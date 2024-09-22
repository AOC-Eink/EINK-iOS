//
//  DIYPanel.swift
//  eink
//
//  Created by Aaron on 2024/9/15.
//

import SwiftUI

struct DIYPanel: View {
    
    let colors: [(name: String, hex: String)]
    let onTouch:((String?)->Void)
    let onSave:(Bool)->Void
    let onEmploy:()->Void
    
    @State private var inputText = ""
    
    @State private var selectColor:String?
    
    @State private var isFavorite:Bool = false
    
    var body: some View {
        VStack(alignment:.leading) {
            HStack(alignment:.top) {
                CustomTextField(placeholder: "Name your design ", text: $inputText)
                    .padding(.top)
                    .padding(.leading)
                FavoriteButton(isSelect: $isFavorite)
            }
            .padding(.bottom, 5)
         
            Text("DIY Color")
                .font(.sectionBoldTitle)
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
                    onSave(isFavorite)
                }
                
                CustomButton(title: "Employ") {
                    onEmploy()
                }
            }
            .padding(.bottom, 10)
            
            
            
        }
        .padding(.horizontal, 30)

        .background(.white)
        .cornerRadius(50, corners: [.topLeft, .topRight])
        .shadow(color: .deviceItemShadow, radius: 5, x: 1, y: -5)
        .aspectRatio(3/2, contentMode: .fit)
//        .toolbar {
//            ToolbarItem(placement: .bottomBar) {
//                // 隐藏 TabBar 的占位符
//                Color.clear.frame(height: 0)
//            }
//        }
        
    }
    
}

#Preview {
    DIYPanel(colors: [
            ("green", "497A64"),
            ("yellow", "DFBE24"),
            ("blue", "2B78B9"),
            ("black", "3F384A"),
            ("red", "A45942")
    ], onTouch: {_ in}, onSave: { _ in}, onEmploy: {})
}
