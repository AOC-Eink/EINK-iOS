//
//  File.swift
//  
//
//  Created by Aaron on 2024/9/24.
//

import Foundation
import CoreBluetooth

public struct BLEDevice: Identifiable {
    public let id: UUID
    public let pid: UInt16
    public let mid: UInt8?
    public let name: String?
    public let mac: String?
    public let peripheral: CBPeripheral
    public var writeCharacteristic: CBCharacteristic?
    public var readCharacteristic: CBCharacteristic?
    
    init(peripheral: CBPeripheral, pid: UInt16, mid: UInt8 = 0, mac: String? = nil) {
        self.id = peripheral.identifier
        self.pid = pid
        self.mid = mid
        self.name = peripheral.name
        self.peripheral = peripheral
        self.mac = mac
    }
    
    
    public static var mockDevice: BLEDevice {
        let mockPeripheral = unsafeBitCast(
            NSObject(), to: CBPeripheral.self
        )
        return BLEDevice(peripheral: mockPeripheral, pid: 0x4E62, mid: 1, mac: "00:11:22:33:44:55")
    }
}
