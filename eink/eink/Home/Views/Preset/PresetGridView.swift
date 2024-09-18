//
//  PresetGridView.swift
//  eink
//
//  Created by Aaron on 2024/9/9.
//

import SwiftUI
import CoreData

struct PresetGridView: View {
    
    @FetchRequest var presetDesigns: FetchedResults<InkDesign>

    let device:Device
    
    init(device:Device) {
        self.device = device
        let request: NSFetchRequest<InkDesign> = InkDesign.designRequest(forDeviceId: device.indentify)
        _presetDesigns = FetchRequest(fetchRequest: request)
    }
    
    var body: some View {
        VStack(alignment:.leading){
            Text("Preset pattern")
                .padding(.leading, 10)
                .font(.deviceCount)
                .foregroundStyle(.sectionTitle)
            
            
                LazyVGrid(columns: device.gridLayout, spacing: 10) {
                    ForEach(presetDesigns, id: \.self) { item in
                        PresetCard(title: item.name ?? "",
                                   presetView: PresetView(colors: item.colors ?? "",
                                                          hGrids: Int(item.hGrids),
                                                          vGrides: Int(item.vGrids)
                                                         ))
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
