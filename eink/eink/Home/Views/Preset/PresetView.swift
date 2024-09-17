//
//  PresetView.swift
//  eink
//
//  Created by Aaron on 2024/9/9.
//

import SwiftUI

struct PresetView: View {
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
    PresetView(image: "preset.clock.club.b")
}
