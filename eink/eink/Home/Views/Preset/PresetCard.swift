//
//  PresetCard.swift
//  eink
//
//  Created by Aaron on 2024/9/9.
//

import SwiftUI

struct PresetCard: View {
    
    let title:String
    let presetView: PresetView?
    let ratio:CGFloat = 1.0

    
    var body: some View {
        
        VStack(alignment:.center, spacing: 10){
            
            if (presetView != nil) {
                presetView
            }
            
            Text(title)
                .font(.deviceCount)
                .foregroundStyle(.sectionTitle)
        }
        //.padding()
        .background(Color.white) // 设置背景色
        //.padding(.all, 5)
    }
}

#Preview {
    PresetCard(title: "Clock", presetView: nil)
}
