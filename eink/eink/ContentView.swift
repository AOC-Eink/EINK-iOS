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
    
    @EnvironmentObject var appConfig:AppConfiguration
    
    @FetchRequest var savedDevices: FetchedResults<InkDevice>
    @Environment(DeviceManager.self) var deviceManager
    @Environment(\.appRouter) var appRouter
    @State var selectIndex:Int = 0
    
    
    init() {
        let request: NSFetchRequest<InkDevice> = InkDevice.deviceRequest
        _savedDevices = FetchRequest(fetchRequest: request)
    }
    
    var saveCVDevices:[InkDevice] {
        savedDevices.map{$0}
    }
    
    var activeDevice:Device {
        let saveDevices:[Device] = deviceManager.showDevices
        return saveDevices[selectIndex]
        
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
            DiscoverView(selectIndex: $selectIndex, 
                         model: DiscoverView.Model(deviceManager))
                //.environment(deviceManager)
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
        .onAppear{
            deviceManager.updateSaveDevices(saveCVDevices)
        }
//        .onChange(of: saveCVDevices) { oldValue, newValue in
//            deviceManager.updateSaveDevices(newValue)
//        }
        
    }
}


#Preview {
    ContentView().environmentObject(AppConfiguration())
}
