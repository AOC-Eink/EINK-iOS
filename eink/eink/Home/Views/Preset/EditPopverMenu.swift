//
//  EditPopverMenu.swift
//  eink
//
//  Created by Aaron on 2024/10/2.
//

import SwiftUI

struct EditPopverMenu: View {
    @Binding var showPopover:Bool
    @State private var maxWidth:CGFloat = 0
    
    let actions:[EditAction]
    
    
    var onTouch:((EditAction)->Void)?
    

    var body: some View {
            VStack(alignment: .leading) {
                
                ForEach(actions, id: \.self) { action in
                    CustomButton(title: "\(action.titleName)",
                                 bgColor: .opButton) {
                        onTouch?(action)
                        showPopover = false
                    }
                    
                }

            }
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 2)
        }
    
    
}

struct MaxWidthPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

#Preview {
    EditPopverMenu(showPopover: .constant(true), actions: [.apply])
}
