//
//  DeviceManager.swift
//  eink
//
//  Created by Aaron on 2024/9/25.
//
import Foundation
import BLECommunicator
import Combine

protocol BLEDataService {
//    func write()
//    func read()
    func readDeviceInfo(_ device:BLEDevice) async
    func sendColors(_ device:Device, colors:[String]) async
}

@Observable 
class DeviceManager:BLEDataService {
    
    private var scanTask: Task<Void, Never>?
    private var cancellable: AnyCancellable?
    
    
    var discoveredDevices:Array<Device> = []
    //var saveDevices:Array<InkDevice> = []
    var showDevices:Array<Device> = []
    //var dbShowDevices:Array<Device> = []
    
    let bleHandle:BLEHandler = BLEHandler()
    
    var discoverInfo:[String] = []
    
    
    init() {
        createModaDevices()
        disconnectedListener()
        didConnectedListener()
        dicoverLogListener()
    }
    
    
    func disconnectedListener() {
        bleHandle.disconnectNotify = { [self] device in
            if let index = self.showDevices.firstIndex(where: { $0.id == device.id.uuidString }) {
                self.showDevices[index].bleDevice = device
            }
        }
    }
    
    func dicoverLogListener() {
        bleHandle.discoverDeviceInfo = { [self] log in
            discoverInfo.append(log)
        }
    }
    
    func didConnectedListener() {
        bleHandle.didConnectNotify = { [self] device in
//            if let index = self.showDevices.firstIndex(where: { $0.id == device.identifier.uuidString }) {
//                self.showDevices[index].bleDevice = device
//            }
        }
    }
    
    func updateSaveDevices(_ devices:[InkDevice]) {
//        saveDevices.removeAll()
//        saveDevices = devices;
        
        showDevices = devices.map{Device(indentify: $0.mac ?? "", deviceName: $0.name ?? "")}
        
    }
    
    func addNewDevice(device:Device) {
        
        showDevices.append(device)
        
        CoreDataStack.shared.insetOrUpdateDevice(name: device.deviceName, item: device)
    }
    
    
    func createModaDevices() {

        let testDevies = [
            Device(indentify: "AA:BB:CC:DD",
                   deviceName: "E-INK Phone Case"),
            
            Device(indentify: "EE:FF:GG:HH",
                   deviceName: "E-INK Clock fake"),
            
            Device(indentify: "EE:FF:GG:AA",
                   deviceName: "E-INK Speaker fake")
        ]
        
        for device in testDevies {
            CoreDataStack.shared.insetOrUpdateDevice(name: device.deviceName, item: device)
        }
        
    }
    
    func removeDevice(device:Device) {
        showDevices.removeAll(where: {$0.indentify == device.indentify})
        try? CoreDataStack.shared.deleteDeviceWith(mac: device.indentify)
    }
    
    
    func updateDevicesByDiscovered(_ devices: [BLEDevice]) {
        for device in devices {
            if let index = showDevices.firstIndex(where: { $0.id == device.id.uuidString }) {
                showDevices[index].bleDevice = device
            }
//            else {
//                 await connectFirstDevice(device: device)
//            }
        }
    }
    
    
    
    
    func startScanning(stopHandle:(()->Void)?) {
        discoverInfo.removeAll()
        // 取消之前的扫描任务（如果存在）
        scanTask?.cancel()
        cancellable?.cancel()

        // 创建新的扫描任务
        scanTask = Task {
            await performScan()
        }

        // 设置30秒后自动停止扫描
        cancellable = Timer.publish(every: 15, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                stopHandle?()
                self?.stopScanning()
            }
    }
    
    private func performScan() async {
        await bleHandle.startScanning(discover: { [weak self] newDevices in
            guard let self = self else { return }
            self.discoveredDevices.removeAll()
            self.discoveredDevices = newDevices.map { ble in
                Device(indentify: ble.id.uuidString,
                       deviceName: ble.name ?? ble.peripheral.identifier.uuidString,
                       bleDevice: ble,
                       deviceFunction: self)
            }
            
            self.updateDevicesByDiscovered(newDevices)
        })
    }
    
    
    
    func startConnect(_ device:Device?) async throws -> Bool {
        guard let bleDevice = device?.bleDevice else {
            return false
        }
        return try await bleHandle.connectToDevice(bleDevice)
    }
    
    
    
    func stopScanning() {
        print("stopScanning")
        scanTask?.cancel()
        cancellable?.cancel()
        Task {
            await bleHandle.stopScan()
        }
        self.discoveredDevices.removeAll()
    }
    
    
    func readDeviceInfo(_ device: BLEDevice) async {
        await bleHandle.sendData(PacketFormat.readDeviceInfoPacket(), to: device)
    }
    
    func sendColors(_ device: Device, colors: [String]) async {
        
        guard let bleDevice = device.bleDevice else { return }
        
        let colorInts = colors.map{getUInt8Color($0)}
        let mcuInts = device.formMCUCommand(colors: colorInts)
        debugPrint("sendColors: \(mcuInts)")
        let datas = PacketFormat.sendColors(header: device.commandHeader, colors: mcuInts)
        
        for data in datas {
            await bleHandle.sendData(data, to: bleDevice)
        }
        
    }
    
    func getUInt8Color(_ color:String) -> UInt8 {
        switch color {
        case "497A64":
            return 0x05 //green
        case "DFBE24":
            return 0x03 //yellow
        case "2B78B9":
            return 0x04 //blue
        case "3F384A":
            return 0x02 //black
        case "A45942":
            return 0x01 // red
        case "DBDBDB":
            return 0x00 // white
        default:
            return 0x33
        }
    }
    
}
