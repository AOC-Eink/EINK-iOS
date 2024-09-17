//
//  SliderView.swift
//  eink
//
//  Created by Aaron on 2024/9/11.
//

import SwiftUI

struct SliderView: View {
    let images: [String]
    @State private var currentIndex = 0
    
    var body: some View {
        TabView(selection: $currentIndex) {
            ForEach(0..<images.count, id: \.self) { index in
                Image(images[index])
                    .resizable()
                    .scaledToFit()
                    .tag(index)
            }
        }
        
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
        .cornerRadius(10) // 设置圆角
        .shadow(color: .deviceItemShadow, radius: 5, x: 0, y: 0)
        .aspectRatio(1.6, contentMode: .fit)
        .background(Color.white)
        .padding()
    }
}

#Preview {
    SliderView(images: DeviceManager().devices.first?.deviceType.guideImage ?? [])
}
