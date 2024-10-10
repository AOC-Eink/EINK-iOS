//
//  FavoriteView.swift
//  eink
//
//  Created by Aaron on 2024/9/4.
//

import SwiftUI

struct FavoriteView: View {
    
    let device:Device
    let designs:[InkDesign]
    
    @Environment(\.appRouter) var appRouter
    
    var body: some View {
        NavigationStack {
            ScrollView {
                PresetGridView(device: device, designs: designs, pageType: .favorite)
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
                    Text("Favorite")
                        .font(.title)
                        .foregroundStyle(.mydevicestitle)

                }
            }
        }
    }
}

#Preview {
    FavoriteView(device: DeviceManager().showDevices.first!, designs: [])
}
