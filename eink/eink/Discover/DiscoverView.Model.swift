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
        var testDevices:[Device]
        
        init(_ savedDevices: [InkDevice], _ devices:[Device] = []) {
            self.savedDevices = savedDevices
            self.testDevices = devices
        }
        
        var deviceList:[Device] {
            let save = savedDevices.map{ saveDevice in
                
                Device(indentify: saveDevice.mac ?? "",
                       deviceName: saveDevice.name ?? "")
                
            }
            
            testDevices.append(contentsOf: save)
            
            return testDevices
        }
        
    }
}
