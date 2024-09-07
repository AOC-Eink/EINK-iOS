//
//  DiscoverView.swift
//  eink
//
//  Created by Aaron on 2024/9/5.
//

import SwiftUI

struct DiscoverView: View {
    @Environment(\.appRouter) var appRouter
    @EnvironmentObject var appConfig:AppConfiguration
    @Environment(DeviceManager.self) var deviceManager
//    let columns = [
//            GridItem(.adaptive(minimum: 150))
//        ]
    let columns = [GridItem(.flexible()),
                   GridItem(.flexible())]
    
    var body: some View {
        
        NavigationView {
            VStack(alignment:.leading, spacing: 10){
                
                HStack(alignment:.center, spacing: 10){
                    Image("eink.logo")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 40, height: 40)
                    
                    Text("My Devices")
                        .font(.mydevices)
                        .fontWeight(.regular)
                        .foregroundStyle(.mydevicestitle)
                    
                    Spacer()
                        
                }
                
                
                Text("7 Devies")
                    .font(.deviceCount)
                    .fontWeight(.light)
                    .foregroundColor(.ekSubtitle)
                
                Spacer()
                
                
                Text("Devies")
                    .font(.deviceCount)
                    .fontWeight(.light)
                    .foregroundColor(.deviceSetionTitle)
                    .padding(.top, 80)
                    .padding(.leading, 5)
                
                ScrollView {
                    LazyVGrid(columns: columns) {
                        ForEach(deviceManager.devices, id: \.self) { item in
                            DeviceCard(name: item.deviceName,
                                       status: item.status,
                                       image: item.deviceImage)
                            .onTapGesture {
                                appRouter.isConnected = true
                            }
                        }
                    }
                }
                //.padding()
                
                
                
            }
            .padding()
            
            .toolbar {

                ToolbarItem {
                    Button(action: {
                        appConfig.showOnboarding = true
                    }) {
                        Image(systemName: "plus")
                            .foregroundColor(.black)
                            
                    }
                    
                }
        }
        }
    }
}

#Preview {
    DiscoverView()
        .environment(DeviceManager())
}
