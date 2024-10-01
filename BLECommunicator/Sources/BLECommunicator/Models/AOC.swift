//
//  File.swift
//  
//
//  Created by Aaron on 2024/10/1.
//

import Foundation
import CoreBluetooth

struct AOCMF {
    static let vid = 0xFFFF
    
    static var AocUUID:CBUUID {
        let uuid = "00001800-0000-1000-8000-00805F9B34FB"
        return CBUUID.init(string: uuid)
    }
    
    static var originServicesUUID:CBUUID {
        let uuid = "65786365-6c70-6f69-6e74-2e636f6d0000"
        return CBUUID.init(string: uuid)
    }
    
    static var RXCharacteristicsUUID:CBUUID {
        let uuid = "65786365-6c70-6f69-6e74-2e636f6d0001"
        return CBUUID.init(string: uuid)
    }
    
    static var TXCharacteristicsUUID:CBUUID {
        let uuid = "65786365-6c70-6f69-6e74-2e636f6d0002"
        return CBUUID.init(string: uuid)
    }
    
    
}
