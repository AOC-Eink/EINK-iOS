//
//  DeviceCommand.swift
//  eink
//
//  Created by Aaron on 2024/10/12.
//

import Foundation

extension Device {
    
    var initCommand:[UInt8] {
        switch deviceType {
        case .clock:
            return Array.init(repeating: 0x00, count: 64)
        case .phoneCase:
            return Array.init(repeating: 0x00, count: 64)
        case .speaker:
            return Array.init(repeating: 0x00, count: 128)
        }
    }
    //-1 代表 0x21  -2 代表 0x00
    var commanOrder:[Int] {
        switch deviceType {
        case .clock:
            return Array.init(repeating: 0x00, count: 64)
        case .phoneCase:
            return Array.init(repeating: 0x00, count: 64)
        case .speaker:
            return [
                    -1,85,86,87,88,89,90,91,
                    92,93,94,95,96,97,98,99,
                    100,101,68,69,70,71,72,73,
                    74,75,76,77,78,79,80,81,
                    82,83,84,51,52,53,54,55,
                    56,57,58,59,60,61,62,63,
                    64,65,66,67,34,35,36,37,
                    38,39,40,41,42,43,44,-2,
                     
                    45,46,47,48,49,50,17,18,
                    19,20,21,22,23,24,25,26,
                    27,28,29,30,31,32,33,0,
                    1,2,3,4,5,6,7,8,
                    9,10,11,12,13,14,15,
                    16,-2,-2,-2,-2,-2,-2,-2,
                    -2,-2,-2,-2,-2,-2,-2,-2,
                    -2,-2,-2,-2,-2,-2,-2,-1,
            ]
        }
    }
    
    func formMCUCommand(colors:[UInt8]) -> [UInt8] {
        
        return commanOrder.map{
            if $0 == -1 {
                return 0x21
            }
            if $0 == -2 {
                return 0x00
            }
            if $0 >= colors.count {
                return 0x00
            }
            return colors[$0]
        }
        
    }
    
}

////多色竖条    5
//    0x21,0x05,0x04,0x01,0x02,0x00,0x03,0x05,//0-7
//    0x04,0x01,0x02,0x00,0x03,0x05,0x04,0x01,//8-15
//    0x02,0x00,0x03,0x05,0x04,0x01,0x02,0x00,//16-23
//    0x03,0x05,0x04,0x01,0x02,0x00,0x03,0x05,//24-31
//    0x04,0x01,0x02,0x00,0x03,0x05,0x04,0x01,//32-39
//    0x02,0x00,0x03,0x05,0x04,0x01,0x02,0x00,//40-47
//    0x03,0x05,0x04,0x01,0x02,0x00,0x03,0x05,//48-55
//    0x04,0x01,0x02,0x00,0x03,0x05,0x04,0x00,//56-63
//    
//    0x00,0x01,0x02,0x00,0x03,0x05,0x04,0x01,//0-7
//    0x02,0x00,0x03,0x05,0x04,0x01,0x02,0x00,//8-15
//    0x03,0x05,0x04,0x01,0x02,0x00,0x03,0x05,//16-23
//    0x04,0x01,0x02,0x00,0x03,0x05,0x04,0x01,//24-31
//    0x02,0x00,0x03,0x05,0x04,0x01,0x02,0x00,//32-39
//    0x03,0x00,0x00,0x00,0x00,0x00,0x00,0x00,//40-47
//    0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,//48-55
//    0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x21,//56-63
