//
//  File.swift
//  
//
//  Created by Aaron on 2024/9/24.
//

import Foundation
import CoreBluetooth

public protocol BLECommunicatorProtocol: AnyObject {
    var delegate: BLECommunicatorDelegate? { get set }
    
    func startScan(withServices serviceUUIDs: [CBUUID]?) async
    func stopScan() async
    func connect(to peripheral: CBPeripheral) async throws -> Bool
    func disconnect(from peripheral: CBPeripheral) async
    func writeData(_ data: Data, to device: BLEDevice) async throws
    func readData(from device: BLEDevice) async throws -> Data
}

public protocol BLECommunicatorDelegate: AnyObject {
    func bleCommunicator(_ communicator: BLECommunicatorProtocol, didDiscoverDevice device: [UUID:BLEDevice])
    func bleCommunicator(_ communicator: BLECommunicatorProtocol, didDiscoverDeviceInfo log: String)
    func bleCommunicator(_ communicator: BLECommunicatorProtocol, didConnectDevice device: BLEDevice)
    func bleCommunicator(_ communicator: BLECommunicatorProtocol, didDisconnectDevice device: BLEDevice)
    func bleCommunicator(_ communicator: BLECommunicatorProtocol, didReceiveData data: Data, fromDevice device: BLEDevice)
}
