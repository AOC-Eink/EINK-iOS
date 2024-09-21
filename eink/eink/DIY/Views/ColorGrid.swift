//
//  ColorGrid.swift
//  eink
//
//  Created by Aaron on 2024/9/15.
//

import SwiftUI

struct ColorGrid: View {
    
    let name:String
    let color:String
    let selectColor:String
    let onTouch:((String?)->Void)
    
    
    var textColor:String {
        isSelected  ? "000000":"686868"
    }
    
    var isSelected:Bool {
        selectColor == color
    }
    
    var body: some View {
        VStack(spacing:10) {
            Button {
                if isSelected {
                    onTouch(nil)
                } else {
                    onTouch(color)
                }
            } label: {
                Color.init(hex: color)
            }
            .aspectRatio(1.0, contentMode: .fit)
            .scaleEffect(isSelected ? 1.2 : 1)
            .shadow(color: isSelected ? .deviceItemShadow : .clear , radius: 5, x: 2, y: 2)
            
            Text(name)
                .font(isSelected ? .contentBoldTitle : .contentTitle)
                .foregroundStyle(Color.init(hex: textColor))
        }
        .zIndex(isSelected ? 1 : 0)
        .animation(.easeInOut, value: isSelected)
    }
}

#Preview {
    ColorGrid(name: "green", color: "497A64", selectColor: "", onTouch: {_ in})
}
