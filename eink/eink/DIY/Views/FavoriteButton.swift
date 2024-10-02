//
//  FavoriteButton.swift
//  eink
//
//  Created by Aaron on 2024/9/15.
//

import SwiftUI

struct FavoriteButton: View {
    
    let initState:Bool
    @Binding var isSelect:Bool
    var onTouch:((Bool)->Void)?
    
    var bgImage:String {
        isSelect||initState ? "favorite.bg.active":"favorite.bg.normal"
    }
    
    var starImage:String {
        isSelect||initState ?  "favorite.star.active":"favorite.star.normal"
    }
    
    var body: some View {
        
        Button(action: {
            isSelect.toggle()
            onTouch?(isSelect)
        }, label: {
            ZStack {
                Image(bgImage)
                    .resizable()
                    .scaledToFit()
                Image(starImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20)
                    .padding(.top, -10)
            }
            .frame(width: 43, height: 52)
        })
        
    }
}

#Preview {
    FavoriteButton(initState: true, isSelect: .constant(false))
}
