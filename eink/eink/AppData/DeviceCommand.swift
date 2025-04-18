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
            var initValues = Array.init(repeating: -2, count: 64)
            
            initValues[0] = -1
            initValues[32] = 2
            
            initValues[47] = 5
            
            initValues[43] = 6
            initValues[40] = 6
            initValues[38] = 6
            initValues[39] = 6
            initValues[41] = 6
            initValues[42] = 6
            initValues[44] = 6
            initValues[45] = 6
            initValues[46] = 6
            
            initValues[30] = 7
            initValues[37] = 7
            initValues[33] = 7
            initValues[28] = 7
            initValues[29] = 7
            initValues[31] = 7
            initValues[34] = 7
            initValues[35] = 7
            initValues[36] = 7

            
            
            initValues[23] = 8
            initValues[27] = 8
            initValues[22] = 8
            initValues[24] = 8
            initValues[26] = 8
            
            
            initValues[25] = 9
            initValues[1] = 10
            
            initValues[2] = 11
            initValues[4] = 11
            initValues[3] = 11
            initValues[5] = 11
            initValues[6] = 11
            
            initValues[7] = 12
            initValues[10] = 12
            initValues[8] = 12
            initValues[9] = 12
            initValues[12] = 12
            initValues[13] = 12
            
            initValues[16] = 13
            initValues[21] = 13
            initValues[14] = 13
            initValues[15] = 13
            initValues[17] = 13
            initValues[19] = 13
            initValues[20] = 13
            
            
            initValues[18] = 14
            initValues[11] = 17
            initValues[63] = -1
            
            return initValues
            
        case .phoneCase:
            
            var phoneNumbers:[Int] = [-1,
                         32,48,
                         33,49,
                         34,50,
                         35,51,
                         36,52,
                 4,20,21,37,53,5,
                 6,22,38,54,
                 7,23,39,55,
                 8,24,40,56,
                 9,25,41,57,
                 10,26,42,58,
                 11,27,43,59,
                 12,28,44,60,
                 13,29,45,61,
                 14,30,46,62,
                 15,31,47,63,
            ]
            phoneNumbers += Array.init(repeating: -2, count: 7)
            phoneNumbers.append(-1)
            
            return phoneNumbers
            
            
        case .speaker:
            var numbers:[Int] = [-1]
            for vIndex in 0..<6 {
                for hIndex in 0..<17 {
                    if hIndex + vIndex*17 == 62 || hIndex + vIndex*17 == 63 {
                        numbers.append(-2)
                    } else {
                        numbers.append(hIndex + vIndex*17)
                    }
                }
            }
            numbers += Array.init(repeating: -2, count: 22)
            numbers.append(-1)
            return numbers
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
