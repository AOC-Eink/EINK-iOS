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
    
    let device:Device
    
    init(device: Device) {
        self.device = device
        let request: NSFetchRequest<InkDesign> = InkDesign.designRequest(forDeviceId: device.indentify)
        _designs = FetchRequest(fetchRequest: request)
        
    }
    
    var favoriteDesigns: [InkDesign] {
        designs.filter { $0.favorite }
    }
    
    var categroyDesigns:[InkDesign] {
        designs.filter { !$0.favorite }
    }
    
    var newAddName: String {
        var newName = "New Design"
        var counter = 0
        
        while designs.contains(where: { $0.name == newName }) {
            counter += 1
            newName = "New Design \(counter)"
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
                    
                    HomeView(device:device, desgins: designs.map { $0 })
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
                    diyName = newAddName
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
        .environment(\.goDIYView) { colors, name, favorite in
            self.diyColors = colors ?? []
            self.diyName = name ?? ""
            self.diyFavorite = favorite ?? false
            if name == nil {
                self.diyName = self.newAddName
            }
            onAddTouch = true
        }
        .onAppear{
            for item in designs {
                print("\(item.name ?? "")")
            }
        }
        
    }
    
}

#Preview {
    TabbarView(device: DeviceManager().devices.first!)
}
//            .fullScreenCover(isPresented: $onAddTouch , content: {
//                DIYView(device: device, isPresented: $onAddTouch)
//            })
