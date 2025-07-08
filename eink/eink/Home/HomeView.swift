//
//  HomeView.swift
//  eink
//
//  Created by Aaron on 2024/9/4.
//

import SwiftUI
import CoreData

struct HomeView: View {
    
//    @Environment(\.managedObjectContext) private var viewContext
    @Environment(AppRouter.self) private var router
    @Environment(DeviceManager.self) private var deviceManager
    @FetchRequest var designs: FetchedResults<InkDesign>
    @FetchRequest var fDesigns: FetchedResults<FavoriteDesign>
    
    @State private var presetDesigns:[PresetDesign] = []

//    @FetchRequest(
//        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
//        animation: .default)
//    private var items: FetchedResults<Item>
    
    let device:Device
    //@State private var showBottomSheet = false
    @State private var isConnected:Bool = false
    @State private var selectedMode: Features = .category
    
    init(device: Device) {
        self.device = device
        let request: NSFetchRequest<InkDesign> = InkDesign.designRequest(forPid: device.devicePidString)
        _designs = FetchRequest(fetchRequest: request)
        let fRequest: NSFetchRequest<FavoriteDesign> = FavoriteDesign.designRequest(forPid: device.devicePidString)
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
    
    
    enum Features {
        case category
        case favorite
        case customize
        
        
        var title: String {
            switch self {
            case .category:
                return "Category"
            case .favorite:
                return "Favorite"
            case .customize:
                return "Customize"
            }
        }
        var icon: String {
            switch self {
            case .category:
                return "square.grid.2x2"
            case .favorite:
                return "star.fill"
            case .customize:
                return "pencil.circle.fill"
            }
        }
        
    }
    
        var favoriteDesigns: [Design] {
    
            allDesigns.filter{$0.favorite}
    
        }
    
        func isFavorite(name:String, id:String) -> Bool {
            if self.fDesigns.contains(where: {$0.pid == id && $0.name == name}) {
                return true
            }
            return false
        }
    
        var categroyDesigns:[Design] {
            presetDesigns.map{ Design(pid: device.devicePidString,
                                      vGrids: device.deviceType.shape[1],
                                     hGrids: device.deviceType.shape[0],
                                      name: $0.name,
                                      colors: $0.colors,
                                      favorite: isFavorite(name: $0.name, id: device.devicePidString),
                                      category: $0.category
            )}
        }
    
        var customDesigns:[Design] {
            designs.map{
                Design(pid: device.devicePidString,
                       vGrids: Int($0.vGrids),
                         hGrids: Int($0.hGrids),
                          name: $0.name ?? "",
                          colors: $0.colors ?? "",
                       favorite: isFavorite(name: $0.name ?? "", id: device.devicePidString),
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
    
    var body: some View {
        
        VStack{
            
            Image(device.deviceImage)
                .resizable()
                .scaledToFit()
                .padding(.top, 20)
                
            
            HStack {
                Text("Turned on")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.primary)
                Spacer()
                Toggle("", isOn: $isConnected)
                    .toggleStyle(SwitchToggleStyle(tint: .blue))
                    .labelsHidden()
            }
            .padding(.horizontal, 27)
            .frame(height: 84)
            .background(Color.white)
            .cornerRadius(10)
            .shadow(color: .deviceItemShadow, radius: 5, x: 0, y: 0)
            .padding(.top, 50)
            
            controlButtonsSection
                .padding(.top, 30)
                        
                
        }
        .padding(.horizontal, 27)
        .toolbar(.hidden, for: .tabBar)
        .onAppear {
            // Load preset designs from the device type
            loadPresetDesigns(devicePid: device.devicePidString)
        }
        .sheet(item: router.presentSheetBinding()) { destination in
            switch destination {
            case .sendDesigns( _, let designs):
                PlaybackView(device: self.device, designs: designs)
                    .presentationDetents([.height(400)])
                    .presentationDragIndicator(.visible)
            default:
                EmptyView()
            }
            
            
        }
        
//        .toolbar {
//            ToolbarItem(placement: .topBarLeading) {
//                Button(action: {
//                    //appRouter.isConnected?.toggle()
//                }) {
//                    Image(systemName: "chevron.backward")
//                        .foregroundColor(.plusbutton)
//                }
//            }
//
//        }
        
    }
    
//    private func addItem() {
//        withAnimation {
//            let newItem = Item(context: viewContext)
//            newItem.timestamp = Date()
//
//            do {
//                try viewContext.save()
//            } catch {
//                // Replace this implementation with code to handle the error appropriately.
//                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//                let nsError = error as NSError
//                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
//            }
//        }
//    }
//
//    private func deleteItems(offsets: IndexSet) {
//        withAnimation {
//            offsets.map { items[$0] }.forEach(viewContext.delete)
//
//            do {
//                try viewContext.save()
//            } catch {
//                // Replace this implementation with code to handle the error appropriately.
//                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//                let nsError = error as NSError
//                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
//            }
//        }
//    }
    
    
    private var controlButtonsSection: some View {
        HStack(spacing: 80){
            ForEach([
                (Features.category, "square.grid.2x2"),
                (Features.favorite, "star.fill"),
                (Features.customize, "pencil.circle.fill")
                   
               ], id: \.0) { mode, iconName in
                   Button(action: {
                       switch mode {
                       case .category:
                           router.navigate(to: .category(deviceId: device.id))
                       case .favorite:
                           router.navigate(to: .favorite(deviceId: device.id, favorites: favoriteDesigns))
                       case .customize:
                           //customize(deviceId:String, name:String, colors:[String]? = nil)
                           router.navigate(to: .customize(deviceId: device.id, name: newAddNameFrom("New Design"), colors: [], favorite: false))
                       }
                   }) {
                       VStack {
                           
                           Image(systemName: iconName)
                               .resizable()
                               .scaledToFit()
                               .padding(.all, 15)
                               .frame(width:46)
                               .foregroundColor(selectedMode == mode ? .white : .gray)
                               .background(selectedMode == mode ? .philipsBlue : .gray.opacity(0.15))
                               .clipShape(Circle())
                           
                            Text(mode.title)
                               .font(.system(size: 11, weight: .regular))
                               .foregroundColor(selectedMode == mode ? .philipsBlue : .gray)
                                 
                       }
                   }
               }
                
        }
        //.padding(.horizontal, 27)
        .frame(height: 127)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: .deviceItemShadow, radius: 5, x: 1, y: 1)
    }
}

#Preview {
    HomeView(device: DeviceManager.shared.mockDevice)
        .environment(AppRouter.shared)
        .environment(DeviceManager.shared)
}

//private let itemFormatter: DateFormatter = {
//    let formatter = DateFormatter()
//    formatter.dateStyle = .short
//    formatter.timeStyle = .medium
//    return formatter
//}()

