//
//  BLEService.swift
//  eink
//
//  Created by Aaron on 2024/10/9.
//

import Foundation

enum CommandType:UInt8 {
    case readDeviceInfo = 0x11
    case writeCmd = 0xFE
    case showCmd = 0xFF
    case sendFlag = 0x21
}

class PacketFormat {
    
    static let Identifier = 0xC5
    
    static func readDeviceInfoPacket() -> Data {
        let temp: [UInt8] = [
            UInt8(Identifier),    // identifier
            UInt8(CommandType.readDeviceInfo.rawValue), // Command-id
            0x00                    // Payload len
        ]
        return Data(temp)
    }
    
    static func playBackTest(header:UInt8, _ serial:UInt8) -> Data {
        let temp: [UInt8] = [
            UInt8(header),    // identifier
            UInt8(CommandType.showCmd.rawValue), // Command-id
            0x01,                    // Payload len
            serial
        ]
        return Data(temp)
    }
    
    static func sendColor(header:UInt8, colors:[UInt8]) -> Data {
        let temp: [UInt8] = [
            UInt8(header),    // identifier
            UInt8(CommandType.writeCmd.rawValue), // Command-id
            UInt8(colors.count),              // Payload len                // Payload
        ] + colors
        return Data(temp)
    }
    
    static func sendColors(header:UInt8, colors: [UInt8]) -> [Data] {
        var packages: [Data] = []
        
        _ = (colors.count + 19) / 20 // Ceiling division
        
        let headCommand: [UInt8] = [
            UInt8(header),    // identifier
            UInt8(CommandType.writeCmd.rawValue), // Command-id
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
            UInt8(CommandType.sendFlag.rawValue), // Command-id
            UInt8(colors.count)
        ]
        
        packages.append(Data(endCommand))
        
        return packages
    }
    
}

