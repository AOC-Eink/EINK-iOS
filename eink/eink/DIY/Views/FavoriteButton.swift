//
//  FavoriteButton.swift
//  eink
//
//  Created by Aaron on 2024/9/15.
//

import SwiftUI

struct FavoriteButton: View {
    
    let onTouch:((Bool)->Void)
    @State private var isSelect = false
    
    init(_ initState:Bool, onTouch:@escaping (Bool)->Void){
        debugPrint("FavoriteButton init")
        
        isSelect = initState
        self.onTouch = onTouch
    }
    
    var bgImage:String {
        isSelect ? "favorite.bg.active":"favorite.bg.normal"
    }
    
    var starImage:String {
        isSelect ?  "favorite.star.active":"favorite.star.normal"
    }
    
    var body: some View {
        
        Button(action: {
            isSelect.toggle()
            onTouch(isSelect)
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
        .onAppear{
            debugPrint("FavoriteButton onAppear")
        }
        
    }
        
}

#Preview {
    FavoriteButton(true, onTouch: {_ in })
}
