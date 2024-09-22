//
//  CatagoryView.swift
//  eink
//
//  Created by Aaron on 2024/9/4.
//

import SwiftUI

struct CatagoryView: View {
    
    let device:Device
    let designs:[InkDesign]
    
    @Environment(\.appRouter) var appRouter
    
    var body: some View {
        NavigationStack {
            ScrollView {
                PresetGridView(device: device, designs: designs, pageType: .category)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        appRouter.isConnected?.toggle()
                    }) {
                        Image(systemName: "chevron.backward")
                            .foregroundColor(.plusbutton)
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text("Category")
                        .font(.title)
                        .foregroundStyle(.mydevicestitle)

                }
            }
        }
    }
}

#Preview {
    CatagoryView(device: DeviceManager().devices.first!, designs: [])
}
