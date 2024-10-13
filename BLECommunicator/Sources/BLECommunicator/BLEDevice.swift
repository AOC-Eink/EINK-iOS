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
    public let peripheral: CBPeripheral
    public var writeCharacteristic: CBCharacteristic?
    public var readCharacteristic: CBCharacteristic?
    
    init(peripheral: CBPeripheral, pid: UInt16, mid: UInt8 = 0) {
        self.id = peripheral.identifier
        self.pid = pid
        self.mid = mid
        self.name = peripheral.name
        self.peripheral = peripheral
    }
}
