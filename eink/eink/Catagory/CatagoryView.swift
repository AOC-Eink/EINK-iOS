//
//  CatagoryView.swift
//  eink
//
//  Created by Aaron on 2024/9/4.
//

import SwiftUI
import OrderedCollections

struct CatagoryView: View {
    
    let device:Device
    let designs:[Design]
    
    @Environment(\.appRouter) var appRouter
    
    var categoryDesigns: OrderedDictionary<String, [Design]> {
        OrderedDictionary(grouping: designs, by: { $0.category })
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(Array(categoryDesigns.keys), id: \.self) { category in
                        PresetGridView(
                            device: device,
                            designs: categoryDesigns[category] ?? [],
                            pageType: .category,
                            sectionName: category
                        )
                    }
                }
                
                
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
    CatagoryView(device: DeviceManager().showDevices.first!, designs: [])
}
