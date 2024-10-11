//
//  PresetView.swift
//  eink
//
//  Created by Aaron on 2024/9/9.
//

import SwiftUI

struct PresetView: View {
    @Environment(\.displayScale) var displayScale
    let colors:String
    let hGrids:Int
    let vGrides:Int
    let heightRatio:CGFloat
    let inkStyle:InkStyle
    let itemWidth:CGFloat
    
    var hexColors:[String] {
        colors.components(separatedBy: ",")
    }
    
    var triangleSize: CGFloat {
        let baseWidth: CGFloat = itemWidth
        
        switch displayScale {
        case 1:
            return baseWidth*0.5
        case 2:
            return baseWidth*0.67
        case 3:
            return baseWidth
        default:
            return baseWidth
        }
    }
    
    var body: some View {
        VStack {
            TriangleGridView(colors: hexColors,
                             columns: hGrids,
                             rows: vGrides,
                             triangleSize: triangleSize,
                             heightRatio: heightRatio,
                             onTouch: {index, isRepeat, color in
                
            })
            .roundedBorder(cornerRadius: inkStyle.cornerRadius*0.5,
                           borderWidth: inkStyle.borderWidth*0.5,
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
