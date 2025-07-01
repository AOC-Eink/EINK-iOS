//
//  PresetGridView.swift
//  eink
//
//  Created by Aaron on 2024/9/9.
//

import SwiftUI
import CoreData
import AlertToast

enum EditAction {
    case apply
    case edit
    case favorite
    case delete
    
    
    var titleName:String {
        switch self {

        case .apply:
            return "Apply"
        case .edit:
            return "Edit"
        case .favorite:
            return "Favorite"
        case .delete:
            return "Delete"
        }
    }
}

enum PageType {
    case preset
    case custom
    case category
    case favorite
    case select
}

struct PresetGridView: View {
    
    @Environment(\.appRouter) var appRouter
    @Environment(\.goDIYView) var goDIYView
    @State private var showToast = false
    @Environment(DeviceManager.self) var deviceManager
    @Environment(NFCCommunicator.self) var nfcCommunicator
    
    
    let device:Device
    let designs:[Design]
    let pageType:PageType
    
    init(device: Device, designs: [Design] = [], pageType: PageType = .preset, sectionName:String = "") {
        self.device = device
        self.designs = designs
        self.pageType = pageType
        self.sectionName = sectionName
    }
    
    func deleteAlert(_ name:String) {
        
        AlertWindow.showOKAndCancel(title: "Reminder",
                                    message: "Are you sure to delete this design",
                                    onTapOk: {
            try? CoreDataStack.shared.deleteDesignWithName(name: name)
        })
    }
    
    func applay(_ colors:[String]) async {
        

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
                AlertWindow.show(title: "读取失败", message: error.localizedDescription)
            }
        }
        
    }
    
    func startScanAndConnect(mac:String, colors:[String]) async {
        
        deviceManager.startScanning(mac) { device, success in
            
            if success {
                self.nfcCommunicator.updateSessionAlertMessage("连接成功，准备写入图案")
                
                guard let connectDevice = device else {
                    self.nfcCommunicator.stopSession(message: "连接失败，请重试")
                    return
                }
                Task {
                    await sendColors(connectDevice, colors)
                }
            } else {
                self.nfcCommunicator.stopSession(message: "连接失败，请重试")
            }
        
        }
        
    }
    
    func sendColors(_ connectDevice:Device, _ colors:[String]) async {
        do {
            try await connectDevice.deviceFuction?.sendColors(connectDevice, commandType: .writeCmd, colors: [colors], timeInterval: nil)
            self.nfcCommunicator.updateSessionAlertMessage("图案写入中，请稍等...")
            //延时10秒钟后关闭NFC会话
            try await Task.sleep(nanoseconds: 30_000_000_000) // 10 seconds
            self.nfcCommunicator.stopSession(message: "图案写入完成")
            
        } catch {
            AlertWindow.show(title: "Apply Failured", message: "\(error.localizedDescription)")
        }
    }
        
    
    func edit(_ design:Design) {
        goDIYView(design.colors.components(separatedBy: ",") ,design.name, design.favorite, design.category == "custom")
    }
    
    let sectionName:String
    
    var body: some View {
        VStack(alignment:.leading){
            
            if !sectionName.isEmpty {
                Text(sectionName)
                    .padding(.leading, 10)
                    .font(.sectionBoldTitle)
                    .foregroundStyle(.sectionTitle)
            }
            
            
            LazyVGrid(columns: device.gridLayout, spacing: 10) {
                ForEach(designs, id: \.self) { item in
                    PresetCard(title: item.name,
                               pageType:pageType,
                               design: item,
                               
                               presetView: PresetView(colors: item.colors,
                                                      hGrids: Int(item.hGrids),
                                                      vGrides: Int(item.vGrids),
                                                      heightRatio: device.inkStyle.heightRatio,
                                                      inkStyle: device.inkStyle, 
                                                      itemWidth:device.inkStyle.presetSize
                                                     ),
                        onTouch:{ action in
                                    
                        switch action {
                            
                        case .apply:
                            Task{
                                await applay(item.colors.components(separatedBy: ","))
                            }
                            
                        case .edit:
                            edit(item)
                        case .delete:
                            deleteAlert(item.name)
                        case .favorite:
                            break
                        }
                                
                       }
                        
                               
                    )
                    
                }
            }
            
        }
        .padding()
        .toast(isPresenting: $showToast) {
            AlertToast(type: .complete(.designGreen), title: "Apply Success")
        }
        
    }
}

#Preview {
    PresetGridView(device: DeviceManager().showDevices.first!)
}
