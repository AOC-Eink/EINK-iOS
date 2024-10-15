import CoreBluetooth

public class BLECommunicator: NSObject, BLECommunicatorProtocol {
    public weak var delegate: BLECommunicatorDelegate?
    private var centralManager: CBCentralManager!
    private var discoveredDevices: [UUID: BLEDevice] = [:]
    private var connectedDevices: [UUID: CBPeripheral] = [:]
    private var readContinuation: CheckedContinuation<Data, Error>?
    private var writeContinuation: CheckedContinuation<Void, Error>?
    private var pendingConnection: (UUID, CheckedContinuation<Bool, Error>)?
    
    public override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    public func startScan(withServices serviceUUIDs: [CBUUID]?) async {
        await withCheckedContinuation { continuation in
            centralManager.scanForPeripherals(withServices: serviceUUIDs, options: nil)
            continuation.resume()
        }
    }
    
    public func stopScan() async {
        Logger.shared.log("-- BLECommunicator stopScan --")
        await withCheckedContinuation { continuation in
            centralManager.stopScan()
            continuation.resume()
        }
    }
    
    public func connect(to peripheral: CBPeripheral) async throws -> Bool {
        Logger.shared.log("连接设备 name = \(peripheral.name ?? ""), uuid = \(peripheral.identifier)  start")

        return try await withThrowingTaskGroup(of: Bool.self) { group in
            group.addTask {
                try await withCheckedThrowingContinuation { continuation in
                    self.pendingConnection = (peripheral.identifier, continuation)
                    self.centralManager.connect(peripheral, options: nil)
                }
            }
            
            group.addTask {
                try await Task.sleep(for: .seconds(20.0))
                throw BLEError.connectionTimeout
            }
            
            // Wait for the first task to complete
            do {
                let result = try await group.next()
                // Cancel the remaining task
                group.cancelAll()
                return result ?? false
            } catch {
                // Cancel the remaining task
                group.cancelAll()
                // If the pending connection still exists, cancel it
                if let (pendingUUID, pendingContinuation) = self.pendingConnection,
                   pendingUUID == peripheral.identifier {
                    pendingContinuation.resume(throwing: error)
                    self.pendingConnection = nil
                }
                throw error
            }
        }
    }
    
    public func disconnect(from peripheral: CBPeripheral) async {
        await withCheckedContinuation { continuation in
            centralManager.cancelPeripheralConnection(peripheral)
            continuation.resume()
        }
    }
    
    public func writeData(_ data: Data, to device: BLEDevice) async throws {
        Logger.shared.log("writeData 开始 device uuid:\(device.id)  writeCharacteristic:\(device.writeCharacteristic?.description ?? "none")")
        guard let peripheral = connectedDevices[device.id],
              let characteristic = device.writeCharacteristic else {
            throw BLEError.deviceNotConnected
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            self.writeContinuation = continuation
            Logger.shared.log("写数据 name = \(peripheral.name ?? "Unknown"), uuid = \(characteristic.uuid) data = \(data.hexEncodedString())")
            peripheral.writeValue(data, for: characteristic, type: .withResponse)
            // 在实际应用中，你需要处理写入完成的回调
        }
    }
    
    public func readData(from device: BLEDevice) async throws -> Data {
        guard let peripheral = connectedDevices[device.id],
              let characteristic = device.readCharacteristic else {
            throw BLEError.deviceNotConnected
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            self.readContinuation = continuation
            peripheral.readValue(for: characteristic)
            // 在实际应用中，你需要处理读取完成的回调
        }
    }
}

extension String {
    func hexadecimal() -> Data? {
        var data = Data(capacity: count / 2)
        let regex = try! NSRegularExpression(pattern: "[0-9a-f]{1,2}", options: .caseInsensitive)
        regex.enumerateMatches(in: self, range: NSMakeRange(0, utf16.count)) { match, _, _ in
            let byteString = (self as NSString).substring(with: match!.range)
            var num = UInt8(byteString, radix: 16)!
            data.append(&num, count: 1)
        }
        guard data.count > 0 else { return nil }
        return data
    }
}

extension BLECommunicator: CBCentralManagerDelegate, CBPeripheralDelegate {
    
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
    }
    
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let log0 = "didDiscover origin: \(peripheral.identifier) name: \(peripheral.name ?? "UnKown")"
        debugPrint(log0)
        Logger.shared.log("搜索到广播 \(log0)")
        guard let adData = advertisementData[CBAdvertisementDataManufacturerDataKey] as? Data else {
            return
        }
//        let hexString = "FFFF4E6274696F6E7300"
//        guard let adData = hexString.hexadecimal(), peripheral.name != nil else { return}
        
        let mfData = MFData(adData)
        let log2 = "didDiscover mfData: vid:\(mfData.vid) pid: \(mfData.pid)"
        Logger.shared.log(log2)
        
        if mfData.vid == AOCMF.vid || mfData.vid == AOCMF.testVid {
            Logger.shared.log("搜索到设备 name = \(peripheral.name ?? "Unknown"), uuid = \(peripheral.identifier) vid\(mfData.vid) pid: \(mfData.pid)")
            let device = BLEDevice(peripheral: peripheral, pid: mfData.pid, mid: mfData.mid)
            discoveredDevices[peripheral.identifier] = device
            delegate?.bleCommunicator(self, didDiscoverDevice: discoveredDevices)
        }
        
    }
    
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        Logger.shared.log("连接设备 name = \(peripheral.name ?? "Unknown"), uuid = \(peripheral.identifier)  didConnect")
        peripheral.delegate = self
        peripheral.discoverServices([AOCMF.ServiceUUID, AOCMF.TestServicesUUID1])//传入需要发现的服务ID
        //delegate?.bleCommunicator(self, didConnectDevice: connectedDevices[peripheral.identifier.uuid])
    }
    
    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        guard let device = discoveredDevices[peripheral.identifier] else { return }
        delegate?.bleCommunicator(self, didDisconnectDevice: device)
        connectedDevices.removeValue(forKey: peripheral.identifier)
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        for service in services {
            peripheral.discoverCharacteristics([AOCMF.TXCharacteristicsUUID,
                                                AOCMF.RXCharacteristicsUUID,
                                                //AOCMF.TestCharacteristicsUUID,
                                                AOCMF.TestCharacteristicsUUID0,
//                                                AOCMF.TestCharacteristicsUUID1,
//                                                AOCMF.TestCharacteristicsUUID2
                                               ], for: service) //传入需要发现的特征
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        Logger.shared.log("发现服务 name = \(peripheral.name ?? "Unknown"), uuid = \(peripheral.identifier)")
        guard let characteristics = service.characteristics else {
            Logger.shared.log("未发现特证 name = \(peripheral.name ?? "Unknown"), uuid = \(peripheral.identifier)")
            return
        }
        Logger.shared.log("发现特证 name = \(peripheral.name ?? "Unknown"), uuid = \(peripheral.identifier) 数量 = \(characteristics.count)")
        for characteristic in characteristics {
            Logger.shared.log("发现特证 name = \(peripheral.name ?? "Unknown"), 特证 uuid = \(characteristic.uuid)")
            if  characteristic.uuid.isEqual(AOCMF.TXCharacteristicsUUID) { //characteristic.properties.contains(.writeWithoutResponse) &&
                Logger.shared.log("发现写服务 name = \(peripheral.name ?? "Unknown"), uuid = \(characteristic.uuid)")
                discoveredDevices[peripheral.identifier]?.writeCharacteristic = characteristic
            }
            
            if  characteristic.uuid.isEqual(AOCMF.TestCharacteristicsUUID0) { //characteristic.properties.contains(.writeWithoutResponse) &&
                Logger.shared.log("发现写服务 name = \(peripheral.name ?? "Unknown"), uuid = \(characteristic.uuid)")
                discoveredDevices[peripheral.identifier]?.writeCharacteristic = characteristic
            }
            if characteristic.uuid.isEqual(AOCMF.RXCharacteristicsUUID) { //characteristic.properties.contains(.read) &&
                Logger.shared.log("发现读服务 name = \(peripheral.name ?? "Unknown"), uuid = \(characteristic.uuid)")
                discoveredDevices[peripheral.identifier]?.readCharacteristic = characteristic
            }
            
            
            if characteristic.properties.contains(.notify) {
                peripheral.setNotifyValue(true, for: characteristic)
                Logger.shared.log("设置通知 name = \(peripheral.name ?? "Unknown"), uuid = \(characteristic.uuid)")
                
                guard let writeCharacteristic = discoveredDevices[peripheral.identifier]?.writeCharacteristic else {
                    Logger.shared.log("未发现写特证 0 name = \(peripheral.name ?? "Unknown"), uuid = \(peripheral.identifier)")
                    if let (pendingUUID, continuation) = pendingConnection, pendingUUID == peripheral.identifier {
                        continuation.resume(returning:false)
                    }
                    return
                }

                
                guard let connectDeivce = discoveredDevices[peripheral.identifier] else {
                    Logger.shared.log("未发现连接设备 name = \(peripheral.name ?? "Unknown"), uuid = \(peripheral.identifier)")
                    if let (pendingUUID, continuation) = pendingConnection, pendingUUID == peripheral.identifier {
                        continuation.resume(returning:false)
                    }
                    return
                }
                connectedDevices[peripheral.identifier] = peripheral
                
                if let (pendingUUID, continuation) = pendingConnection, pendingUUID == peripheral.identifier {
                    continuation.resume(returning: true)
                    Logger.shared.log("连接成功返回结束 name = \(peripheral.name ?? "Unknown"), uuid = \(peripheral.identifier)")
                    pendingConnection = nil
                    delegate?.bleCommunicator(self, didConnectDevice: connectDeivce)
                }
                
            } else {
                Logger.shared.log("未发现通知特征 name = \(peripheral.name ?? "Unknown"), uuid = \(characteristic.uuid)")
            }
        }
        
        if let (pendingUUID, continuation) = pendingConnection, pendingUUID == peripheral.identifier {
            continuation.resume(returning:false)
        }
        
        
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard let device = discoveredDevices[peripheral.identifier],
              let data = characteristic.value else { return }
        Logger.shared.log("peripheral didUpdateValueFor : \(peripheral.name ?? "") data: \(data)")
        if let error = error {
            readContinuation?.resume(throwing: error)
        } else if let value = characteristic.value {
            readContinuation?.resume(returning: value)
        } else {
            readContinuation?.resume(throwing: BLEError.noData)
        }
        readContinuation = nil
        delegate?.bleCommunicator(self, didReceiveData: data, fromDevice: device)
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            writeContinuation?.resume(throwing: error)
            Logger.shared.log("写入失败 name = \(peripheral.name ?? "Unknown"), uuid = \(characteristic.uuid) error = \(error.localizedDescription))")
        } else {
            Logger.shared.log("成功写入特征值: \(characteristic.uuid)")
            if let value = characteristic.value {
                Logger.shared.log("写入的数据 name = \(peripheral.name ?? "Unknown"), uuid = \(characteristic.uuid) data = \(value.hexEncodedString()))")
            }
            writeContinuation?.resume()
        }
        writeContinuation = nil
    }
    
    
}

extension Data {
    func hexEncodedString() -> String {
        return map { String(format: "%02hhx", $0) }.joined()
    }
}
