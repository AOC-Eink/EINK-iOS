//
//  DiscoverView.Model.swift
//  eink
//
//  Created by Aaron on 2024/9/14.
//

import Foundation
import SwiftUI

extension DiscoverView {
    
    @Observable
    class Model {
        
        private let deviceManager:DeviceManager
        init(deviceManager: DeviceManager) {
            self.deviceManager = deviceManager
        }
        
        var errorMessage:String?
        var nfcCommunicator:NFCCommunicator?
//        func setManager(_ deviceManager:DeviceManager) {
//            if self.deviceManager == nil {
//                self.deviceManager = deviceManager
//                print("new init model")
//            }
//
//        }
        
//        init(_ deviceManager:DeviceManager) {
//            self.deviceManager = deviceManager
//        }
        
//        var showDevices:(DeviceManager) -> [Device] = { deviceManager in
//            deviceManager.showDevices
//        }
        
        var showDevices: [Device] {
            deviceManager.showDevices
        }
        
        
        func refreshDevicesStatus()  {
            deviceManager.startScanning(discover: nil)
        }
        
        func stopScan()  {
             deviceManager.stopScanning()
        }
        
        
        func connectDevice(device:Device) async -> Bool {
            
            do {
                let result = try await deviceManager.startConnect(device)
                if result {
                    errorMessage = "success"
                    return true
                } else {
                    errorMessage = "Connect failured"
                    return false
                }
            } catch {
                errorMessage = "Connect \(error)"
                return false
            }
        }
        
        func removeDevice(device:Device) async {
            await deviceManager.removeDevice(device: device)
        }
        
        func activeNFCDevice() {
            stopScan();
            nfcCommunicator = NFCCommunicator()

            nfcCommunicator?.startSession { result in
                switch result {
                case .success(let macAddress):
                    print("操作成功完成，MAC地址为: \(macAddress)")
                    //AlertWindow.show(title: "读取结果", message: "\(macAddress)")
                    Task {
                        await self.startScanAndConnect(mac: macAddress)
                    }
                    
                case .failure(let error):
                    print("操作失败: \(error.localizedDescription)")
                    AlertWindow.show(title: "Notify", message: error.localizedDescription)
                }
            }
        }
        
        func startScanAndConnect(mac:String) async {
            
            deviceManager.startScanning(mac) { device, success in
                
                if success {
                    self.nfcCommunicator?.stopSession(message: "Connect successfully")
                } else {
                    self.nfcCommunicator?.stopSession(message: "Connect failed, please try again")
                }
                self.nfcCommunicator = nil
            
            }
            
        }
        
        
    }
}
