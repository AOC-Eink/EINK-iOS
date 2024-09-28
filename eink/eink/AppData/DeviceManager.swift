//
//  DeviceManager.swift
//  eink
//
//  Created by Aaron on 2024/9/25.
//

protocol BLEDataService {
    func write()
    func read()
}

import Foundation
@Observable class DeviceManager:BLEDataService {
    
    var devices:Array<Device> = []
    
    let belHandle:BLEHandler = BLEHandler()
    
    
    init() {
        devices = createModalDevices()
    }
    
    
    func createModalDevices() -> [Device] {

        return [
            Device(indentify: "AA:BB:CC:DD",
                   deviceName: "E-INK Phone Case",
                   status: "Unconected",
                   deviceImage: "eink.case.device", 
                   deviceFunction: self),
            
            Device(indentify: "EE:FF:GG:HH",
                   deviceName: "E-INK Clock",
                   status: "Unconected",
                   deviceImage: "eink.clock.device", 
                   deviceFunction: self)
        ]
        
    }
    
    
    
    
    func startScaning() {
        
    }
    
    func write() {
        
    }
    
    func read() {
        
    }
    
}
