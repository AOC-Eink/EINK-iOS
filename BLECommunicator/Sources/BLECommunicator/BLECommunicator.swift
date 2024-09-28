import CoreBluetooth

public class BLECommunicator: NSObject, BLECommunicatorProtocol {
    public weak var delegate: BLECommunicatorDelegate?
    private var centralManager: CBCentralManager!
    private var discoveredDevices: [UUID: BLEDevice] = [:]
    private var connectedDevices: [UUID: CBPeripheral] = [:]
    
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
        await withCheckedContinuation { continuation in
            centralManager.stopScan()
            continuation.resume()
        }
    }
    
    public func connect(to device: BLEDevice) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            centralManager.connect(device.peripheral, options: nil)
            // 在实际应用中，你可能需要设置一个超时机制
        }
    }
    
    public func disconnect(from device: BLEDevice) async {
        await withCheckedContinuation { continuation in
            centralManager.cancelPeripheralConnection(device.peripheral)
            continuation.resume()
        }
    }
    
    public func writeData(_ data: Data, to device: BLEDevice) async throws {
        guard let peripheral = connectedDevices[device.id],
              let characteristic = device.writeCharacteristic else {
            throw BLEError.deviceNotConnected
        }
        
        return try await withCheckedThrowingContinuation { continuation in
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
            peripheral.readValue(for: characteristic)
            // 在实际应用中，你需要处理读取完成的回调
        }
    }
}

extension BLECommunicator: CBCentralManagerDelegate, CBPeripheralDelegate {
    
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        // 处理蓝牙状态更新
    }
    
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let device = BLEDevice(peripheral: peripheral, rssi: RSSI.intValue)
        discoveredDevices[peripheral.identifier] = device
        delegate?.bleCommunicator(self, didDiscoverDevice: discoveredDevices)
    }
    
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        guard let device = discoveredDevices[peripheral.identifier] else { return }
        connectedDevices[peripheral.identifier] = peripheral
        peripheral.delegate = self
        peripheral.discoverServices(nil)//传入需要发现的服务ID
        delegate?.bleCommunicator(self, didConnectDevice: connectedDevices)
    }
    
    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        guard let device = discoveredDevices[peripheral.identifier] else { return }
        connectedDevices.removeValue(forKey: peripheral.identifier)
        delegate?.bleCommunicator(self, didDisconnectDevice: device)
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        for service in services {
            peripheral.discoverCharacteristics(nil, for: service) //传入需要发现的特征
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        for characteristic in characteristics {
            if characteristic.properties.contains(.write) {
                discoveredDevices[peripheral.identifier]?.writeCharacteristic = characteristic
            }
            if characteristic.properties.contains(.read) {
                discoveredDevices[peripheral.identifier]?.readCharacteristic = characteristic
            }
            if characteristic.properties.contains(.notify) {
                peripheral.setNotifyValue(true, for: characteristic)
            }
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard let device = discoveredDevices[peripheral.identifier],
              let data = characteristic.value else { return }
        delegate?.bleCommunicator(self, didReceiveData: data, fromDevice: device)
    }
}
