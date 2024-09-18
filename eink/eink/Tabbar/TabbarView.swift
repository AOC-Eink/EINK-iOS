//
//  TabbarView.swift
//  eink
//
//  Created by Aaron on 2024/9/5.
//

import SwiftUI

struct TabbarView: View {
    
    @Environment(\.appRouter) var appRouter
    @Environment(DeviceManager.self) var deviceManager
    @State private var onAddTouch:Bool = false
    let deviceIndex:Int
    
    var device:Device {
        deviceManager.devices[deviceIndex]
    }
    
    var testColors:[String] {
        device.deviceType.presetDesigns["Cube"]!.components(separatedBy: ",")
    }
    
    
    @State private var selectedTab: Router = .home(nil)
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab){
                
                HomeView(device:device)
                    .tabItem {
                        Label("home", systemImage: "house")}
                    .tag(Router.home(nil))
                
                CatagoryView()
                    .tabItem {
                        Label("catagory", systemImage: "list.bullet")}
                    .tag(Router.catagory(nil))
                
                Color.clear
                    .tabItem {
                        
                    }
                    .tag(Router.addDevice(nil))
                
                
                FavoriteView()
                    .tabItem {
                        Label("favorites", systemImage: "heart")}
                    .tag(Router.favorites(nil))
                
                ProfileView()
                    .tabItem {
                        Label("profile", systemImage: "person")}
                    .tag(Router.profile(nil))
                
            }
            
            Button(action: {
                onAddTouch = true
            }) {
                Image(systemName: "plus.circle.fill")
                    .resizable()
                    .frame(width: 60, height: 60)
                    .foregroundColor(.blue)
            }
            .offset(y: -30)
        }
        .fullScreenCover(isPresented: $onAddTouch , content: {
            DIYView(device: device, isPresented: $onAddTouch)
        })
        
    }
}

#Preview {
    TabbarView(deviceIndex: 0)
}
