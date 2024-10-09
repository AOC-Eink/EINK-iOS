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
        
        let savedDevices:[InkDevice]
        var deviceManager:DeviceManager?
        func setManager(_ deviceManager:DeviceManager) {
            if self.deviceManager == nil {
                self.deviceManager = deviceManager
                print("new init model")
            }
            
        }
        
        init(_ savedDevices: [InkDevice]) {
            self.savedDevices = savedDevices
        }
        
        var deviceList:[Device] {
            var save = savedDevices.map{ saveDevice in
                
                Device(indentify: saveDevice.mac ?? "",
                       deviceName: saveDevice.name ?? "")
                
            }
            
            
            
            return save
        }
        
        var disCoverDevices:[Device] {
            self.deviceManager?.devices ?? []
        }
        
        func connectFirstDevice(device:Device) async {

            do {
                guard let result = try await deviceManager?.startConnect(device) else {

                    return
                }
                if result {
                    
                } else {

                }
            } catch {
                
            }
        }
        
        
        func refreshDevicesStatus() async {
            await deviceManager?.startScaning()
        }
        
        func stopScan() async {
            await deviceManager?.stopScan()
        }
        
        
        
    }
}
