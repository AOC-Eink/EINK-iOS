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
    
    static var ServiceUUID:CBUUID {
        let uuid = "00002760-08C2-11E1-9073-0E8AC72E1001"
        return CBUUID.init(string: uuid)
    }
    
    static var RXCharacteristicsUUID:CBUUID {
        let uuid = "00002760-08C2-11E1-9073-0E8AC72E0002"
        return CBUUID.init(string: uuid)
    }
    
    static var TXCharacteristicsUUID:CBUUID {
        let uuid = "00002760-08C2-11E1-9073-0E8AC72E0001"
        return CBUUID.init(string: uuid)
    }
    
    
    static var originServicesUUID:CBUUID {
        let uuid = "00002760-08C2-11E1-9073-0E8AC72E1001"
        return CBUUID.init(string: uuid)
    }
    
    static var TestServicesUUID:CBUUID {
        let uuid = "00002760-08C2-11E1-9073-0E8AC72E1001"
        return CBUUID.init(string: uuid)
    }
    
    static var TestCharacteristicsUUID:CBUUID {
        let uuid = "00002760-08C2-11E1-9073-0E8AC72E1001"
        return CBUUID.init(string: uuid)
    }
    
}
