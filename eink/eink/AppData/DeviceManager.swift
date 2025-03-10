//
//  DeviceManager.swift
//  eink
//
//  Created by Aaron on 2024/9/25.
//
import Foundation
import BLECommunicator
import Combine
import SwiftUI


protocol BLEDataService {
//    func write()
//    func read()
    func readDeviceInfo(_ device:BLEDevice) async throws
    func sendColors(_ device:Device, colors: [[String]], timeInterval:Int?) async throws
    //func sendTestPlayColors(_ device: Device, designs:[Design], gapTime: Int, isShow:Bool) async throws
}

@Observable 
class DeviceManager:BLEDataService {
    
    private var timerCancellable: AnyCancellable?
    private var counter = 0
    
    private var scanTask: Task<Void, Never>?
    private var cancellable: AnyCancellable?
    
    
    var discoveredDevices:Array<Device> = []
    //var saveDevices:Array<InkDevice> = []
    var showDevices:Array<Device> = []
    //var dbShowDevices:Array<Device> = []
    
    let bleHandle:BLEHandler = BLEHandler()
    
    var discoverInfo:[String] = []
    
    
    init() {
        //createModaDevices()
        disconnectedListener()
        didConnectedListener()
        dicoverLogListener()
    }
    
    
    func disconnectedListener() {
        bleHandle.disconnectNotify = { [self] device in
            if let index = self.showDevices.firstIndex(where: { $0.id == device.id.uuidString }) {
                self.showDevices[index].bleDevice = nil
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
            if let index = self.showDevices.firstIndex(where: { $0.id == device.peripheral.identifier.uuidString }) {
                self.showDevices[index].bleDevice = device
            } else {
                CoreDataStack.shared.insetOrUpdateDevice(name: device.name ?? "Unknown",
                                                         item: Device(indentify: device.id.uuidString,
                                                                      deviceName: device.name ?? "Unknown",
                                                                      bleDevice: device))
                self.showDevices.append(Device(indentify: device.id.uuidString,
                                               deviceName: device.name ?? "Unknown",
                                               bleDevice: device))
            }
        }
    }
    
    func updateSaveDevices(_ devices:[InkDevice]) {
//        saveDevices.removeAll()
//        saveDevices = devices;
        
        showDevices = devices.map{Device(indentify: $0.mac ?? "", deviceName: $0.name ?? "", deviceFunction: self)}
        
    }
    
    func addNewDevice(device:Device) {
        if let index = self.showDevices.firstIndex(where: { $0.id == device.id }) {
            self.showDevices[index].deviceFuction = device.deviceFuction
        } else {
            showDevices.append(device)
        }
        
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
    
    func removeDevice(device:Device) async {
        showDevices.removeAll(where: {$0.indentify == device.indentify})
        try? CoreDataStack.shared.deleteDeviceWith(mac: device.indentify)
        
        guard let bleDevice = device.bleDevice else { return }
        await bleHandle.disconnetDevice(device: bleDevice)
    }
    
    
    
    
    func startScanning(discover: (([Device], Bool)->Void)?) {
        discoverInfo.removeAll()
        discoveredDevices.removeAll()
        // 取消之前的扫描任务（如果存在）
        scanTask?.cancel()
        cancellable?.cancel()

        // 创建新的扫描任务
        scanTask = Task {
            await performScan(discover: discover)
        }

        // 设置30秒后自动停止扫描
        cancellable = Timer.publish(every: 15, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                discover?(self?.discoveredDevices ?? [], true)
                self?.stopScanning()
                if discover == nil {
                    self?.discoveredDevices.removeAll()
                }
            }
    }
    
    private func performScan(discover: (([Device], Bool)->Void)?) async {
        await bleHandle.startScanning(discover: { [weak self] newDevices in
            guard let self = self else { return }
            self.discoveredDevices.removeAll()
            self.discoveredDevices = newDevices.map { ble in
                Device(indentify: ble.id.uuidString,
                       deviceName: ble.name ?? ble.peripheral.identifier.uuidString,
                       bleDevice: ble,
                       deviceFunction: self)
            }
            discover?(self.discoveredDevices, false)
            //if discover == nil {
                self.updateDevicesByDiscovered(newDevices)
            //}
            
        })
    }
    
    func updateDevicesByDiscovered(_ devices: [BLEDevice]) {
        for device in devices {
            if let index = showDevices.firstIndex(where: { $0.id == device.id.uuidString }) {
                showDevices[index].bleDevice = device
            }
        }
    }
    
    func startConnect(_ device:Device?) async throws -> Bool {
        guard let bleDevice = device?.bleDevice else {
            return false
        }
        
        //return true
        
        Logger.shared.log("点击设备开始连接 name = \(device?.deviceName ?? ""), uuid = \(bleDevice.peripheral.identifier)")
        return try await bleHandle.connectToDevice(bleDevice)
    }
    
    
    
    func stopScanning() {
        print("stopScanning")
        scanTask?.cancel()
        cancellable?.cancel()
        Task {
            await bleHandle.stopScan()
        }
    }
    
    
    func readDeviceInfo(_ device: BLEDevice) async throws {
        try await bleHandle.sendData(PacketFormat.readDeviceInfoPacket(), to: device)
    }
    
    func getCurrentTimeHexArray() -> [UInt8] {
        let date = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date) % 12
        let minute = calendar.component(.minute, from: date)
        let second = calendar.component(.second, from: date)

        let formattedHour: UInt8 = UInt8(hour == 0 ? 12 : hour)  // 12 小时制中 0 点显示为 12

        return [formattedHour, UInt8(minute), UInt8(second)]
    }
    
    func sendColors(_ device: Device, colors: [[String]], timeInterval:Int?) async throws {
        
        guard let bleDevice = device.bleDevice else { return }
        
        var headers = [UInt8]()
        headers.append(UInt8(device.commandHeader))
        
        
        if timeInterval == nil {
            headers.append(CommandType.writeCmd.rawValue)
            
            headers += getCurrentTimeHexArray()
            
            headers.append(0x00)
            headers.append(0x00) //延时两个字节
            headers.append(0x00) //单个命令不设置张数
        } else {
            headers.append(CommandType.writeCmdQueue.rawValue)
            
            headers += getCurrentTimeHexArray()
            
            let time = UInt16(timeInterval ?? 0)
            let highByte: UInt8 = UInt8((time >> 8) & 0xFF)
            let lowByte: UInt8 = UInt8(time & 0xFF)
            headers.append(highByte)
            headers.append(lowByte) //延时两个字节
            headers.append(UInt8(colors.count)) //张数
        }
        
        

        var allColors = [UInt8]()
        for color in colors {
            let colorInts = color.map{getUInt8Color($0)}
            let mcuInts = device.formMCUCommand(colors: colorInts)
            allColors += mcuInts
        }
        
        let length = UInt16(allColors.count)
        let highByte: UInt8 = UInt8((length >> 8) & 0xFF)
        let lowByte: UInt8 = UInt8(length & 0xFF)
        headers.append(highByte)
        headers.append(lowByte) //长度两个字节
        Logger.shared.log("sendColors: \(headers + allColors)")
        let data = PacketFormat.sendColor(header: headers, colors: allColors)

        try await bleHandle.sendData(data, to: bleDevice)
        
        
//        let datas = PacketFormat.sendColors(header: device.commandHeader, colors: mcuInts)
//        
//        for data in datas {
//            await bleHandle.sendData(data, to: bleDevice)
//        }
        
    }
    
    func taskScheduler(interval: TimeInterval, taskCount: Int, task: @escaping (Int) -> Void) {
        timerCancellable?.cancel()
        counter = 0
        task(self.counter)
        counter += 1
        timerCancellable = Timer.publish(every: interval, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                if self.counter < taskCount {
                    task(self.counter)
                    self.counter += 1
                } else {
                    self.timerCancellable?.cancel()
                }
            }
    }
    
    func getUInt8Color(_ color:String) -> UInt8 {
        switch color {
        case "497A64":
            return 0x05 //green
        case "DFBE24":
            return 0x01 //yellow
        case "2B78B9":
            return 0x02 //blue
        case "3F384A":
            return 0x04 //black
        case "A45942":
            return 0x03 // red
        case "DBDBDB":
            return 0x00 // white
        default:
            return 0x33
        }
    }
    
}
