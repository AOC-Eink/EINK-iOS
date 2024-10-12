//
//  File.swift
//  
//
//  Created by Aaron on 2024/10/1.
//

import Foundation

struct MFData {
    var vid: UInt16 = 0
    var pid: UInt16 = 0
    var mid: UInt8 = 0
    var scrValue: UInt16 = 0
    var scrValue2: UInt16 = 0
    
    init(_ data: Data) {
        guard data.count >= 5 else {
            return
        }
        
        self.vid = UInt16(data[0]) | (UInt16(data[1]) << 8)
        self.pid = UInt16(data[2]) | (UInt16(data[3]) << 8)
        self.mid = data[4]
        
        if data.count >= 7 {
            self.scrValue = UInt16(data[5]) | (UInt16(data[6]) << 8)
        }
        
        if data.count >= 9 {
            self.scrValue2 = UInt16(data[7]) | (UInt16(data[8]) << 8)
        }
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
