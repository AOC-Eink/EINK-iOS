//
//  DIYView.swift
//  eink
//
//  Created by Aaron on 2024/9/15.
//

import SwiftUI

struct DIYView: View {
    
    let device:Device
    
    @State var colors:[String] = Array(repeating: "FFFFFF", count: 63)
    
    @State private var selectIndex:Int?
    
    var body: some View {
        VStack(spacing:30){
            
            
            TriangleGridView(colors: colors, columns: 4, rows: 16, triangleSize: 50, onTouch: {index in
                selectIndex = index
            })
                .clipCornerRadius(20)

                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(.deviceItemShadow, lineWidth: 1)
                )
                .shadow(color: .deviceItemShadow, radius: 5, x: 2, y: 2)

            
            DIYPanel(colors:  [
                ("green", "497A64"),
                ("yellow", "DFBE24"),
                ("blue", "2B78B9"),
                ("black", "3F384A"),
                ("red", "A45942")
            ], onTouch: { color in
                print("color : \(color)")
                if (selectIndex != nil) {
                    colors[selectIndex ?? 0] = color
                    
                }
            })
            
        }
        .background(.white)
    }
}

#Preview {
    DIYView(device: DeviceManager().devices.first!)
}
