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
    public let name: String?
    public let rssi: Int
    let peripheral: CBPeripheral
    var writeCharacteristic: CBCharacteristic?
    var readCharacteristic: CBCharacteristic?
    
    init(peripheral: CBPeripheral, rssi: Int) {
        self.id = peripheral.identifier
        self.name = peripheral.name
        self.rssi = rssi
        self.peripheral = peripheral
    }
}
