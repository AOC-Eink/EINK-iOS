//
//  PresetGridView.swift
//  eink
//
//  Created by Aaron on 2024/9/9.
//

import SwiftUI

struct PresetGridView: View {
    
    let device:Device
    
    var body: some View {
        VStack(alignment:.leading){
            Text("Preset pattern")
                .padding(.leading, 10)
                .font(.deviceCount)
                .foregroundStyle(.sectionTitle)
            
            
                LazyVGrid(columns: device.gridLayout, spacing: 10) {
                    ForEach(device.deviceType.presetImages, id: \.self) { item in
                        PresetCard(title: "Letter",
                                   presetView: PresetView(image: item))
                        .onTapGesture {
                            
                        }
                    }
                }
            
        }.padding()
    }
}

#Preview {
    PresetGridView(device: DeviceManager().devices.first!)
}
