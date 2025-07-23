//
//  PresetGridView.swift
//  eink
//
//  Created by Aaron on 2024/9/9.
//

import SwiftUI
import CoreData
import AlertToast
import BLECommunicator

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
    
    @Environment(AppRouter.self) private var router
    @Environment(\.goDIYView) var goDIYView
    @State private var showToast = false
    @Environment(DeviceManager.self) var deviceManager
    @Environment(NFCCommunicator.self) var nfcCommunicator
    
    @Binding var isEditing: Bool
    
    
    let device:Device
    let designs:[Design]
    let pageType:PageType
    
    init(device: Device, designs: [Design] = [], pageType: PageType = .preset, isEditing: Binding<Bool>) {
        self.device = device
        self.designs = designs
        self.pageType = pageType
        self._isEditing = isEditing // 默认不编辑
    }
    
    func deleteAlert(_ name:String) {
        
        AlertWindow.showOKAndCancel(title: "Reminder",
                                    message: "Are you sure to delete this design",
                                    onTapOk: {
            try? CoreDataStack.shared.deleteDesignWithName(name: name)
        })
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
        
    
    func edit(_ design:Design) {
        goDIYView(design.colors.components(separatedBy: ",") ,design.name, design.favorite, design.category == "custom")
    }
    
    var body: some View {
        VStack(alignment:.leading){
            LazyVGrid(columns: device.gridLayout, spacing: 10) {
                ForEach(designs, id: \.self) { item in
                    PresetCard(title: item.name,
                               pageType:pageType,
                               device: device,
                               design: item,
                               
                               presetView: PresetView(colors: item.colors,
                                                      hGrids: Int(item.hGrids),
                                                      vGrides: Int(item.vGrids),
                                                      heightRatio: device.inkStyle.heightRatio,
                                                      inkStyle: device.inkStyle,
                                                      itemWidth:device.inkStyle.presetSize
                                                     ),
                               isEdit: $isEditing,
                        onTouch:{ action in
                        
                        if !isEditing {
                            router.navigate(to: .designDetail(deviceId: device.id, design: item))
                            return
                        }
                        
                          
                        
                                    
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
                            if item.favorite {
                                try? CoreDataStack.shared.deleteDesignWithNameAndId(name: item.name, pid: item.pid)
                            } else {
                                CoreDataStack.shared.insetFavoriteDesign(item: item)
                            }
                            
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

//#Preview {
//    PresetGridView(device: DeviceManager().showDevices.first!)
//}
