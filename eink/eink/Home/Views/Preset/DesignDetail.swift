//
//  DesignDetail.swift
//  eink
//
//  Created by Aaron on 2025/7/8.
//

//
//  DIYView.swift
//  eink
//
//  Created by Aaron on 2024/9/15.
//

import SwiftUI
import BLECommunicator
import AlertToast

struct DesignDetail: View {
    
    let device: Device
    let design: Design
    
    @Environment(AppRouter.self) private var router
    @Environment(NFCCommunicator.self) var nfcCommunicator
    @Environment(DeviceManager.self) var deviceManager
    @State private var showToast = false
    @Environment(\.displayScale) var displayScale
    
    var itemDesignWidth:CGFloat {
        device.inkStyle.itemWidth
    }
    
    var hGirds:Int {
        device.deviceType.shape[0]
    }
    var vGirds:Int {
        device.deviceType.shape[1]
    }
    
    var itemWidth: CGFloat {
        let baseWidth: CGFloat = itemDesignWidth
        
        switch displayScale {
        case 1:
            return baseWidth*0.5
        case 2:
            return baseWidth*0.67
        case 3:
            return baseWidth
        default:
            return baseWidth
        }
    }
    
    var colors:[String] { design.colors.components(separatedBy: ",")}
    
    var name:String {design.name}
    
    
    var body: some View {
        VStack{
            //topbarView
            Spacer()
            
            ZStack(alignment:.topLeading){
                
                
                
                TriangleGridView(colors: colors,
                                 columns: hGirds,
                                 rows: vGirds,
                                 triangleSize: itemWidth,
                                 heightRatio: device.heightRatio,
                                 onTouch: {index, isRepeat, preColor in
                    
                })
                .roundedBorder(cornerRadius: device.inkStyle.cornerRadius*0.8,
                               borderWidth: device.inkStyle.borderWidth,
                               borderColor: device.inkStyle.borderColor,
                               isCircle: device.inkStyle.isCircle
                )
                
                if device.deviceType == .phoneCase {
                    
                    Image(.iphoneCamera)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 130, height: 130)
                        .padding(.leading, -3)
                        .padding(.top, -3)
                }
            }
                
            
            

            Spacer()
            
            HStack(spacing:50) {
            
                CustomButton(title: "Screen Cast", icon: "square.and.arrow.up") {
                    Task{
                        await applay(colors)
                    }
                }
                
                CustomButton(title: "Derivative", icon: "pawprint.circle") {
                    router.navigate(to: .customize(deviceId: device.id, name: "New Design", colors: colors, favorite: false))
                }
                
            }
            .padding(.horizontal, 27)
            
            Spacer()
            
            
        }
        .navigationTitle(name)
        .background(.white)
        .onChange(of: device.bleStatus) { oldValue, newValue in
            print("Device status changed from \(oldValue) to \(newValue)")
            if newValue == .disconnected {
                DeviceManager.shared.startScanning(discover: nil)
                router.navigateToRoot()
            }
        }
        .toast(isPresenting: $showToast, duration: 1, alert: {
            AlertToast(type: .systemImage("checkmark.circle", .opButton), title: "Message Sent!")
        }, completion: {
            showToast = false
            //showBottomSheet.toggle()
        })
    }
    
    func applay(_ colors:[String]) async {
        
        Logger.shared.log("Apply colors: start")
        if (device.bleDevice?.peripheral.state == .connected) {
            self.nfcCommunicator.updateSessionAlertMessage("Connected Wirte")
            await sendColors(device, colors)
            return
        }
        if device.deviceType == .phoneCase {
            nfcCommunicator.startSession { result in
                switch result {
                case .success(let macAddress):
                    Logger.shared.log("操作成功完成，MAC地址为: \(macAddress)")
                    //AlertWindow.show(title: "读取结果", message: "\(macAddress)")
                    
                    
                    Task {
                        await self.startScanAndConnect(mac: macAddress, colors: colors)
                        
                    }
                    
                case .failure(let error):
                    Logger.shared.log("操作失败: \(error.localizedDescription)")
                    AlertWindow.show(title: "Notify", message: error.localizedDescription)
                }
            }
        } else {
            await sendColors(device, colors)
        }
        
    }
    
    func startScanAndConnect(mac:String, colors:[String]) async {
        
        deviceManager.startScanning(mac) { device, success in
            Logger.shared.log("connect result: \(success), device: \(String(describing: device))")
            
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
            showToast = true
            
        } catch {
            AlertWindow.show(title: "Apply Failured", message: "\(error.localizedDescription)")
        }
    }
    
}

//#Preview {
//    DIYView(model: DIYViewModel(DeviceManager.shared.showDevices.last!), isPresented: .constant(false))
//}
