//
//  TabbarView.swift
//  eink
//
//  Created by Aaron on 2024/9/5.
//

import SwiftUI
import CoreData
struct TabbarView: View {
    
    @Environment(\.appRouter) var appRouter
    @State private var onAddTouch:Bool = false
    @FetchRequest var designs: FetchedResults<InkDesign>
    @FetchRequest var fDesigns: FetchedResults<FavoriteDesign>
    @State private var presetDesigns:[PresetDesign] = []
    
    let device:Device
    
    init(device: Device) {
        self.device = device
        let request: NSFetchRequest<InkDesign> = InkDesign.designRequest(forDeviceId: device.indentify)
        _designs = FetchRequest(fetchRequest: request)
        let fRequest: NSFetchRequest<FavoriteDesign> = FavoriteDesign.designRequest(forDeviceId: device.indentify)
        _fDesigns = FetchRequest(fetchRequest: fRequest)
        
        
    }
    
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
    
    
    var favoriteDesigns: [Design] {
        
        allDesigns.filter{$0.favorite}

    }
    
    func isFavorite(name:String, id:String) -> Bool {
        if self.fDesigns.contains(where: {$0.deviceId == id && $0.name == name}) {
            return true
        }
        return false
    }
    
    var categroyDesigns:[Design] {
        presetDesigns.map{ Design(deviceId: device.indentify,
                                  vGrids: device.deviceType.shape[1],
                                 hGrids: device.deviceType.shape[0],
                                  name: $0.name,
                                  colors: $0.colors,
                                  favorite: isFavorite(name: $0.name, id: device.indentify),
                                  category: $0.category
        )}
    }
    
    var customDesigns:[Design] {
        designs.map{
            Design(deviceId: device.indentify,
                   vGrids: Int($0.vGrids),
                     hGrids: Int($0.hGrids),
                      name: $0.name ?? "",
                      colors: $0.colors ?? "",
                      favorite: isFavorite(name: $0.name ?? "", id: device.indentify),
                      category: "custom")
        }
    }
    
    var allDesigns:[Design] {
        categroyDesigns+customDesigns
    }
    
    func newAddNameFrom(_ name:String) -> String {
        var newName = name
        var counter = 0
        
        while allDesigns.contains(where: { $0.name == newName }) {
            counter += 1
            newName = "\(name) \(counter)"
        }
        return newName
    }
    
    @State private var diyColors:[String] = []
    @State private var diyName:String = ""
    @State private var diyFavorite:Bool = false
    
    
    @State private var selectedTab: Router = .home(nil)
    
    var body: some View {
        ZStack {
            ZStack(alignment: .bottom) {
                TabView(selection: $selectedTab){
                    
                    HomeView(device:device, designs: categroyDesigns, customDesigns: customDesigns)
                        .tabItem {
                            Label("Home", systemImage: "house")}
                        .tag(Router.home(nil))
                    
                    CatagoryView(device: device, designs: categroyDesigns)
                        .tabItem {
                            Label("Category", systemImage: "list.bullet")}
                        .tag(Router.catagory(nil))
                    
                    Color.clear
                        .tabItem {}
                        .tag(Router.addDIY(nil))
                    
                    FavoriteView(device: device, designs:favoriteDesigns)
                        .tabItem {
                            Label("Favorites", systemImage: "heart")}
                        .tag(Router.favorites(nil))
                    
                    ProfileView()
                        .tabItem {
                            Label("Profile", systemImage: "person")}
                        .tag(Router.profile(nil))
                    
                }
                .tint(.opButton)
                
                Button(action: {
                    diyName = newAddNameFrom("New Design")
                    diyColors = []
                    diyFavorite = false
                    onAddTouch.toggle()
                }) {
                    Image(systemName: "plus.app.fill")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.opButton)
                }
                .offset(y:-5)
            }
            .zIndex(0)
            
            if onAddTouch {
                DIYView(model: DIYView.Model(device,
                                             name: diyName,
                                             colors: diyColors,
                                             favorite: diyFavorite
                                            ),
                        isPresented: $onAddTouch)
                    .transition(.move(edge: .bottom))
                    .zIndex(1)
                    .id(UUID())
            }

            
        }
        .animation(.easeInOut, value: onAddTouch)
        .environment(\.goDIYView) { colors, name, favorite, isCostom in
            self.diyColors = colors ?? []
            self.diyName = isCostom ? (name ?? "") : self.newAddNameFrom(name ?? "New Design")
            self.diyFavorite = favorite ?? false
            onAddTouch = true
        }
        .onAppear{
            loadPresetDesigns(devicePid: device.devicePidString)
//            for item in designs {
//                print("\(item.name ?? "")")
//            }
        }
        .onChange(of: device.bleStatus) { oldValue, newValue in
            if newValue == .disconnected {
                appRouter.isConnected = false
            }
        }
        
    }
    
}

#Preview {
    TabbarView(device: DeviceManager().showDevices.first!)
}
//            .fullScreenCover(isPresented: $onAddTouch , content: {
//                DIYView(device: device, isPresented: $onAddTouch)
//            })
