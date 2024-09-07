//
//  Device.swift
//  eink
//
//  Created by Aaron on 2024/9/6.
//

import Foundation
import Combine

enum ConnectStatus {
    case unConnected
    case conected
    
}

struct Device: Equatable, Hashable {
    
    let indendify:String
    let deviceName:String
    
    
    var status:String = "Unconnected"
    var deviceImage:String = ""
    
}


@Observable class DeviceManager {

    var devices:Array<Device> = []
    
    
    
    
    init() {
        devices = createModalDevices()
    }
    
    
    func createModalDevices() -> [Device] {

        return [
            Device(indendify: UUID().uuidString, deviceName: "E-INK Phone Case", status: "Unconected", deviceImage: "eink.case.device"),
            Device(indendify: UUID().uuidString, deviceName: "E-INK Clock", status: "Unconected", deviceImage: "eink.clock.device")
        ]
        
    }
    
}


