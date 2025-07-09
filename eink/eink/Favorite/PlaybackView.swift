//
//  PlaybackView.swift
//  eink
//
//  Created by Aaron on 2024/10/12.
//

import SwiftUI
import AlertToast
import BLECommunicator

enum PlaybackMode {
    case stopPlayback
    case singlePlayback
    case allPlayback
    case randomPlayback
}

struct PlaybackView: View {
    @Environment(AppRouter.self) private var router
    
    let device:Device
    let designs:[Design]
    //@Binding var showBottomSheet:Bool
    @State private var showToast = false
    @State private var showAddView = false
    
    @State private var isToggleOn = true
    @State private var selectedMinutes = 0
    @State private var selectedSeconds = 0
    @State private var selectedMode: PlaybackMode = .singlePlayback
    @Environment(NFCCommunicator.self) var nfcCommunicator
    @Environment(DeviceManager.self) var deviceManager
    //@State private var selectDesgins:[Design] = []
    
    
    var commandType:CommandType {
        if isToggleOn {
            
            switch selectedMode {
            case .stopPlayback:
                return .stopCmd
            case .singlePlayback:
                return .writeCmd
            case .allPlayback:
                return .recycleCmd
            case .randomPlayback:
                return .randomCmd
            }
            
        } else {
            return .stopCmd
        }
    }
    
    
    var body: some View {
        VStack(spacing: 20) {
            
//            VStack(alignment:.leading){
//                Button {
//                    showBottomSheet.toggle()
//                } label: {
//                    Text("Cancel")
//                        .font(.sectionBoldTitle)
//                        .foregroundStyle(.opButton)
//                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
//                }
//                Spacer()
//
//            }
//            .frame(height: 44)
            
            
            //deviceInfoSection
            
//            if selectDesgins.isEmpty {
//                VStack{
//                    Spacer()
//                    Button(action: {
//                        showAddView = true
//                    }) {
//                        Image(systemName: "plus.app.fill")
//                            .resizable()
//                            .frame(width: 40, height: 40)
//                            .foregroundColor(.opButton)
//                            .clipShape(Circle())
//                    }
//                    .padding()
//                    
//                    
//                    Text("请添加播放图案")
//                        .padding()
//                    Spacer()
//                    
//                }
//            } else {
//                playbackListView
//            }
            
            
            //Spacer()
            
            controlButtonsSection
            scheduledPlaybackSection
            timePickerSection
            actionButtonsSection
        }
        .padding()
        //.padding(.top, 10)
        .background(.white)
        .toast(isPresenting: $showToast, duration: 1, alert: {
            AlertToast(type: .systemImage("checkmark.circle", .opButton), title: "Message Sent!")
        }, completion: {
            showToast = false
            //showBottomSheet.toggle()
        })
        .sheet(isPresented: $showAddView) {
            SelectDesginView(device: device, designs: designs, showAddView: $showAddView)
        }
//        .environment(\.selectDesigns) { designs in
//            selectDesgins = designs
//        }

        
        
    }
    
    var totalSeconds:Int {
        if selectedMinutes == 0 && selectedSeconds == 0 {
            return 1
        }
        return selectedMinutes*60 + selectedSeconds
    }
    
//    private var playbackListView: some View {
//        List{
//            ForEach(selectDesgins, id: \.self) { design in
//                Text(design.name)
//                    .font(.sectionTitle)
//                    .foregroundStyle(.sectionTitle)
//                    .frame(maxWidth: .infinity, alignment:.leading)
//                    .background(.white)
//                    .buttonStyle(.borderless)
//                
//            }
//            .onDelete(perform: deleteItem)
//        }
//        .background(.white)
//        .listStyle(PlainListStyle())
//        .clipCornerRadius(10)
//        .shadow(color: .deviceItemShadow, radius: 2, x: 2, y: 1)
//        .padding(.bottom, 20)
//        
//    }
    
//    func deleteItem(at offsets: IndexSet) {
//        selectDesgins.remove(atOffsets: offsets)
//    }
    
    private var deviceInfoSection: some View {
        HStack{
            
            Image(device.deviceImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 20, height: 20)
                .background(.deviceItemShadow)
            VStack(alignment: .leading, spacing: 5) {
                Text("Current playback device")
                    .font(.headline)
                Text(device.deviceName)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        
    }
    
    private var controlButtonsSection: some View {
        HStack {
            ForEach([
                   //(PlaybackMode.singlePlayback, "arrow.clockwise"),
                   (PlaybackMode.allPlayback, "arrow.2.circlepath"),
                   (PlaybackMode.randomPlayback, "arrow.right.arrow.left")
               ], id: \.0) { mode, iconName in
                   Button(action: {
                       selectedMode = mode
                   }) {
                       Image(systemName: iconName)
                           .foregroundColor(selectedMode == mode ? .white : .gray)
                           .frame(width: 50, height: 30)
                           .background(selectedMode == mode ? .opButton : .white)
                           .cornerRadius(20)
                           .shadow(color: .deviceItemShadow, radius: 2, x: 0, y: 0)
                   }
               }
            Spacer()
            Toggle("", isOn: $isToggleOn)
                .labelsHidden()
                .toggleStyle(ColoredToggleStyle())
                .onChange(of: isToggleOn) { old, new in
                    if !new {
                        selectedMode = .stopPlayback
                        Logger.shared.log("--已停止播放--")
                    }
                }
            
                
        }
    }
    
    private var scheduledPlaybackSection: some View {
        Text("Scheduled playback")
            .font(.headline)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var timePickerSection: some View {
        HStack(spacing: 20) {
            timePicker(for: $selectedMinutes, label: "min")
            Text("|").foregroundColor(.gray)
            timePicker(for: $selectedSeconds, label: "s")
        }
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
    
    private func timePicker(for binding: Binding<Int>, label: String) -> some View {
        VStack {
            Text(label)
                .font(.sectionBoldTitle)
                .foregroundColor(.gray)
            Picker("", selection: binding) {
                ForEach(0..<60) { value in
                    Text("\(value)").tag(value)
                }
            }
            .pickerStyle(WheelPickerStyle())
            .frame(maxHeight: .infinity)
            .clipped()
        }
        .padding()
    }
    
    private var actionButtonsSection: some View {
        HStack(spacing:40) {
            CustomButton(title: "Cancel", bgColor: designs.isEmpty ? .philipsBlue : .deviceItemShadow) {
                //showBottomSheet.toggle()
                router.dismissSheet()
            }

            CustomButton(title: "Confirm", bgColor: designs.isEmpty ? .deviceItemShadow : .philipsBlue) {
                
//                if designs.isEmpty {
//                    return
//                }
//                Logger.shared.log("--点击 Confirm 发送--")
//                if showToast { return }
//                Logger.shared.log("--点击 Confirm 发送 222-- \(device.bleDevice?.name ?? "Unknown")")
//                if let _ = device.bleDevice?.writeCharacteristic {
//                    Logger.shared.log("--存在写特证 Confirm 发送 333--")
//                    
//                    Task {
//                        Logger.shared.log("--存在写特证 Confirm 发送--")
//                        let colors = designs.map { design in
//                            design.colors.split(separator: ",").map(String.init)
//                        }
//                        
//                        await applay(colors)
//                        
//                    }
//                } else {
//                    Logger.shared.log("--不存在写特证 Confirm 发送 333--")
//                    AlertWindow.show(title: "Reminder", message: "设备异常，请重新连接。") {
//                        //appRouter.isConnected = false
//                    }
//                }
                Task {
                    Logger.shared.log("--Confirm 发送--")
                    let colors = designs.map { design in
                        design.colors.split(separator: ",").map(String.init)
                    }
                    
                    await applay(colors)
                    
                }
            }
        }
    }
    
    func applay(_ colors:[[String]]) async {
        
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
    
    func startScanAndConnect(mac:String, colors:[[String]]) async {
        
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
    
    func sendColors(_ connectDevice:Device, _ colors:[[String]]) async {
        do {
            self.nfcCommunicator.updateSessionAlertMessage("Writing colors...")
            try await connectDevice.deviceFuction?.sendColors(connectDevice, commandType: .writeCmd, colors: colors, timeInterval: nil, response: { response in
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
    


struct ColoredToggleStyle: ToggleStyle {
    var onColor: Color = .opButton
    var offColor: Color = .deviceItemShadow
    var thumbColor: Color = .white
    
    func makeBody(configuration: Configuration) -> some View {
        Button(action: { configuration.isOn.toggle() }) {
            RoundedRectangle(cornerRadius: 16, style: .circular)
                .fill(configuration.isOn ? onColor : offColor)
                .frame(width: 50, height: 29)
                .overlay(
                    Circle()
                        .fill(thumbColor)
                        .shadow(radius: 1, x: 0, y: 1)
                        .padding(1.5)
                        .offset(x: configuration.isOn ? 10 : -10)
                )
                .animation(.easeInOut(duration: 0.2), value: configuration.isOn)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    PlaybackView(device: Device(indentify: "", deviceName: "EINK Phone Case"), designs: [])
        .environment(AppRouter.shared)
}
