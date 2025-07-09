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
    @Binding var isEdit:Bool
    @Environment(\.selectDesign) private var selectDesign
    
    var onTouch:((EditAction)->Void)?
    
    var actions:[EditAction] {
        switch pageType {
        case .preset:
            return [.apply, .favorite]
        case .custom:
            return [.apply, .favorite]
        case .category:
            return [.apply, .favorite]
        case .favorite:
            return [.apply, .favorite]
        case .select:
            return []
        }
    }
    
    var body: some View {
//        ZStack(alignment:.topLeading) {
            VStack(alignment:.center, spacing: 10){
                    
                if (presetView != nil) {
                    presetView
                        .allowsHitTesting(false)
                }
                
                if isEdit {
                    Image(systemName: isSelected ? "checkmark.square.fill":"checkmark.square")
                        .resizable()
                        .frame(width: 28, height: 28)
                        .foregroundStyle(isSelected ? .philipsBlue : .deviceItemShadow)
                } else {
                    //占位height 28
                    Color.clear
                        .frame(height: 28)
                    
                }
                
//                Text(title)
//                    .font(.deviceCount)
//                    .foregroundStyle(.sectionTitle)
            }
            
            
//        }
        
        .background(Color.white) // 设置背景色
        .environment(\.triggleEdit) { isEdit in
            self.isEdit = isEdit
        }
        
        .onTapGesture {
            if isEdit {
                isSelected.toggle()
                
                selectDesign(design,isSelected)
                
            } else {
                onTouch?(.edit)
            }
//            if (isEdit) {
//                isSelected.toggle()
//                selectDesign(design,isSelected)
//                return
//            }
                
//            onTouch?(.edit)
        }
        .onLongPressGesture {
            if !actions.isEmpty {
                
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
