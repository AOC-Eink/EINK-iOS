//
//  ContentView.swift
//  eink
//
//  Created by Aaron on 2024/9/3.
//

import SwiftUI
import CoreData

struct ContentView: View {
    
    @EnvironmentObject var appConfig:AppConfiguration
    @State var deviceManager = DeviceManager()
    
    @Environment(\.appRouter) var appRouter

    var isConnected: Binding<Bool> {
        Binding<Bool>(
            get: { self.appRouter.isConnected ?? false },
            set: { newValue in self.appRouter.isConnected = newValue }
        )
    }
    
    var showOnboarding: Binding<Bool> {
        Binding<Bool>(
            get: { appConfig.showOnboarding },
            set: { newValue in appConfig.showOnboarding = newValue }
        )
    }

    var body: some View {
        
        DiscoverView()
            .environment(deviceManager)
            .fullScreenCover(isPresented: showOnboarding, content: {
                GuideView()
            })
            .fullScreenCover(isPresented: isConnected, content: {
                TabbarView()
            })
            
        
    }
}


#Preview {
    ContentView().environmentObject(AppConfiguration())
}
