//
//  DeviceManager.swift
//  eink
//
//  Created by Aaron on 2024/9/25.
//
import Foundation

protocol BLEDataService {
    func write()
    func read()
}

@Observable 
class DeviceManager:BLEDataService {
    
    var devices:Array<Device> = []
    
    let bleHandle:BLEHandler = BLEHandler()
    
    
    init() {
        createModalDevices()
    }
    
    
    func createModalDevices() {

        let testDevies = [
            Device(indentify: "AA:BB:CC:DD",
                   deviceName: "E-INK Phone Case",
                   deviceFunction: self),
            
            Device(indentify: "EE:FF:GG:HH",
                   deviceName: "E-INK Clock",
                   deviceFunction: self)
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
    
    func stopScan() async {
        await bleHandle.stopScan()
        self.devices.removeAll()
    }
    
    func write() {
        
    }
    
    func read() {
        
    }
    
}
