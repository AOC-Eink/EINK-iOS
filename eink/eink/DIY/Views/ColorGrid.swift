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
    let onTouch:((String)->Void)
    
    
    
    var textColor:String {
        selectColor == color ? "000000":"686868"
    }
    
    var body: some View {
        VStack(spacing:10) {
            Button {
                onTouch(color)
            } label: {
                Color.init(hex: color)
            }
            .aspectRatio(1.0, contentMode: .fit)
            
            Text(name)
                .font(.contentTitle)
                .foregroundStyle(Color.init(hex: textColor))
            
            
        }
    }
}

#Preview {
    ColorGrid(name: "green", color: "497A64", selectColor: "", onTouch: {_ in})
}
