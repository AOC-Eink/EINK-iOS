//
//  SliderCard.swift
//  eink
//
//  Created by Aaron on 2024/9/11.
//

import SwiftUI

struct SliderCard: View {
    let image:String
    
    var body: some View {
        //VStack {
        Image(image)
            .resizable()
            .aspectRatio(contentMode: .fit)
        //}
    }
}

#Preview {
    SliderCard(image: "device.case.slide.guide")
}
