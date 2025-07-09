//
//  FavoriteView.swift
//  eink
//
//  Created by Aaron on 2024/9/4.
//

import SwiftUI
import Combine
import BLECommunicator

struct FavoriteView: View {
    
    let device:Device
    let designs:[Design]
    @State private var showBottomSheet = false
    @State private var timerCancellable: AnyCancellable?
    @State private var counter = 0
    @State private var selectDesins:[Design] = []
    @Environment(\.selectDesigns) private var selected
    @State private var showDeleteSheet = false
    
    @Environment(NFCCommunicator.self) var nfcCommunicator
    @Environment(DeviceManager.self) var deviceManager
    
    @Environment(AppRouter.self) private var router
    @State private var isEditing: Bool = false
    
    var body: some View {
        
        ZStack(alignment: .bottom) {
            ScrollView {
                PresetGridView(device: device, designs: designs, pageType: .select, isEditing: $isEditing)
                
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        isEditing.toggle()
                    }) {
                        Image(systemName: isEditing ? "app.badge.checkmark" : "ellipsis")
                            .foregroundColor(.plusbutton)
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text("Favorite")
                        .font(.navTitle)
                        .foregroundStyle(.mydevicestitle)
                    
                }
            }
            
            if isEditing {
                FunctionArea(functions: [
                    (image: "square.and.arrow.up", text: "Screen Cast", active: selectDesins.count == 1, action: {
                        
                        if (selectDesins.count == 1) {
                        
                            let design = selectDesins.first
                            let colors = design?.colors.components(separatedBy: ",")
                            guard let colors = colors, !colors.isEmpty else {
                                AlertWindow.show(title: "Error", message: "No colors found in the selected design.")
                                return
                            }
                        
                            Task{
                                await applay(colors)
                            }
                        }
                        
                    }),
                    (image: "timer", text: "Timing", active: selectDesins.count > 1, action: {
                        if (selectDesins.count > 1) {
                            router.presentSheet(.sendDesigns(deviceId: device.id, designs: selectDesins))
                        }
                        
                    }),
                    (image: "trash", text: "Delete", active: selectDesins.count > 0, action: {
                        //弹出底部sheet Confirm delete and cancel
                        if selectDesins.count > 0 {
                            showDeleteSheet = true
                        }
                        
                        
                    })
                ])
                .frame(height: 80)
                .frame(maxWidth: .infinity)
                .background(.ultraThinMaterial)
                .transition(.move(edge: .bottom))
                .animation(.easeInOut, value: isEditing)
            }
            
            
        }
        .sheet(isPresented: $showDeleteSheet) {
            VStack(spacing: 10) {
                //上面区域 按钮 “Confirm delete” 红色粗体 白色背景 全频幕宽度 高度45
                Button(action: {
                    // Confirm delete action
                    showDeleteSheet = false
                    if !selectDesins.isEmpty {
                        //router.deleteDesigns(selectDesins)
                        
                        selectDesins.removeAll()
                    }
                }) {
                    Text("Confirm Delete")
                        .font(.headline)
                        .foregroundColor(.red)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                }
                //下面区域 按钮 “Cancel” 白色背景 黑色粗体 全频幕宽度 高度45
                Color.gray.opacity(0.2)
                    .frame(height: 5)
                Button(action: {
                    showDeleteSheet = false
                }) {
                    Text("Cancel")
                        .font(.headline)
                        .foregroundColor(.black)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                }
            }
            .background(.white)
            .presentationDetents([.height(140)])
        }
        .environment(\.selectDesign) { design, isAdd in
            if isAdd {
                selectDesins.append(design)
            } else {
                if let index = selectDesins.firstIndex(where: {$0.name == design.name}) {
                    selectDesins.remove(at: index)
                }
                
            }
            
        }
        //
        //        .sheet(isPresented: $showBottomSheet) {
        //            PlaybackView(device: device, designs: designs, showBottomSheet: $showBottomSheet)
        //.presentationDetents([.height(400)])
        //.presentationDragIndicator(.visible)
        //                .cornerRadius(40, corners: [.topLeft, .topRight])
        //                .shadow(color: .deviceItemShadow, radius: 5, x: 1, y: -5)
        //        }
    }
        
    func applay(_ colors:[String]) async {
        
        if device.deviceType == .phoneCase {
            nfcCommunicator.startSession { result in
                switch result {
                case .success(let macAddress):
                    print("操作成功完成，MAC地址为: \(macAddress)")
                    //AlertWindow.show(title: "读取结果", message: "\(macAddress)")
                    Task {
                        await self.startScanAndConnect(mac: macAddress, colors: colors)
                    }
                    
                case .failure(let error):
                    print("操作失败: \(error.localizedDescription)")
                    AlertWindow.show(title: "Notify", message: error.localizedDescription)
                }
            }
        } else {
            await sendColors(device, colors)
        }
        
    }
    
    func startScanAndConnect(mac:String, colors:[String]) async {
        
        deviceManager.startScanning(mac) { device, success in
            
            if success {
                self.nfcCommunicator.updateSessionAlertMessage("Connect successfully")
                
                guard let connectDevice = device else {
                    self.nfcCommunicator.stopSession(message: "Connect failed, please try again")
                    return
                }
                Task {
                    await sendColors(connectDevice, colors)
                }
            } else {
                self.nfcCommunicator.stopSession(message: "Connect failed, please try again")
            }
        
        }
        
    }
    
    func sendColors(_ connectDevice:Device, _ colors:[String]) async {
        do {
            self.nfcCommunicator.updateSessionAlertMessage("Writing colors...")
            try await connectDevice.deviceFuction?.sendColors(connectDevice, commandType: .writeCmd, colors: [colors], timeInterval: nil, response: { response in
                //假设预期数据为 0x11FC0101 则成功写入 reponse 为Data 如何解析
                if response.count >= 4 {
                    let expectedData = Data([0x11, 0xFC, 0x01, 0x01])
                    if response.starts(with: expectedData) {
                        Logger.shared.log("图案写入成功")
                        self.nfcCommunicator.stopSession(message: "Patterns write success")
                        //self.showToast = true
                    } else {
                            Logger.shared.log("图案写入失败，返回数据不匹配")
                        self.nfcCommunicator.stopSession(message: "Patterns write failed")
                    }
                } else {
                    Logger.shared.log("图案写入失败，返回数据长度不足")
                    self.nfcCommunicator.stopSession(message: "Patterns write failed")
                }
            })

            
        } catch {
            AlertWindow.show(title: "Apply Failured", message: "\(error.localizedDescription)")
        }
    }
        
    
}

#Preview {
    FavoriteView(device: DeviceManager().showDevices.first!, designs: [])
}
