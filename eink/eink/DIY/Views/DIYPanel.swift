//
//  DIYPanel.swift
//  eink
//
//  Created by Aaron on 2024/9/15.
//

import SwiftUI

struct DIYPanel: View {
    
    let colors: [(name: String, hex: String)]
    let onTouch:((String)->Void)
    
    @State private var selectColor:String?
    
    var body: some View {
        VStack(alignment:.leading) {
            HStack {
                Spacer()
                FavoriteButton()
            }.padding(.horizontal)
            
            Text("DIY Color")
                .font(.sectionTitle)
                .foregroundStyle(.sectionTitle)
            
            HStack(spacing:1) {
                ForEach(colors.indices, id: \.self) { index in
                    ColorGrid(name: colors[index].name, 
                              color: colors[index].hex,
                              selectColor: selectColor ?? "",
                              onTouch: {
                        color in
                        selectColor = color
                        onTouch(color)
                    })
                }
                Color.white
                    .frame(width: 30)
                ColorGrid(name: "off", 
                          color: "DBDBDB",
                          selectColor: selectColor ?? "",
                          onTouch:  {
                    color in
                    selectColor = color
                    onTouch(color)
                })
            }
            .frame(maxWidth: .infinity)
            
            
            HStack(spacing:50) {
                
                CustomButton(title: "Save") {
                    
                }
                
                CustomButton(title: "Employ") {
                    
                }
            }
            .padding(.bottom, 10)
            
            
            
        }
        .padding(.horizontal, 30)

        .background(.white)
        .cornerRadius(50, corners: [.topLeft, .topRight])
        .shadow(color: .deviceItemShadow, radius: 5, x: 1, y: -5)
        .aspectRatio(3/2, contentMode: .fit)
        
        
    }
}

#Preview {
    DIYPanel(colors: [
            ("green", "497A64"),
            ("yellow", "DFBE24"),
            ("blue", "2B78B9"),
            ("black", "3F384A"),
            ("red", "A45942")
        ], onTouch: {_ in})
}
