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
    static let testVid = 0x5350
    
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
        let uuid = "FEF0"
        return CBUUID.init(string: uuid)
    }
    
    static var TestServicesUUID1:CBUUID {
        let uuid = "00010203-0405-0607-0809-0A0B0C0D1912"
        return CBUUID.init(string: uuid)
    }
    static var TestCharacteristicsUUID0:CBUUID {
        let uuid = "00010203-0405-0607-0809-0A0B0C0D2B12"//00010203-0405-0607-0809-0A0B0C0D2B12
        return CBUUID.init(string: uuid)
    }
    
    static var TestCharacteristicsUUID:CBUUID {
        let uuid = "FEF3"
        return CBUUID.init(string: uuid)
    }
    
    static var TestCharacteristicsUUID1:CBUUID {
        let uuid = "FEF1"
        return CBUUID.init(string: uuid)
    }
    
    static var TestCharacteristicsUUID2:CBUUID {
        let uuid = "FEF2"
        return CBUUID.init(string: uuid)
    }
    
}
