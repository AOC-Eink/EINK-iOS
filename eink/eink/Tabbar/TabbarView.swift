//
//  TabbarView.swift
//  eink
//
//  Created by Aaron on 2024/9/5.
//

import SwiftUI

struct TabbarView: View {
    
    @Environment(\.appRouter) var appRouter
    @State private var onAddTouch:Bool = false
    
    let device:Device
    
    @State private var selectedTab: Router = .home(nil)
    
    var body: some View {
        ZStack {
            ZStack(alignment: .bottom) {
                TabView(selection: $selectedTab){
                    
                    HomeView(device:device)
                        .tabItem {
                            Label("Home", systemImage: "house")}
                        .tag(Router.home(nil))
                    
                    CatagoryView()
                        .tabItem {
                            Label("Category", systemImage: "list.bullet")}
                        .tag(Router.catagory(nil))
                    
                    Color.clear
                        .tabItem {}
                        .tag(Router.addDIY(nil))
                    
                    FavoriteView()
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
                    onAddTouch = true
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
                DIYView(device: device, isPresented: $onAddTouch)
                    .transition(.move(edge: .bottom))
                    .zIndex(1)
            }

            
        }
        .animation(.easeInOut, value: onAddTouch)
    }
}

#Preview {
    TabbarView(device: Device(indentify: "EE:FF:GG:HH",
                                   deviceName: "E-INK Clock",
                                   status: "Unconected",
                                   deviceImage: "eink.clock.device"))
}
//            .fullScreenCover(isPresented: $onAddTouch , content: {
//                DIYView(device: device, isPresented: $onAddTouch)
//            })
