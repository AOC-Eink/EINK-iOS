//
//  ContentView.swift
//  eink
//
//  Created by Aaron on 2024/9/3.
//

import SwiftUI
import CoreData

struct ContentView: View {
    
    @Environment(\.appRouter) var appRouter
    
    @State private var selectedTab: Router = .home(nil)
//    {
//        switch appRouter.router {
//        case .home:     
//            return .home(nil)
//        case .catagory:
//            return .catagory(nil)
//        case .favorites:
//            return .favorites(nil)
//        case .profile:
//            return .profile(nil)
//        case .addDevice:
//            return .addDevice(nil)
//        case .none:
//            return .home(.detail(0))
//        }
//    }
    

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

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
