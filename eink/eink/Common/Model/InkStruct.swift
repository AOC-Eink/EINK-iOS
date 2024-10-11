//
//  InkStruct.swift
//  eink
//
//  Created by Aaron on 2024/9/22.
//

import Foundation
import SwiftUI

struct InkStyle {
    let itemWidth:CGFloat
    let panelHeight:CGFloat
    let cornerRadius: CGFloat
    let borderWidth: CGFloat
    let borderColor: Color
    let heightRatio: CGFloat
    let isCircle: Bool
    let presetSize: CGFloat
    
    init(itemWidth: CGFloat, 
         panelHeight: CGFloat,
         cornerRadius: CGFloat,
         borderWidth: CGFloat,
         borderColor: Color,
         heightRatio: CGFloat,
         presetSize: CGFloat,
         isCircle: Bool = false
         
    ) {
        self.itemWidth = itemWidth
        self.panelHeight = panelHeight
        self.cornerRadius = cornerRadius
        self.borderWidth = borderWidth
        self.borderColor = borderColor
        self.heightRatio = heightRatio
        self.isCircle = isCircle
        self.presetSize = presetSize
    }
}
