//
//  Device.swift
//  eink
//
//  Created by Aaron on 2024/9/6.
//

import Foundation
import Combine
import SwiftUI

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

struct Device: Equatable, Hashable {
    
    let indentify:String
    let deviceName:String
    
    
    var status:String = "Unconnected"
    var deviceImage:String = ""
    
    var deviceType:DeviceType {
        if deviceName.contains("Case") {
            return .phoneCase
        }
        
        if deviceName.contains("Clock") {
            return .clock
        }
        
        return .phoneCase
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
    
}

@Observable class DeviceManager {

    var devices:Array<Device> = []
    
    
    
    
    init() {
        devices = createModalDevices()
    }
    
    
    func createModalDevices() -> [Device] {

        return [
            Device(indentify: "AA:BB:CC:DD",
                   deviceName: "E-INK Phone Case",
                   status: "Unconected",
                   deviceImage: "eink.case.device"),
            
            Device(indentify: "EE:FF:GG:HH",
                   deviceName: "E-INK Clock",
                   status: "Unconected",
                   deviceImage: "eink.clock.device")
        ]
        
    }
    
}


