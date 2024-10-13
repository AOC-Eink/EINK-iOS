//
//  Device.swift
//  eink
//
//  Created by Aaron on 2024/9/6.
//

import Foundation
import Combine
import SwiftUI
import BLECommunicator

enum ConnectStatus {
    case unConnected
    case conected
    
}

enum DeviceType {
    case clock
    case phoneCase
    case speaker
    

    
    var guideImage:Array<String> {
        switch self {
        case .clock:
            return [
                "device.clock.slide.guide",
            ]
            
        case .phoneCase:
            return [
                "device.case.slide.guide",
            ]
        case .speaker:
            return [
                "device.speaker.slide",
            ]
        }
    }
    

    
    var shape:Array<Int> {
        switch self {
        case .clock:
            return [6,9]
            
        case .phoneCase:
            return [4,16]
        case .speaker:
            return [6,17]
        }
    }
    
}

enum DeviceStatus {
    case disconnected
    case connecting
    case discovered
    case connected
    
    var statusName:String {
        switch self {
        case .connecting:
            return "Connecting"
        case .disconnected:
            return "Disconnected"
        case .discovered:
            return "Discovered"
        case .connected:
            return "Connected"
        }
    }
    
    var statusBg:Color {
        switch self {
        case .connecting:
            return .opButton
        case .disconnected:
            return .deviceStatusDisconnected
        case .discovered:
            return .white
        case .connected:
            return .deviceStatusConnected
        }
    }
}
struct PresetDesign:Codable {
    let name:String
    let category:String
    let colors:String
    
    enum CodingKeys: String, CodingKey {
        case name
        case category
        case colors
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? "Untitled"
        category = try container.decodeIfPresent(String.self, forKey: .category) ?? ""
        colors = try container.decodeIfPresent(String.self, forKey: .colors) ?? ""
    }
    
}

struct Device:Hashable, Equatable {
    var id: String { indentify }
    let indentify:String
    let deviceName:String
    var bleDevice:BLEDevice?
    var deviceFuction: BLEDataService?
    init(indentify: String,
         deviceName: String,
         bleDevice:BLEDevice? = nil,
         deviceFunction: BLEDataService? = nil) {
        self.indentify = indentify
        self.deviceName = deviceName
        
        if (deviceFunction != nil) {
            self.deviceFuction = deviceFunction
        }
        
        if (bleDevice != nil) {
            self.bleDevice = bleDevice
        }
    }
    
    
    
    func hash(into hasher: inout Hasher) {
            hasher.combine(indentify)
            hasher.combine(deviceName)
            hasher.combine(dbDesigns)
            hasher.combine(deviceImage)
        }
    
    static func == (lhs: Device, rhs: Device) -> Bool {
        return lhs.indentify == rhs.indentify &&
               lhs.deviceName == rhs.deviceName &&
               lhs.dbDesigns == rhs.dbDesigns &&
               lhs.deviceImage == rhs.deviceImage
    }
    
    var dbDesigns: [InkDesign] = []
    
//    mutating func updateStatus(_ status:String) {
//        self.bleStatus = status
//    }
    
    var bleStatus:DeviceStatus {
        guard let bleDevice = self.bleDevice else {
            return .disconnected
        }
        
        switch bleDevice.peripheral.state {
            
        case .disconnected:
            return .discovered
        case .connecting:
            return .discovered
        case .connected:
            return .connected
        case .disconnecting:
            return .disconnected
        @unknown default:
            return .disconnected
        }
    }
    
    var deviceImage:String {
        switch deviceType {
        case .clock:
            return "eink.clock.device"
        case .phoneCase:
            return "eink.case.device"
        case .speaker:
            return "eink.device.speaker"
        }
    }
    
    var favoriteDesigns: [InkDesign] {
        dbDesigns.filter { $0.favorite }
    }
    
    mutating func getDBDesgins(designs:[InkDesign]) {
        dbDesigns = designs
    }
    
    var devicePidString:String {
        switch deviceType {
            
        case .clock:
            return "4E61"
            
        case .phoneCase:
            return "4E62"
            
        case .speaker:
            return "4E63"
        }
    }
    
    var deviceType:DeviceType {
        if deviceName.contains("Case") || bleDevice?.pid == 0x4E61 || bleDevice?.pid == 0x4E62 {
            return .phoneCase
        }
        
        if deviceName.contains("Clock") && bleDevice?.pid == 0x4E65 {
            return .clock
        }
        
        if deviceName.contains("Speaker") || bleDevice?.pid == 0x4E63 {
            return .speaker
        }
        
        return .clock
    }
    
    var commandHeader:UInt8 {
        switch deviceType {
            
        case .clock:
            return 0xC5
            
        case .phoneCase:
            return 0xCF
            
        case .speaker:
            return 0xC5
        }
    }
    
    var gridLayout:[GridItem] {
        switch deviceType {
            
        case .clock:
            return [GridItem(.flexible()),
                    GridItem(.flexible())]
            
        case .phoneCase:
            return [GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())]
        case .speaker:
            return [GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())]
        }
    }
    
    var inkStyle:InkStyle {
        switch deviceType {
            case .phoneCase:
                return InkStyle(itemWidth: 50,
                                panelHeight: panelHeight(50,64),
                                cornerRadius: 35,
                                borderWidth: 5,
                                borderColor: .caseBorderWhite,
                                heightRatio: 1.0, presetSize: 25)
                
            case .clock:
                return InkStyle(itemWidth: 50,
                                panelHeight: panelHeight(50,54),
                                cornerRadius: panelHeight(50,54) * 0.5,
                                borderWidth: 4,
                                borderColor: .white,
                                heightRatio: 0.725, presetSize: 25,
                                isCircle: true
                )
            case .speaker:
                return InkStyle(itemWidth: 40,
                            panelHeight: panelHeight(40,102),
                            cornerRadius: 28,
                            borderWidth: 5,
                            borderColor: .caseBorderWhite,
                                heightRatio: 1.0, presetSize: 15)
        }
    }
    
    var panelHeight:(Int, CGFloat) -> CGFloat {
        return { rows, itemWidth in
            let triangleHeight = (2 * itemWidth) / sqrt(3)
            let offsetY = (triangleHeight/2.0) - 0.7
            let totalHeight = CGFloat(rows) * triangleHeight - offsetY * CGFloat(rows - 1)
            
            return totalHeight - triangleHeight*heightRatio
        }
    }
    
    var heightRatio:CGFloat {
        switch deviceType {
        case .phoneCase:
            return 1.0
            
        case .clock:
            return 0.725
        case .speaker:
            return 1.0
        }
    }
    
    var inkCounts:Int {
        deviceType.shape[0] * deviceType.shape[1]
    }
    
}




