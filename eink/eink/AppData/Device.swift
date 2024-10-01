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
    
    
    var presetImages:Array<String> {
        switch self {
        case .clock:
            return [
                "preset.clock.strips",
                "preset.clock.cube",
                "preset.clock.graphics",
                "preset.clock.club.a",
                "preset.clock.club.b"
                
            ]
            
        case .phoneCase:
            return [
                "preset.case.letter.o",
                "preset.case.letter.e",
                "preset.case.letter.q",
                "preset.case.letter.f",
                "preset.case.stripe.a",
                "preset.case.geometry.b",
                "preset.case.geometry.b"
                
            ]
        }
    }
    
    var guideImage:Array<String> {
        switch self {
        case .clock:
            return [
                "device.clock.slide.guide",
                "device.case.slide.guide",
            ]
            
        case .phoneCase:
            return [
                "device.case.slide.guide",
                "device.clock.slide.guide",
            ]
        }
    }
    
    var presetDesigns:Dictionary<String,String> {
        switch self {
        case .clock:
            return [
                "Clock": """
                    DFBE24,3F384A,497A64,A45942,2B78B9,DFBE24,A45942,
                    2B78B9,497A64,A45942,3F384A,DFBE24,A45942,3F384A,
                    A45942,3F384A,2B78B9,497A64,A45942,DFBE24,497A64,
                    497A64,DFBE24,3F384A,A45942,2B78B9,DFBE24,A45942,
                    DFBE24,2B78B9,497A64,DFBE24,A45942,3F384A,2B78B9,
                    A45942,DFBE24,3F384A,2B78B9,497A64,2B78B9,DFBE24,
                    497A64,A45942,3F384A,DFBE24,A45942,2B78B9,497A64
                    """,
                "Digtal": """
                    3F384A,497A64,A45942,DFBE24,2B78B9,A45942,3F384A,
                    DFBE24,A45942,3F384A,497A64,DFBE24,2B78B9,A45942,
                    2B78B9,497A64,DFBE24,3F384A,A45942,2B78B9,497A64,
                    A45942,2B78B9,DFBE24,497A64,3F384A,DFBE24,A45942,
                    DFBE24,3F384A,497A64,A45942,2B78B9,DFBE24,3F384A,
                    497A64,A45942,DFBE24,2B78B9,3F384A,A45942,2B78B9,
                    A45942,DFBE24,2B78B9,497A64,3F384A,A45942,497A64
                    """
            ]
            
        case .phoneCase:
            return [
                "Letter E": """
                    DFBE24,DFBE24,DFBE24,DFBE24,3F384A,3F384A,3F384A,3F384A,DFBE24,DFBE24,DFBE24,DFBE24,3F384A,3F384A,3F384A,3F384A,
                    DFBE24,DFBE24,DFBE24,DFBE24,3F384A,3F384A,3F384A,3F384A,DFBE24,DFBE24,DFBE24,DFBE24,3F384A,3F384A,3F384A,3F384A,
                    DFBE24,DFBE24,DFBE24,DFBE24,3F384A,3F384A,3F384A,3F384A,DFBE24,DFBE24,DFBE24,DFBE24,3F384A,3F384A,3F384A,3F384A,
                    DFBE24,DFBE24,DFBE24,DFBE24,3F384A,3F384A,3F384A,3F384A,DFBE24,DFBE24,DFBE24,DFBE24,3F384A,3F384A,3F384A,3F384A
                    """,
                "Cube": """
                    3F384A,3F384A,3F384A,3F384A,3F384A,3F384A,497A64,497A64,3F384A,3F384A,497A64,497A64,3F384A,3F384A,3F384A,3F384A,
                    3F384A,3F384A,3F384A,497A64,497A64,497A64,497A64,497A64,497A64,497A64,497A64,497A64,497A64,497A64,3F384A,3F384A,
                    3F384A,3F384A,497A64,497A64,497A64,497A64,A45942,A45942,497A64,497A64,497A64,497A64,497A64,497A64,3F384A,3F384A,
                    3F384A,3F384A,3F384A,3F384A,3F384A,3F384A,497A64,497A64,3F384A,3F384A,3F384A,3F384A,3F384A,3F384A,3F384A,3F384A
                    """
            ]
        }
        
    }
    
    var shape:Array<Int> {
        switch self {
        case .clock:
            return [6,9]
            
        case .phoneCase:
            return [4,16]
        }
    }
    
}

struct Device:Hashable, Equatable {
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
            hasher.combine(status)
            hasher.combine(deviceImage)
        }
    
    static func == (lhs: Device, rhs: Device) -> Bool {
        return lhs.indentify == rhs.indentify &&
               lhs.deviceName == rhs.deviceName &&
               lhs.status == rhs.status &&
               lhs.deviceImage == rhs.deviceImage
    }
    
    var dbDesigns: [InkDesign] = []
    
    
    var status:String = "Unconnected"
    
    var deviceImage:String {
        switch deviceType {
        case .clock:
            return "eink.clock.device"
        case .phoneCase:
            return "eink.case.device"
        }
    }
    
    var favoriteDesigns: [InkDesign] {
        dbDesigns.filter { $0.favorite }
    }
    
    mutating func getDBDesgins(designs:[InkDesign]) {
        dbDesigns = designs
    }
    
    var deviceType:DeviceType {
        if deviceName.contains("Case") {
            return .phoneCase
        }
        
        if deviceName.contains("Clock") || bleDevice?.pid == 0x4E61 {
            return .clock
        }
        
        return .clock
    }
    
    var gridLayout:[GridItem] {
        if deviceName.contains("Case") {
            return [GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())]
        }
        
        if deviceName.contains("Clock") {
            return [GridItem(.flexible()),
                    GridItem(.flexible())]
        }
        
        return [GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())]
    }
    
    var inkStyle:InkStyle {
        switch deviceType {
            case .phoneCase:
                return InkStyle(itemWidth: 50,
                                panelHeight: panelHeight(50,64),
                                cornerRadius: 20,
                                borderWidth: 0,
                                borderColor: .clear,
                                heightRatio: 1.0)
                
            case .clock:
                return InkStyle(itemWidth: 50,
                                panelHeight: panelHeight(50,54),
                                cornerRadius: panelHeight(50,54) * 0.5,
                                borderWidth: 4,
                                borderColor: .white,
                                heightRatio: 0.725,
                                isCircle: true
                )
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
        }
    }
    
    var inkCounts:Int {
        deviceType.shape[0] * deviceType.shape[1]
    }
    
}




