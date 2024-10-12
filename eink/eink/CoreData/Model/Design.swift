//
//  Design.swift
//  eink
//
//  Created by Aaron on 2024/9/14.
//

import Foundation

struct Design: Equatable, Hashable {
    let deviceId:String
    let vGrids:Int
    let hGrids:Int
    let name:String
    let colors:String
    let favorite:Bool
    let category:String
}


//struct InkColor:Codable, Equatable, Hashable {
//    let red:Int
//    let green:Int
//    let blue:Int
//}
