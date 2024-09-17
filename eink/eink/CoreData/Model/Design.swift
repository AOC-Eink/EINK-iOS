//
//  Design.swift
//  eink
//
//  Created by Aaron on 2024/9/14.
//

import Foundation

struct Design:Codable, Equatable, Hashable {

    let vGrids:Int
    let hGrids:Int
    let colorMap:Array<InkColor>
    
}


struct InkColor:Codable, Equatable, Hashable {
    let red:Int
    let green:Int
    let blue:Int
}
