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
        
        var errorMessage:String?
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
        
        var showDevices:(DeviceManager) -> [Device] = { deviceManager in
            deviceManager.showDevices
        }
        
        
        func refreshDevicesStatus(_ deviceManager:DeviceManager)  {
            deviceManager.startScanning(discover: nil)
        }
        
        func stopScan(_ deviceManager:DeviceManager)  {
             deviceManager.stopScanning()
        }
        
        
        func connectDevice(_ deviceManager:DeviceManager, device:Device) async {
            
            do {
                let result = try await deviceManager.startConnect(device)
                if result {
                    errorMessage = "success"
                } else {
                    errorMessage = "Connect failured"
                }
            } catch {
                errorMessage = "Connect \(error)"
            }
        }
        
        func removeDevice(_ deviceManager:DeviceManager, device:Device) async {
            await deviceManager.removeDevice(device: device)
        }
        
        
    }
}
