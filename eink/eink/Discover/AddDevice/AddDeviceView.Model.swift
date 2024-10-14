//
//  AddDeviceView.Model.swift
//  eink
//
//  Created by Aaron on 2024/9/27.
//

import Foundation
import SwiftUI
import BLECommunicator

extension AddDeviceView {
    
    @Observable
    class Model {
        
//        var deviceManager:DeviceManager?
//        func setManager(_ deviceManager:DeviceManager) {
//            if self.deviceManager == nil {
//                self.deviceManager = deviceManager
//                print("new init model")
//            }
//            
//        }
        
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
        
        var discoverDevices:[Device] = []
        
        
        func startScan(_ deviceManager:DeviceManager) {
            deviceManager.startScanning { devices, isStop in
                self.discoverDevices.removeAll()
                self.discoverDevices = devices
                if isStop && devices.isEmpty {
                    self.addStatus = .scanNone
                }
            }
        }
        
        func startConnect(_ deviceManager:DeviceManager) async {
            
//            DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
//                self.saveAdd()
//                self.addStatus = .addSuccess
//            })
//            
//            return
            
            do {
                let result = try await deviceManager.startConnect(selectDevice)

                if result {
                    saveAdd(deviceManager)
                    addStatus = .addSuccess
                } else {
                    //errorMessage = "Connect failured"
                    saveAdd(deviceManager)
                    addStatus = .addSuccess
                }
            } catch {
                //errorMessage = "Connect \(error)"
                saveAdd(deviceManager)
                addStatus = .addSuccess
            }
        }
        
        private func stopConnect() {
            
        }
        
        func stopScan(_ deviceManager:DeviceManager) {
            Logger.shared.log("-- stopScan --")
            deviceManager.stopScanning()
        }
        
        func stopTask(_ deviceManager:DeviceManager) {
            addStatus = .scan
            stopScan(deviceManager)
        }
        
        func saveAdd(_ deviceManager:DeviceManager) {
            if let device = selectDevice {
                deviceManager.addNewDevice(device: device)
            }
        }
        
        
        static let modaModel = Model()
        
        
    }
}
