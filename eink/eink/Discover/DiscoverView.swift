//
//  DiscoverView.swift
//  eink
//
//  Created by Aaron on 2024/9/5.
//

import SwiftUI
import CoreData
import SwiftfulLoadingIndicators

struct DiscoverView: View {
    @Environment(\.appRouter) var appRouter
    @EnvironmentObject var appConfig:AppConfiguration
    @Environment(DeviceManager.self) var deviceManager
    @EnvironmentObject var alertManager: AlertManager
    
    @Binding var selectIndex:Int
    @State private var showAddView:Bool = false
    @State private var isShowingPopup:Bool = false

    let model:Model
    
    init(selectIndex:Binding<Int>, model:Model) {
        _selectIndex = selectIndex
        self.model = model
    }
    
    
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
                
                
                Text("\(model.showDevices.count) Devies")
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
                if model.showDevices.isEmpty {
                    VStack {
                        Spacer()
                        Button(action: {
                            showAddView = true
                        }) {
                            Image(systemName: "plus.app.fill")
                                .resizable()
                                .frame(width: 60, height: 60)
                                .foregroundColor(.gray)
                                .clipShape(Circle())
                        }
                        .padding()
                        
                        
                        Text("Please add a device")
                            .padding()
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                } else {
                    ScrollView {
                        
                        LazyVGrid(columns: columns) {
                            ForEach(Array(model.showDevices.enumerated()), id: \.offset) {index, item in
                                DeviceCard(name: item.deviceName,
                                           status: item.bleStatus.statusName,
                                           image: item.deviceImage,
                                           color: item.bleStatus.statusBg
                                )
                                .onTapGesture {
                                    model.stopScan()
                                    let device = model.showDevices[index]
                                    if device.bleStatus == .connected {
                                        selectIndex = index
                                        appRouter.isConnected = true
                                        return
                                    }
                                    
                                    if device.bleStatus == .discovered  {
                                        selectIndex = index
                                        isShowingPopup = true
                                        Task {
                                            await model.connectDevice(device: device)
                                        }
                                        
                                    }

                                }
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
                    .id(UUID())
                
            }
        }
        .onAppear{
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                model.refreshDevicesStatus()
            }
        }
        .onChange(of: model.errorMessage) { oldValue, newValue in
            guard let error = newValue else {return}
            isShowingPopup = false
            if error == "successs" {
                
                appRouter.isConnected = true
                return
            }
            
            alertManager.showAlert(message:error, confirmAction: {
                model.refreshDevicesStatus()
            })
        }
        .onChange(of: appRouter.isConnected) { oldValue, newValue in
            
            if (oldValue ?? false) && !(newValue ?? true) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    model.refreshDevicesStatus()
                }
            }
        }
        .overlay(
            Group {
                if isShowingPopup {
                    Color.black.opacity(0.4)
                        .edgesIgnoringSafeArea(.all)
//                        .onTapGesture {
//                            isShowingPopup = false
//                        }
                    
                    VStack {
                        connectingView
                            .frame(width: 300, height: 200)
                            .background(Color.white)
                            .cornerRadius(20)
                            .shadow(radius: 10)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        )
        
    }
    
    @ViewBuilder
    var connectingView:some View {
        VStack(spacing:30) {
            LoadingIndicator(animation: .circleTrim, color: .opButton, size: .large)
            Text("Connecting...")
                .font(.sectionBigTitle)
                .foregroundStyle(.sectionTitle)
        }
        .padding(.vertical, 80)
    }
}

#Preview {
    DiscoverView(selectIndex: .constant(0), model: DiscoverView.Model(DeviceManager()))
        .environment(DeviceManager())
}
