//
//  ContentView.swift
//  eink
//
//  Created by Aaron on 2024/9/3.
//

import SwiftUI
import CoreData

struct ContentView: View {
    
    @EnvironmentObject var alertManager: AlertManager
    @Environment(\.presentFullScreen) var presentFullScreen
    @Environment(\.dismissFullScreen) var dismissFullScreen
    
    @EnvironmentObject var appConfig:AppConfiguration
    @State var deviceManager = DeviceManager()
    
    @Environment(\.appRouter) var appRouter
    @State var selectIndex:Int = 0
    
    var activeDevice:Device {
        deviceManager.devices[selectIndex]
    }

    var isConnected: Bool {self.appRouter.isConnected ?? false}
//    Binding<Bool> {
//        Binding<Bool>(
//            get: { self.appRouter.isConnected ?? false },
//            set: { newValue in self.appRouter.isConnected = newValue }
//        )
//    }
    
    var showOnboarding: Binding<Bool> {
        Binding<Bool>(
            get: { appConfig.showOnboarding },
            set: { newValue in appConfig.showOnboarding = newValue }
        )
    }

    var body: some View {
        ZStack {
            DiscoverView(selectIndex: $selectIndex)
                .environment(deviceManager)
                .zIndex(0)
            
            if isConnected {
                TabbarView(device: activeDevice)
                .transition(.move(edge: .bottom))
                .zIndex(1)
            }
        }
        .withAlertManager()
        .animation(.easeInOut, value: isConnected)
        .fullScreenCover(isPresented: showOnboarding) {
            GuideView()
        }
    }
}


#Preview {
    ContentView().environmentObject(AppConfiguration())
}
