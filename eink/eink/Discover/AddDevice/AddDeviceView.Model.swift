//
//  AddDeviceView.Model.swift
//  eink
//
//  Created by Aaron on 2024/9/27.
//

import Foundation

extension AddDeviceView {
    
    @Observable
    class Model {
        
        enum AddStatus {
            case scan
            case scanNone
            case descovered
            case select
            case adding
            case addSuccess
            case addFail
        }
        
        var addStatus:AddStatus = .scanNone
        
        var discoverDevices:[String] {
            ["E-INK Phone Case","E-INK Clock","E-INK Headphones","E-INK Speakers", "E-INK Monitor"]
        }
        
    }
}
