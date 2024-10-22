//
//  PresetCard.swift
//  eink
//
//  Created by Aaron on 2024/9/9.
//

import SwiftUI

struct PresetCard: View {
    
    let title:String
    let pageType:PageType
    let design:Design
    let presetView: PresetView?
    let ratio:CGFloat = 1.0
    @State var showPopover = false
    @State private var isSelected:Bool = false
    @Environment(\.selectDesign) private var selectDesign
    
    var onTouch:((EditAction)->Void)?
    
    var actions:[EditAction] {
        switch pageType {
        case .preset:
            return [.apply, .edit, .favorite, .delete]
        case .custom:
            return [.apply, .edit, .favorite, .delete]
        case .category:
            return [.apply, .favorite]
        case .favorite:
            return [.apply, .favorite]
        case .select:
            return []
        }
    }
    
    var body: some View {
        ZStack(alignment:.topLeading) {
            VStack(alignment:.center, spacing: 10){
                    
                if (presetView != nil) {
                    presetView
                        .allowsHitTesting(false)
                }
                
                Text(title)
                    .font(.deviceCount)
                    .foregroundStyle(.sectionTitle)
            }
            if pageType == .select {
                
                //isSelected ? Color.selectCover : .clear
                
                Image(systemName: isSelected ? "checkmark.circle.fill":"checkmark.circle")
                    .resizable()
                    .frame(width: 28, height: 28)
                    .foregroundStyle(isSelected ? .opButton : .deviceItemShadow)
                
                
                
            }
            
        }
        
        .background(Color.white) // 设置背景色
        
        .onTapGesture {
            if actions.isEmpty { 
                isSelected.toggle()
                
                selectDesign(design,isSelected)
                
            } else {
                showPopover.toggle()
            }
        }

        .popover(isPresented: $showPopover, content: {
            EditPopverMenu(showPopover: $showPopover, actions: actions, onTouch: onTouch)
                .presentationCompactAdaptation(.popover)
        })
    }
}

//#Preview {
//    PresetCard(title: "Clock", pageType: .favorite, design: <#Design#>, presetView: nil)
//}
