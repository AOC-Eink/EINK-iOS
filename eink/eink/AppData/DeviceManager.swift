//
//  DeviceManager.swift
//  eink
//
//  Created by Aaron on 2024/9/25.
//
import Foundation
import BLECommunicator

protocol BLEDataService {
//    func write()
//    func read()
    func readDeviceInfo(_ device:BLEDevice) async
    func sendColors(_ device:BLEDevice, colors:[String]) async
}

@Observable 
class DeviceManager:BLEDataService {
    
    
    var devices:Array<Device> = []
    
    let bleHandle:BLEHandler = BLEHandler()
    
    
    init() {
        createModaDevices()
    }
    
    
    func createModaDevices() {

        let testDevies = [
            Device(indentify: "AA:BB:CC:DD",
                   deviceName: "E-INK Phone Case"),
            
            Device(indentify: "EE:FF:GG:HH",
                   deviceName: "E-INK Clock"),
            
            Device(indentify: "EE:FF:GG:AA",
                   deviceName: "E-INK Speaker")
        ]
        
        for device in testDevies {
            CoreDataStack.shared.insetOrUpdateDevice(name: device.deviceName, item: device)
        }
        
    }
    
    
    
    
    func startScaning() async {
        await bleHandle.startScanning(discover: {
            newDevices in
            self.devices.removeAll()
            self.devices = newDevices.map{ ble in
                Device(indentify: ble.id.uuidString,
                       deviceName: ble.name ?? "UnKnown",
                       bleDevice: ble,
                       deviceFunction: self
                )
            }
        })
    }
    
    func startConnect(_ device:Device?) async throws -> Bool {
        guard let bleDevice = device?.bleDevice else {
            return false
        }
        return try await bleHandle.connectToDevice(bleDevice)
    }
    
    
    
    func stopScan() async {
        await bleHandle.stopScan()
        self.devices.removeAll()
    }
    
    
    func readDeviceInfo(_ device: BLEDevice) async {
        await bleHandle.sendData(PacketFormat.readDeviceInfoPacket(), to: device)
    }
    
    func sendColors(_ device: BLEDevice, colors: [String]) async {
        
        let colorInts = colors.map{getUInt8Color($0)}
        let datas = PacketFormat.sendColors(colors: colorInts)
        
        for data in datas {
            await bleHandle.sendData(data, to: device)
        }
        
    }
    
    func getUInt8Color(_ color:String) -> UInt8 {
        switch color {
        case "497A64":
            return 0x05
        case "DFBE24":
            return 0x03
        case "2B78B9":
            return 0x04
        case "3F384A":
            return 0x02
        case "A45942":
            return 0x01
        case "DBDBDB":
            return 0x00
        default:
            return 0x33
        }
    }
    
}
