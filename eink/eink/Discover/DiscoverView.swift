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
    
    @Binding var selectIndex:Int
    @State private var showAddView:Bool = false

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
                
                
                Text("\(deviceManager.devices.count) Devies")
                    .font(.deviceCount)
                    .fontWeight(.light)
                    .foregroundColor(.ekSubtitle)
                
                Spacer()
                
                
                Text("Devies")
                    .font(.deviceCount)
                    .fontWeight(.light)
                    .foregroundColor(.sectionTitle)
                    .padding(.top, 60)
                    .padding(.leading, 5)
                
                ScrollView {
                    LazyVGrid(columns: columns) {
                        ForEach(Array(deviceManager.devices.enumerated()), id: \.element) {index, item in
                            DeviceCard(name: item.deviceName,
                                       status: item.status,
                                       image: item.deviceImage)
                            .onTapGesture {
                                selectIndex = index
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
                        withAnimation {
                            showAddView = true
                        }
                    }) {
                        Image(systemName: "plus")
                            .foregroundColor(.plusbutton)
                            
                    }
                    
                }
            }
        }
        .overlay {
            if showAddView {
                AddDeviceView(showAddView: $showAddView)
                    .transition(.move(edge: .bottom))
                    .animation(.spring(), value: showAddView)
                
            }
        }
    }
}

#Preview {
    DiscoverView(selectIndex: .constant(0))
        .environment(DeviceManager())
}
