//
//  PresetGridView.swift
//  eink
//
//  Created by Aaron on 2024/9/9.
//

import SwiftUI
import CoreData
import AlertToast

enum EditAction {
    case apply
    case edit
    case delete
}

struct PresetGridView: View {
    
    enum PageType {
        case preset
        case custom
        case category
        case favorite
    }
    
    @EnvironmentObject var alertManager: AlertManager
    @Environment(\.appRouter) var appRouter
    @Environment(\.goDIYView) var goDIYView
    @State private var showToast = false
    
    let device:Device
    let designs:[InkDesign]
    let pageType:PageType
    
    init(device: Device, designs: [InkDesign] = [], pageType: PageType = .preset) {
        self.device = device
        self.designs = designs
        self.pageType = pageType
    }
    
    func deleteAlert(_ name:String) {
        alertManager.showAlert(
            message: "Are you sure to delete this design",
            confirmAction: {
                try? CoreDataStack.shared.deleteDesignWithName(name: name)
            },
            cancelAction: {
                
            }
            )
    }
    
    func applay(_ colors:[String]) {
        showToast.toggle()
    }
    
    func edit(_ design:InkDesign) {
        goDIYView(design.colors?.components(separatedBy: ",") ,design.name, design.favorite)
    }
    
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
                                                     ),
                        onTouch:{ action in
                                    
                        switch action {
                            
                        case .apply:
                            applay(item.colors?.components(separatedBy: ",") ?? [])
                        case .edit:
                            edit(item)
                        case .delete:
                            deleteAlert(item.name ?? "")
                        }
                                
                       }
                        
                               
                    )
                    
                }
            }
            
        }
        .padding()
        .toast(isPresenting: $showToast) {
            AlertToast(type: .complete(.designGreen), title: "Apply Success")
        }
        
    }
}

#Preview {
    PresetGridView(device: DeviceManager().devices.first!)
}
