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
        
        init(_ savedDevices: [InkDevice]) {
            self.savedDevices = savedDevices
        }
        
        var deviceList:[Device] {
            let save = savedDevices.map{ saveDevice in
                
                Device(indentify: saveDevice.mac ?? "",
                       deviceName: saveDevice.name ?? "")
                
            }
            
            return save
        }
        
    }
}
