//
//  TabbarView.swift
//  eink
//
//  Created by Aaron on 2024/9/5.
//

import SwiftUI

struct TabbarView: View {
    
    @Environment(\.appRouter) var appRouter
    
    @State private var selectedTab: Router = .home(nil)
    
    var body: some View {
        TabView(selection: $selectedTab){
            
            HomeView()
                .tabItem {
                Label("home", systemImage: "house")}
                .tag(Router.home(nil))

            CatagoryView()
                .tabItem {
                Label("catagory", systemImage: "list.bullet")}
                .tag(Router.catagory(nil))

            Color.clear // 占位用的透明视图
                .tabItem {
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .frame(width: 44, height: 44)
                        .foregroundColor(.blue)
                }
                .onTapGesture {
                    // 点击添加按钮的操作
                    print("Tapped add button")
                }

            FavoriteView()
                .tabItem {
                Label("favorites", systemImage: "heart")}
                .tag(Router.favorites(nil))

            ProfileView()
                .tabItem {
                Label("profile", systemImage: "person")}
                .tag(Router.profile(nil))

        }
    }
}

#Preview {
    TabbarView()
}
