//
//  FavoriteView.swift
//  eink
//
//  Created by Aaron on 2024/9/4.
//

import SwiftUI

struct FavoriteView: View {
    
    let device:Device
    let designs:[Design]
    @State private var showBottomSheet = false
    
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
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        showBottomSheet.toggle()
                    }) {
                        Image(systemName: "ellipsis")
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
        .sheet(isPresented: $showBottomSheet) {
            PlaybackView(device: device, showBottomSheet: $showBottomSheet)
                .presentationDetents([.height(400)])
                .presentationDragIndicator(.visible)
//                .cornerRadius(40, corners: [.topLeft, .topRight])
//                .shadow(color: .deviceItemShadow, radius: 5, x: 1, y: -5)
        }
    }
}

#Preview {
    FavoriteView(device: DeviceManager().showDevices.first!, designs: [])
}
