//
//  PresetGridView.swift
//  eink
//
//  Created by Aaron on 2024/9/9.
//

import SwiftUI
import CoreData

struct PresetGridView: View {
    
    enum PageType {
        case preset
        case custom
        case category
        case favorite
    }
    
    @EnvironmentObject var alertManager: AlertManager
    
    let device:Device
    let designs:[InkDesign]
    let pageType:PageType
    
    init(device: Device, designs: [InkDesign] = [], pageType: PageType = .preset) {
        self.device = device
        self.designs = designs
        self.pageType = pageType
    }
    
    
//    var designs:[InkDesign] {
//        switch pageType {
//        case .preset:
//            return []
//        case .custom:
//            return []
//        case .category:
//            return device.favoriteDesigns
//        case .favorite:
//            return device.favoriteDesigns
//        }
//    }
    
    
    var body: some View {
        VStack(alignment:.leading){
            
            if pageType == .preset {
                Text("Preset pattern")
                    .padding(.leading, 10)
                    .font(.deviceCount)
                    .foregroundStyle(.sectionTitle)
            }
            
            
            LazyVGrid(columns: device.gridLayout, spacing: 10) {
                ForEach(designs, id: \.self) { item in
                    PresetCard(title: item.name ?? "",
                               presetView: PresetView(colors: item.colors ?? "",
                                                      hGrids: Int(item.hGrids),
                                                      vGrides: Int(item.vGrids),
                                                      heightRatio: device.inkStyle.heightRatio,
                                                      inkStyle: device.inkStyle
                                                     ))
                    .onTapGesture {
                        alertManager.showAlert(
                            message: "Are you sure to active this design",
                            confirmAction: {
                                
                            },
                            cancelAction: {
                                
                            }
                        )
                    }
                }
            }
            
        }.padding()
    }
}

#Preview {
    PresetGridView(device: DeviceManager().devices.first!)
}
