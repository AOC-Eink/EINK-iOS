//
//  FavoriteView.swift
//  eink
//
//  Created by Aaron on 2024/9/4.
//

import SwiftUI
import Combine

struct FavoriteView: View {
    
    let device:Device
    let designs:[Design]
    @State private var showBottomSheet = false
    @State private var timerCancellable: AnyCancellable?
    @State private var counter = 0
    
    @Environment(AppRouter.self) private var router
    @State private var isEditing: Bool = false
    
    var body: some View {

        ScrollView {
            PresetGridView(device: device, designs: designs, pageType: .select, isEditing: $isEditing)
                
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
        
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    isEditing.toggle()
                }) {
                    Image(systemName: isEditing ? "app.badge.checkmark" : "ellipsis")
                        .foregroundColor(.plusbutton)
                }
            }
            ToolbarItem(placement: .principal) {
                Text("Favorite")
                    .font(.navTitle)
                    .foregroundStyle(.mydevicestitle)

            }
        }
//        
//        .sheet(isPresented: $showBottomSheet) {
//            PlaybackView(device: device, designs: designs, showBottomSheet: $showBottomSheet)
                //.presentationDetents([.height(400)])
                //.presentationDragIndicator(.visible)
//                .cornerRadius(40, corners: [.topLeft, .topRight])
//                .shadow(color: .deviceItemShadow, radius: 5, x: 1, y: -5)
//        }
        
    }
}

#Preview {
    FavoriteView(device: DeviceManager().showDevices.first!, designs: [])
}
