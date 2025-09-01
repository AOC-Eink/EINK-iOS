//
//  DIYView.Model.swift
//  eink
//
//  Created by Aaron on 2024/9/21.
//

import Foundation
import BLECommunicator

    
    @Observable
    class DIYViewModel {
        
        let device:Device
        var colors:[String]
        let diyName:String
        let initFavorite:Bool
        private let deviceManager:DeviceManager
        private let nfcCommunicator:NFCCommunicator
        //定义一个可以绑定View的 binding 属性
        var showToast:Bool = false
        
        init(_ device: Device,
             _ deviceManager:DeviceManager,
             _ nfcCommunicator:NFCCommunicator,
             name:String = "", colors:[String] = [], favorite:Bool = false) {
            self.device = device
            self.diyName = name
            self.colors = colors == [] ? Array(repeating: "DBDBDB", count: device.inkCounts) : colors
            self.initFavorite = favorite
            self.deviceManager = deviceManager
            self.nfcCommunicator = nfcCommunicator
        }
        
        let panelColors = [("green", "497A64"),
                           ("yellow", "DFBE24"),
                           ("blue", "2B78B9"),
                           ("black", "3F384A"),
                           ("red", "A45942"),
                           ("off", "DBDBDB")
        ]
        
        var hGirds:Int {
            device.deviceType.shape[0]
        }
        var vGirds:Int {
            device.deviceType.shape[1]
        }
        
        var itemWidth:CGFloat {
            device.inkStyle.itemWidth
        }
        
        var hexString:String {
            colors.joined(separator: ",")
        }
        
        
        
        func clearDesgin() {
            colors = Array(repeating: "DBDBDB", count: device.inkCounts)
        }
        
        func saveDesgin(_ name:String, _ isFavorite:Bool) {
            debugPrint("\(name)\":\"\(hexString)")
            let design = Design(pid: device.devicePidString,
                               vGrids: vGirds,
                               hGrids: hGirds,
                               name: name,
                               colors: hexString,
                               favorite: isFavorite,
                               category: "custom")
            
            CoreDataStack.shared.insetOrUpdateDesign(
                name: name,
                item: design
            )
            
            if isFavorite {
                CoreDataStack.shared.insetFavoriteDesign(item: design)
            }
            else {
                try? CoreDataStack.shared.deleteDesignWithNameAndId(name: name, pid: device.devicePidString)
            }
        }
        
        
        
        
        
        var randonName:String {
            let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ" // 包含大小写字母
                return String((0..<8).map { _ in letters.randomElement()! })
        }
        
//        func applay(_ response:@escaping(Bool)->Void) async throws {
//            //showToast.toggle()
//        
//            try await device.deviceFuction?.sendColors(device, commandType: .writeCmd, colors: [colors], timeInterval: nil, response: { _ in
//                debugPrint("Colors sent successfully")
//                response(true)
//            })
//            
//            
//        }
        
        func applay() async {
            if (device.bleDevice?.peripheral.state == .connected) {
                self.nfcCommunicator.updateSessionAlertMessage("Connected Wirte")
                await sendColors(device, colors)
                return
            }
            
            if device.deviceType == .phoneCase {
                nfcCommunicator.startSession { result in
                    switch result {
                    case .success(let macAddress):
                        print("操作成功完成，MAC地址为: \(macAddress)")
                        //AlertWindow.show(title: "读取结果", message: "\(macAddress)")
                        Task {
                            await self.startScanAndConnect(mac: macAddress, colors: self.colors)
                        }
                        
                    case .failure(let error):
                        print("操作失败: \(error.localizedDescription)")
                        //AlertWindow.show(title: "Notify", message: error.localizedDescription)
                    }
                }
            } else {
                await sendColors(device, colors)
            }
            
        }
        
        func startScanAndConnect(mac:String, colors:[String]) async {
            
            deviceManager.startScanning(mac) {[weak self] device, success in
                guard let self = self else { return }
                
                if success {
                    self.nfcCommunicator.updateSessionAlertMessage("Connect successfully")
                    
                    guard let connectDevice = device else {
                        self.nfcCommunicator.stopSession(message: "Connect failed, please try again")
                        return
                    }
                    Task {
                        await self.sendColors(connectDevice, colors)
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
                            
                        } else {
                                Logger.shared.log("图案写入失败，返回数据不匹配")
                            self.nfcCommunicator.stopSession(message: "Patterns write failed")
                        }
                    } else {
                        Logger.shared.log("图案写入失败，返回数据长度不足")
                        self.nfcCommunicator.stopSession(message: "Patterns write failed")
                    }
                })
                showToast = true

                
            } catch {
                //AlertWindow.show(title: "Apply Failured", message: "\(error.localizedDescription)")
            }
        }
        
        
    }

