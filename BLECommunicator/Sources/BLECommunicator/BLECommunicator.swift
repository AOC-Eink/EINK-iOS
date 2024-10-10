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
        print("startScan")
        await withCheckedContinuation { continuation in
            print("scanForPeripherals")
            centralManager.scanForPeripherals(withServices: serviceUUIDs, options: nil)
            continuation.resume()
        }
    }
    
    public func stopScan() async {
        await withCheckedContinuation { continuation in
            centralManager.stopScan()
            continuation.resume()
        }
    }
    
    public func connect(to peripheral: CBPeripheral) async throws -> Bool {
        return try await withThrowingTaskGroup(of: Bool.self) { group in
            group.addTask {
                try await withCheckedThrowingContinuation { continuation in
                    self.pendingConnection = (peripheral.identifier, continuation)
                    self.centralManager.connect(peripheral, options: nil)
                }
            }
            
            group.addTask {
                try await Task.sleep(for: .seconds(10.0))
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
        guard let peripheral = connectedDevices[device.id],
              let characteristic = device.writeCharacteristic else {
            throw BLEError.deviceNotConnected
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            self.writeContinuation = continuation
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

extension BLECommunicator: CBCentralManagerDelegate, CBPeripheralDelegate {
    
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
    }
    
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        print("didDiscover: \(peripheral.identifier) name: \(peripheral.name ?? "")")
        
        guard let adData = advertisementData[CBAdvertisementDataManufacturerDataKey] as? Data else {
            return
        }
        
        let mfData = MFData(adData)
        if mfData.vid == AOCMF.vid {
            let device = BLEDevice(peripheral: peripheral, pid: mfData.pid, mid: mfData.mid)
                discoveredDevices[peripheral.identifier] = device
                delegate?.bleCommunicator(self, didDiscoverDevice: discoveredDevices)
        }
        
    }
    
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        
        peripheral.delegate = self
        peripheral.discoverServices([AOCMF.AocUUID])//传入需要发现的服务ID
        //delegate?.bleCommunicator(self, didConnectDevice: connectedDevices)
    }
    
    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        guard let device = discoveredDevices[peripheral.identifier] else { return }
        connectedDevices.removeValue(forKey: peripheral.identifier)
        delegate?.bleCommunicator(self, didDisconnectDevice: device)
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        for service in services {
            peripheral.discoverCharacteristics([AOCMF.RXCharacteristicsUUID, AOCMF.TXCharacteristicsUUID], for: service) //传入需要发现的特征
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        for characteristic in characteristics {
            if characteristic.properties.contains(.write) && characteristic.uuid.isEqual(AOCMF.TXCharacteristicsUUID) {
                discoveredDevices[peripheral.identifier]?.writeCharacteristic = characteristic
            }
            if characteristic.properties.contains(.read) && characteristic.uuid.isEqual(AOCMF.RXCharacteristicsUUID) {
                discoveredDevices[peripheral.identifier]?.readCharacteristic = characteristic
            }
            if characteristic.properties.contains(.notify) {
                peripheral.setNotifyValue(true, for: characteristic)
                //到这里先假设连接成功
                //guard let device = discoveredDevices[peripheral.identifier] else { return }
                delegate?.bleCommunicator(self, didConnectDevice: peripheral)
                connectedDevices[peripheral.identifier] = peripheral
                if let (pendingUUID, continuation) = pendingConnection, pendingUUID == peripheral.identifier {
                    continuation.resume(returning: true)
                    pendingConnection = nil
                    break
                }
            }
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard let device = discoveredDevices[peripheral.identifier],
              let data = characteristic.value else { return }
        print("peripheral didUpdateValueFor : \(peripheral.name ?? "") data: \(data)")
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
        } else {
            writeContinuation?.resume()
        }
        writeContinuation = nil
    }
    
    
}
