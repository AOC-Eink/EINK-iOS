//
//  BLEService.swift
//  eink
//
//  Created by Aaron on 2024/10/9.
//

import Foundation

enum CommandType:UInt8 {
    case readDeviceInfo = 0x11
    case sendColors = 0x12
    case sendColorsEnd = 0x20
}

class PacketFormat {
    
    static let Identifier = 0xAD
    
    static func readDeviceInfoPacket() -> Data {
        var temp: [UInt8] = [
            UInt8(Identifier),    // identifier
            UInt8(CommandType.readDeviceInfo.rawValue), // Command-id
            0x00                    // Payload len
        ]
        return Data(temp)
    }
    
    static func sendColors(colors: [UInt8]) -> [Data] {
        var packages: [Data] = []
        
        let packagesCount = (colors.count + 19) / 20 // Ceiling division
        
        let headCommand: [UInt8] = [
            UInt8(Identifier),    // identifier
            UInt8(CommandType.sendColors.rawValue), // Command-id
            UInt8(colors.count)   // Payload len
        ]
        
        // 1. First package: message header command + first 20 colors
        var firstPackage = Data(headCommand)
        firstPackage.append(contentsOf: colors.prefix(20))
        packages.append(firstPackage)
        
        // Subsequent packages: 20 colors each, last package may be smaller
        for i in stride(from: 20, to: colors.count, by: 20) {
            let endIndex = min(i + 20, colors.count)
            let colorChunk = colors[i..<endIndex]
            packages.append(Data(colorChunk))
        }
        
        let endCommand: [UInt8] = [
            UInt8(Identifier),    // identifier
            UInt8(CommandType.sendColorsEnd.rawValue), // Command-id
            UInt8(colors.count)
        ]
        
        packages.append(Data(endCommand))
        
        return packages
    }
    
}

