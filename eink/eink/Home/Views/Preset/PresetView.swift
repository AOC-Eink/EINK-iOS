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
    let heightRatio:CGFloat
    let inkStyle:InkStyle
    
    var hexColors:[String] {
        colors.components(separatedBy: ",")
    }
    
    var body: some View {
        VStack {
            TriangleGridView(colors: hexColors,
                             columns: hGrids,
                             rows: vGrides,
                             triangleSize: 25,
                             heightRatio: heightRatio,
                             onTouch: {index, isRepeat, color in
                
            })
            .roundedBorder(cornerRadius: inkStyle.cornerRadius,
                           borderWidth: inkStyle.borderWidth,
                           borderColor: inkStyle.borderColor,
                           isCircle: inkStyle.isCircle)
        }
    }
}

//#Preview {
//    PresetView(colors: "", hGrids: 4, vGrides: 4, heightRatio: 1.0, inkStyle:
//                InkStyle(itemWidth: 50,
//                                panelHeight: panelHeight(50,54),
//                                cornerRadius: panelHeight(50,54) * 0.5,
//                                borderWidth: 4,
//                                borderColor: .white,
//                                heightRatio: 0.725,
//                                isCircle: true)
//}
