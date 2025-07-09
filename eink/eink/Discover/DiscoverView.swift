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
    @Environment(AppRouter.self) private var router
    @EnvironmentObject var appConfig:AppConfiguration
    @FetchRequest var savedDevices: FetchedResults<InkDevice>
    @Environment(DeviceManager.self) var deviceManager
    
    //@Binding var selectIndex:Int
    @State private var showAddView:Bool = false
    @State private var isShowingPopup:Bool = false
    @State private var showSelectType:Bool = false

    //let model:Model = Model()
    @State private var model:Model
    
    init() {
        debugPrint("new Init DiscoverView")
        //_selectIndex = selectIndex
        _model = State(initialValue: Model(deviceManager: DeviceManager.shared))

        let request: NSFetchRequest<InkDevice> = InkDevice.deviceRequest
        _savedDevices = FetchRequest(fetchRequest: request)
    }
    
    var saveCVDevices:[InkDevice] {
        savedDevices.map{$0}
    }
    
    
    let columns = [GridItem(.flexible()),
                   GridItem(.flexible())]
    
    var showDevices:[Device] {
        model.showDevices
    }
    

    var body: some View {
        
        NavigationStack(path: router.navigationPathBinding()) {
            VStack(alignment:.leading, spacing: 10){
                
                headArea
                
                if showDevices.isEmpty {
                    emptyView
                } else {
                    deviceCountView
                }
            }
            .padding()
            .navigationTitle("E-ink Prism")
            .navigationDestination(for: AppDestination.self) { destination in
                switch destination {
                case .device(let id):
                    if let device = showDevices.first(where: { $0.id == id }) {
                        HomeView(device: device)
                            
                    } else {
                        Text("Device not found")
                            .foregroundColor(.red)
                    }
                case .category(deviceId: let deviceId):
                    if let device = showDevices.first(where: { $0.id == deviceId }) {
                        CatagoryView(device: device)
                    } else {
                        Text("Device not found")
                            .foregroundColor(.red)
                    }
                case .favorite(deviceId: let deviceId, favorites: let favoriteDesigns):
                    if let device = showDevices.first(where: { $0.id == deviceId }) {
                        FavoriteView(device: device, designs:favoriteDesigns)
                    } else {
                        Text("Device not found")
                            .foregroundColor(.red)
                    }
                //customize(deviceId:String, name:String, colors:[String], favorite:Bool)
                case .customize(deviceId: let deviceId, name: let name, colors: let colors, favorite: let favorite):

                    if let device = showDevices.first(where: { $0.id == deviceId }) {
                        DIYView(device: device, name: name, colors: colors, favorite: favorite)
                    } else {
                        Text("Device not found")
                            .foregroundColor(.red)
                    }
                case .sendDesigns(deviceId: let deviceId, designs: let designs):
                    if let device = showDevices.first(where: { $0.id == deviceId }) {
                        PlaybackView(device: device, designs: designs)
                    } else {
                        Text("Device not found")
                            .foregroundColor(.red)
                    }
                    
                case .designDetail(deviceId: let deviceId, design: let design):
                    
                    if let device = showDevices.first(where: { $0.id == deviceId }) {
                        
                        DesignDetail(device: device, design:design)
                    } else {
                        Text("Device not found")
                            .foregroundColor(.red)
                    }
                }
            }
            
//            .toolbar {
//                ToolbarItem(placement: .navigationBarLeading) {
//                    Button(action: {
//                        exportLog()
//                    }) {
//                        Image(systemName: "square.and.arrow.up")
//                            .foregroundColor(.opButton)
//                    }
//                }
//                ToolbarItem {
//                    Button(action: {
//                        withAnimation {
//                            showSelectType = true
//                        }
//                    }) {
//                        Image(systemName: "plus")
//                            .foregroundColor(.plusbutton)
//                            
//                    }
//                    
//                }
//            }
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
        .alert("Add Device", isPresented: $showSelectType) {
            HStack {
                Button {
                    // 蓝牙连接逻辑
                    showAddView = true
                } label: {
                    Label("BT", systemImage: "bluetooth")
                }
                
                Button {
                    // NFC连接逻辑
                    model.activeNFCDevice()
                } label: {
                    Label("NFC", systemImage: "radiowaves.left")
                }
                
                Button("Cancel", role: .cancel) {
                       
                }
            }
        } message: {
            Text("Please select a connection method")
        }
        
        .onAppear{
            deviceManager.updateSaveDevices(saveCVDevices)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                model.refreshDevicesStatus()
            }
        }
        .onChange(of: model.errorMessage) { oldValue, newValue in
            guard let error = newValue else {return}
            isShowingPopup = false
            if error == "success" {
                
                //appRouter.isConnected = true
                return
            }
            AlertWindow.show(title: "Reminder", message: error, onTap:{
                model.refreshDevicesStatus()
            })
        }
        .onChange(of: saveCVDevices) { oldValue, newValue in
            deviceManager.updateSaveDevices(newValue)
        }
//        .onChange(of: appRouter.isConnected) { oldValue, newValue in
//            
//            if (oldValue ?? false) && !(newValue ?? true) {
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                    model.refreshDevicesStatus()
//                }
//            }
//        }
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
    
    
    var headArea: some View {
        HStack{
            Text("Devies")
                .font(.deviceCount)
                .fontWeight(.bold)
                .foregroundColor(.sectionTitle)
                //.padding(.top, 60)
                .padding(.leading, 5)
            
            Spacer()
            
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
    
    @ViewBuilder
    var deviceCountView: some View {
        ScrollView {
            
            LazyVGrid(columns: columns) {
                ForEach(Array(showDevices.enumerated()), id: \.offset) {index, item in
                    DeviceCard(name: item.deviceName,
                               status: item.bleStatus.statusName,
                               image: item.deviceImage,
                               color: item.bleStatus.statusBg
                    )
                    .onTapGesture {
                        model.stopScan()
                        let device = showDevices[index]
                        if device.bleStatus == .connected {
                            //selectIndex = index
                            //appRouter.isConnected = true
                            router.navigate(to: .device(id: device.id))
                            return
                        }
                        
                        if device.bleStatus == .discovered  {
                            //selectIndex = index
                            isShowingPopup = true
                            Task {
                                await model.connectDevice(device: device)
                            }
                            
                        }

                    }
                    .contextMenu {
                        
                        Button {
                            let device = showDevices[index]
                            Task {
                                await model.removeDevice(device: device)
                            }
                           
                        } label: {
                            Label("Remove", systemImage: "trash.slash")
                        }
                    }
                }
            }
            
        }
    }
    
    var emptyView: some View {
        VStack {
            Spacer()
            
            Button(action: {
                showSelectType = true
            }) {
                
                ZStack {
                    HStack {
                        Image(systemName: "plus.circle")
                            .foregroundColor(.white)
                            .font(.system(size: 20, weight: .regular))
                        Text("Add Device")
                            .foregroundColor(.white)
                            .font(.system(size: 14, weight: .regular))
                            .padding(.vertical, 10)
                    }
                    .padding(.horizontal, 60)
                    
                }
                .background(.philipsBlue)
                .cornerRadius(30)
            }
            .padding()
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
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
    DiscoverView()
        .environment(DeviceManager.shared)
        .environment(AppRouter.shared)
}
