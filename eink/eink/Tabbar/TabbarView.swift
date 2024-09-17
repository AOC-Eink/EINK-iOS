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
    
    @State private var selectedTab: Router = .home(nil)
    
    var body: some View {
        TabView(selection: $selectedTab){
            
            HomeView(device:device)
                .tabItem {
                Label("home", systemImage: "house")}
                .tag(Router.home(nil))

            CatagoryView()
                .tabItem {
                Label("catagory", systemImage: "list.bullet")}
                .tag(Router.catagory(nil))

            DIYView(device: device) // 占位用的透明视图
                .tabItem {
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .frame(width: 44, height: 44)
                        .foregroundColor(.blue)
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
        .fullScreenCover(isPresented: $onAddTouch , content: {
            DIYView(device: device)
        })
        
    }
}

#Preview {
    TabbarView(deviceIndex: 0)
}
