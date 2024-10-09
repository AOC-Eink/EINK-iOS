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
    public let pid: Int
    public let mid: Int?
    public let name: String?
    public let peripheral: CBPeripheral
    var writeCharacteristic: CBCharacteristic?
    var readCharacteristic: CBCharacteristic?
    
    init(peripheral: CBPeripheral, pid: Int, mid: Int = 0) {
        self.id = peripheral.identifier
        self.pid = pid
        self.mid = mid
        self.name = peripheral.name
        self.peripheral = peripheral
    }
}
