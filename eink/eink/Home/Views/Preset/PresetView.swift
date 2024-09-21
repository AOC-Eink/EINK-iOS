//
//  PresetView.swift
//  eink
//
//  Created by Aaron on 2024/9/9.
//

import SwiftUI

struct PresetView: View {
    let colors:String
    let hGrids:Int
    let vGrides:Int
    
    var hexColors:[String] {
        colors.components(separatedBy: ",")
    }
    
    var body: some View {
        VStack {
            TriangleGridView(colors: hexColors, columns: hGrids, rows: vGrides, triangleSize: 25, onTouch: {index, isRepeat, color in
            })
            .clipCornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(.deviceItemShadow, lineWidth: 1)
            )
            .shadow(color: .deviceItemShadow, radius: 5, x: 2, y: 2)
        }
    }
}

#Preview {
    PresetView(colors: "", hGrids: 4, vGrides: 4)
}
