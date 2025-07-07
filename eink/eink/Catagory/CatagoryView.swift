//
//  CatagoryView.swift
//  eink
//
//  Created by Aaron on 2024/9/4.
//

import SwiftUI
import OrderedCollections
import CoreData

struct CatagoryView: View {
    let device: Device
    @Environment(AppRouter.self) private var router
    @FetchRequest var designs: FetchedResults<InkDesign>
    @FetchRequest var fDesigns: FetchedResults<FavoriteDesign>
    @State private var presetDesigns: [PresetDesign] = []
    @State private var selectedCategory: String = ""
    
    func loadPresetDesigns(devicePid:String) {
        guard let url = Bundle.main.url(forResource: "PresetColors", withExtension: "json") else {
            print("无法找到配置文件")
            return
        }
        do {
            let data = try Data(contentsOf: url)
            if let presets:[PresetDesign] = data.toModel(key: devicePid) {
                presetDesigns = presets
            }
        } catch {
            print("解析配置文件时出错: \(error)")
            return
        }
    }

    init(device: Device) {
        self.device = device
        let request: NSFetchRequest<InkDesign> = InkDesign.designRequest(forPid: device.devicePidString)
        _designs = FetchRequest(fetchRequest: request)
        let fRequest: NSFetchRequest<FavoriteDesign> = FavoriteDesign.designRequest(forPid: device.devicePidString)
        _fDesigns = FetchRequest(fetchRequest: fRequest)
    }

    func isFavorite(name: String, id: String) -> Bool {
        self.fDesigns.contains(where: { $0.pid == id && $0.name == name })
    }

    var categroyDesigns: [Design] {
        presetDesigns.map {
            Design(pid: device.devicePidString,
                   vGrids: device.deviceType.shape[1],
                   hGrids: device.deviceType.shape[0],
                   name: $0.name,
                   colors: $0.colors,
                   favorite: isFavorite(name: $0.name, id: device.indentify),
                   category: $0.category
            )
        }
    }

    var categoryDesigns: OrderedDictionary<String, [Design]> {
        OrderedDictionary(grouping: categroyDesigns, by: { $0.category })
    }

    var body: some View {
            VStack(spacing: 0) {
                // Segment View
                let categories = Array(categoryDesigns.keys)
                    HStack(spacing: 24) {
                        ForEach(categories, id: \.self) { category in
                            Button(action: {
                                selectedCategory = category
                            }) {
                                VStack(spacing: 4) {
                                    Text(category)
                                        .font(.system(size: 12))
                                        .multilineTextAlignment(.center)
                                        .foregroundColor(selectedCategory == category ? .accentColor : .primary)
                                        .fontWeight(selectedCategory == category ? .bold : .regular)
                                    Rectangle()
                                        .fill(selectedCategory == category ? Color.accentColor : Color.clear)
                                        .frame(height: 3)
                                        .frame(maxWidth: .infinity)
                                }
                                .padding(.vertical, 8)
                                .frame(minWidth: 0, maxWidth: .infinity)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal)
                    .padding(.top, 10)


                // Content
                ScrollView {
                    if let designs = categoryDesigns[selectedCategory] {
                        PresetGridView(
                            device: device,
                            designs: designs,
                            pageType: .category,
                            isEditing: .constant(false)
                        )
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Category")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(.mydevicestitle)
                }
            }
            .onAppear{
               loadPresetDesigns(devicePid: device.devicePidString)
               for item in designs {
                   print("\(item.name ?? "")")
               }
                if selectedCategory.isEmpty, let first = Array(categoryDesigns.keys).first {
                    selectedCategory = first
                }
           }
        }
        
    
}

#Preview {
    CatagoryView(device: DeviceManager.shared.mockDevice)
        .environment(AppRouter.shared)
}
