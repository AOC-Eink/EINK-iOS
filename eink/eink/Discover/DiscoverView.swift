//
//  DiscoverView.swift
//  eink
//
//  Created by Aaron on 2024/9/5.
//

import SwiftUI
import CoreData
import SwiftfulLoadingIndicators
import BLECommunicator

struct DiscoverView: View {
    @Environment(\.appRouter) var appRouter
    @EnvironmentObject var appConfig:AppConfiguration
    @Environment(DeviceManager.self) var deviceManager
    
    @Binding var selectIndex:Int
    @State private var showAddView:Bool = false
    @State private var isShowingPopup:Bool = false
    @State private var showSelectType:Bool = false

    let model:Model = Model()
    
    init(selectIndex:Binding<Int>) {
        debugPrint("new Init DiscoverView")
        _selectIndex = selectIndex
    }
    
    
    let columns = [GridItem(.flexible()),
                   GridItem(.flexible())]
    
    var showDevices:[Device] {
        model.showDevices(deviceManager)
    }
    
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
                
                
                Text("\(showDevices.count) Devies")
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
                if showDevices.isEmpty {
                    VStack {
                        Spacer()
                        Button(action: {
                            showSelectType = true
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
                            ForEach(Array(showDevices.enumerated()), id: \.offset) {index, item in
                                DeviceCard(name: item.deviceName,
                                           status: item.bleStatus.statusName,
                                           image: item.deviceImage,
                                           color: item.bleStatus.statusBg
                                )
                                .onTapGesture {
                                    model.stopScan(deviceManager)
                                    let device = showDevices[index]
                                    if device.bleStatus == .connected {
                                        selectIndex = index
                                        appRouter.isConnected = true
                                        return
                                    }
                                    
                                    if device.bleStatus == .discovered  {
                                        selectIndex = index
                                        isShowingPopup = true
                                        Task {
                                            await model.connectDevice(deviceManager, device: device)
                                        }
                                        
                                    }

                                }
                                .contextMenu {
                                    
                                    Button {
                                        let device = showDevices[index]
                                        Task {
                                            await model.removeDevice(deviceManager, device: device)
                                        }
                                       
                                    } label: {
                                        Label("Remove", systemImage: "trash.slash")
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
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        exportLog()
                    }) {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(.opButton)
                    }
                }
                ToolbarItem {
                    Button(action: {
                        withAnimation {
                            showSelectType = true
                        }
                    }) {
                        Image(systemName: "plus")
                            .foregroundColor(.plusbutton)
                            
                    }
                    
                }
            }
        }
//        .overlay {
//            if showAddView {
//                AddDeviceView(showAddView: $showAddView)
//                    .transition(.move(edge: .bottom))
//                    .animation(.spring(), value: showAddView)
//                    .id(UUID())
//                
//            }
//        }
        .sheet(isPresented: $showAddView, onDismiss: {
            
        }, content: {
            AddDeviceView(showAddView: $showAddView)
                .presentationDetents([.height(400)])
                .presentationDragIndicator(.visible)
        })
        .alert("添加设备", isPresented: $showSelectType) {
            HStack {
                Button {
                    // 蓝牙连接逻辑
                    showAddView = true
                } label: {
                    Label("蓝牙", systemImage: "bluetooth")
                }
                
                Button {
                    // NFC连接逻辑
                    model.activeNFCDevice()
                } label: {
                    Label("NFC", systemImage: "radiowaves.left")
                }
                
                Button("取消", role: .cancel) {
                       
                }
            }
        } message: {
            Text("请选择要使用的连接方式")
        }
        
        .onAppear{
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                model.refreshDevicesStatus(deviceManager)
            }
        }
        .onChange(of: model.errorMessage) { oldValue, newValue in
            guard let error = newValue else {return}
            isShowingPopup = false
            if error == "success" {
                
                appRouter.isConnected = true
                return
            }
            AlertWindow.show(title: "Reminder", message: error, onTap:{
                model.refreshDevicesStatus(deviceManager)
            })
        }
        .onChange(of: appRouter.isConnected) { oldValue, newValue in
            
            if (oldValue ?? false) && !(newValue ?? true) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    model.refreshDevicesStatus(deviceManager)
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
    
    func exportLog() {
        let logFileURL = Logger.shared.getLogFileURL()
        let activityVC = UIActivityViewController(activityItems: [logFileURL], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootViewController = window.rootViewController {
            rootViewController.present(activityVC, animated: true, completion: nil)
        }
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
    DiscoverView(selectIndex: .constant(0))
        .environment(DeviceManager())
}
