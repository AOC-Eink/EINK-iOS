//
//  BLEHandler.swift
//  eink
//
//  Created by Aaron on 2024/9/25.
//

import Foundation
import BLECommunicator
import CoreBluetooth

class BLEHandler {
    
    let communicator: BLECommunicatorProtocol = BLECommunicator()
    private var pendingConnection: (UUID, CheckedContinuation<Bool, Error>)?
    
    var disconnectNotify:((BLEDevice)->Void)?
    var didConnectNotify:((BLEDevice)->Void)?
    var discoverDeviceInfo:((String)->Void)?
    
    init() {
        communicator.delegate = self
    }
    
    var discoverDevices:(([BLEDevice])->Void)?
    var connectDevice:((BLEDevice)->Void)?
    
    
    func startScanning(discover:@escaping (([BLEDevice])->Void)) async {
        self.discoverDevices = nil
        self.discoverDevices = discover
        await communicator.startScan(withServices: nil)
    }
    
    func stopScan() async {
        await communicator.stopScan()
    }
    
    func connectToDevice(_ device: BLEDevice) async throws -> Bool {
//        do {
//            let result = try await communicator.connect(to: device.peripheral)
//            print("Connected to device: \(device.name ?? "Unknown")")
//        } catch {
//            print("Failed to connect: \(error)")
//        }
        return try await communicator.connect(to: device.peripheral)
    }
    
    func sendData(_ data: Data, to device: BLEDevice) async {
        do {
            Logger.shared.log("Data sent")
            try await communicator.writeData(data, to: device)
            Logger.shared.log("Data sent successfully")
        } catch {
            Logger.shared.log("Failed to send data: \(error)")
        }
    }
    
    func disconnetDevice(device: BLEDevice) async {
        await communicator.disconnect(from: device.peripheral)
    }
}

extension BLEHandler: BLECommunicatorDelegate {
    func bleCommunicator(_ communicator: any BLECommunicatorProtocol, didDiscoverDevice device: [UUID:BLEDevice]) {
        Logger.shared.log("didDiscoverDevice count:\(device.count)")
        discoverDevices?(device.map{$0.value})
    }
    
    func bleCommunicator(_ communicator: any BLECommunicatorProtocol, didConnectDevice device: BLEDevice) {
        didConnectNotify?(device)
    }
    
    func bleCommunicator(_ communicator: any BLECommunicatorProtocol, didDisconnectDevice device: BLEDevice) {
        disconnectNotify?(device)
    }
    
    func bleCommunicator(_ communicator: any BLECommunicatorProtocol, didReceiveData data: Data, fromDevice device: BLEDevice) {
        
    }
    
    func bleCommunicator(_ communicator: BLECommunicatorProtocol, didDiscoverDeviceInfo log: String) {
        discoverDeviceInfo?(log)
    }
    
    
}
