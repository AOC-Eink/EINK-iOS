//
//  AddDeviceView.Model.swift
//  eink
//
//  Created by Aaron on 2024/9/27.
//

import Foundation
import SwiftUI

extension AddDeviceView {
    
    @Observable
    class Model {
        
        var deviceManager:DeviceManager?
        func setManager(_ deviceManager:DeviceManager) {
            if self.deviceManager == nil {
                self.deviceManager = deviceManager
                print("new init model")
            }
            
        }
        
        var errorMessage:String?
        
        
        enum AddStatus {
            case scan
            case scanNone
            case descovered
            case select
            case adding
            case addSuccess
            case addFail
        }
        
        var selectDevice:Device?
        
        var addStatus:AddStatus = .scanNone {
            didSet{
                print("new addStatus = \(addStatus)")
            }
        }
        
        var discoverDevices:[Device] {
            self.deviceManager?.discoveredDevices ?? []
        }
        
        
        func startScan() {
            deviceManager?.startScanning()
        }
        
        func startConnect() async {
            
            do {
                guard let result = try await deviceManager?.startConnect(selectDevice) else {
                    errorMessage = "Connect fail, please try again later"
                    return
                }
                if result {
                    saveAdd()
                    addStatus = .addSuccess
                } else {
                    errorMessage = "Connect failured"
                }
            } catch {
                errorMessage = "Connect \(error)"
            }
        }
        
        private func stopConnect() {
            
        }
        
        func stopScan() {
            print("stopScan")
            deviceManager?.stopScanning()
        }
        
        func stopTask() {
            addStatus = .scan
            stopScan()
        }
        
        func saveAdd() {
            if let device = selectDevice {
                deviceManager?.addNewDevice(device: device)
            }
        }
        
        
        static let modaModel = Model()
        
        
    }
}
