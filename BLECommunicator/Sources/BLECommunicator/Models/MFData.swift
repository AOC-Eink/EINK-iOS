//
//  File.swift
//  
//
//  Created by Aaron on 2024/10/1.
//

import Foundation

struct MFData {
    var vid: Int = 0
    var pid: Int = 0
    var mid: Int = 0
    var scrValue: UInt = 0
    var scrValue2: UInt = 0
    
    
    init(_ data: Data) {
        guard data.count < 4 else {
            return
        }
        
        // Parse VID (Vendor ID)
        let vidData = data.prefix(2)
        self.vid = Int(vidData.withUnsafeBytes { $0.load(as: UInt16.self) })
        
        // Parse PID (Product ID)
        let pidData = data[2..<4]
        self.pid = Int(pidData.withUnsafeBytes { $0.load(as: UInt16.self) })
        
        // Parse MID (Model ID)
        self.mid = Int(data[4])
        
        // Parse SCR State
        let scrData = data[5..<7]
        self.scrValue = UInt(scrData.withUnsafeBytes { $0.load(as: UInt16.self) })
        
        // Parse Second SCR State
        let scrData2 = data[7..<9]
        self.scrValue2 = UInt(scrData2.withUnsafeBytes { $0.load(as: UInt16.self) })
    }
}

//extension BLECommunicator {
//    func parseManufacturerData(_ data: Data) -> MFData {
//        var mf = MFData()
//        
//        // Parse VID (Vendor ID)
//        let vidData = data.prefix(2)
//        mf.vid = Int(vidData.withUnsafeBytes { $0.load(as: UInt16.self) })
//        
//        // Parse PID (Product ID)
//        let pidData = data[2..<4]
//        mf.pid = Int(pidData.withUnsafeBytes { $0.load(as: UInt16.self) })
//        
//        // Parse MID (Model ID)
//        mf.mid = Int(data[4])
//        
//        // Parse SCR State
//        let scrData = data[5..<7]
//        mf.scrValue = UInt(scrData.withUnsafeBytes { $0.load(as: UInt16.self) })
//        
//        // Parse Second SCR State
//        let scrData2 = data[7..<9]
//        mf.scrValue2 = UInt(scrData2.withUnsafeBytes { $0.load(as: UInt16.self) })
//        
//        return mf
//    }
//}
