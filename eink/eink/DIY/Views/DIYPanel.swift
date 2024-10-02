//
//  DIYPanel.swift
//  eink
//
//  Created by Aaron on 2024/9/15.
//

import SwiftUI

struct DIYPanel: View {
    
    let colors: [(name: String, hex: String)]
    let name:String
    let initFavorite:Bool
    let onTouch:((String?)->Void)
    let onSave:(Bool, String)->Void
    let onEmploy:()->Void
    
    var diyColors:[(name: String, hex: String)] {
        Array(colors.prefix(upTo: colors.count - 1))
    }
    
    var offColor:(name: String, hex: String) {
        colors.last ?? (name:"off", hex:"DBDBDB")
    }
    
    @State private var inputText = ""
    
    @State private var selectColor:String?
    
    @State private var isFavorite:Bool = false
    
    @EnvironmentObject var alertManager: AlertManager
    
    var body: some View {
        VStack(alignment:.leading) {
            HStack(alignment:.top) {
                CustomTextField(placeholder: "Name your design ", 
                                initName: name,
                                text: $inputText)
                    .padding(.top)
                    .padding(.leading)
                FavoriteButton(initState: initFavorite, isSelect: $isFavorite)
            }
            .padding(.bottom, 5)
         
            Text("DIY Color")
                .font(.sectionBoldTitle)
                .foregroundStyle(.sectionTitle)
            
            HStack(spacing:1) {
                ForEach(diyColors.indices, id: \.self) { index in
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
                ColorGrid(name: offColor.name,
                          color: offColor.hex,
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
                    if inputText.isEmpty {
                        alertManager.showAlert(
                            message: "Name should not be empty"
                        )
                    } else {
                        onSave(isFavorite||initFavorite, inputText)
                    }
                    
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
//        .aspectRatio(3/2, contentMode: .fit)
//        .ignoresSafeArea(.keyboard)
        .frame(height: 260)
        .onAppear{
            inputText = name
        }
        
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
            ("red", "A45942"),
            ("off", "DBDBDB")
    ], name: "hello", initFavorite: true, onTouch: {_ in}, onSave: {_,_ in}, onEmploy: {})
}
