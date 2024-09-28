//
//  AddDeviceView.swift
//  eink
//
//  Created by Aaron on 2024/9/27.
//

import SwiftUI
import SwiftfulLoadingIndicators

struct AddDeviceView: View {
    
    let model:Model = Model()
    @Binding var showAddView:Bool
    @Environment(DeviceManager.self) var deviceManager
    
    init(showAddView: Binding<Bool>) {
        _showAddView = showAddView
        print("new init")
    }
    
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                VStack(alignment:.center) {
                    
                    Color.black
                        .frame(width: 80, height: 6)
                        .cornerRadius(3)
                        .onTapGesture {
                            Task{
                                model.addStatus = .scan
                                await model.stopScan()
                                withAnimation {
                                    showAddView = false
                                }
                            }
                            
                        }
                        .gesture(
                            DragGesture(minimumDistance: 5, coordinateSpace: .local)
                                    .onEnded { gesture in
                                        let verticalMovement = gesture.translation.height
                                        let threshold: CGFloat = 50 // 设置一个阈值来判断是否为有效的下滑

                                        if verticalMovement > threshold {
                                            Task{
                                                model.addStatus = .scan
                                                await model.stopScan()
                                                withAnimation {
                                                    showAddView = false
                                                }
                                            }
                                            
                                        }
                                    }
                        )
                        
                    Spacer()
                    switch model.addStatus {
                    case .scan, .scanNone, .descovered:
                        scanView
                    case .select:
                        connectDeviceView
                    case .adding:
                        addingView
                    case .addFail:
                        addFailView
                    case .addSuccess:
                        addSuccessView
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, minHeight: 200, maxHeight: 400)
                .background(.white)
                .cornerRadius(30, corners: [.topLeft, .topRight])
                .shadow(color: .deviceItemShadow, radius: 5, x: 2, y: -2)
                
            }
            
        }
        .ignoresSafeArea()
        .contentShape(Rectangle())
        .onChange(of: model.discoverDevices) { oldValue, newValue in
            print("newValue \(newValue.count) model.addStatus = \(model.addStatus)")
            if oldValue != newValue && newValue.count > 0 && model.addStatus == .scan {
                print("model.addStatus = .descovered")
                self.model.addStatus = .descovered
            }
        }
        .onAppear{
            print("onAppear")
            model.setManager(deviceManager)
            model.addStatus = .scan
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                Task{
                    await self.model.startScan()
                }
            })
        }
        .onChange(of: showAddView) { oldValue, newValue in
            print("showAddView = \(showAddView)")
            if newValue {
                model.addStatus = .scan
                model.setManager(deviceManager)
            }
        }
        
    }
    
    @ViewBuilder
    var addSuccessView:some View {
        VStack(spacing:30) {
            Image(systemName: "checkmark.circle")
                .resizable()
                .scaledToFill()
                .foregroundStyle(.designGreen)
                .frame(width: 100, height: 100)
                
            Text("Add Success")
                .font(.sectionBigTitle)
                .foregroundStyle(.sectionTitle)
        }
        .padding(.vertical, 50)
    }
    
    @ViewBuilder
    var addFailView:some View {
        VStack(spacing:30) {
            HStack{
                Button(action: {
                    model.addStatus = .scan
                },label: {
                    Image(systemName: "arrow.uturn.backward")
                        .foregroundStyle(.opButton)
                })
                Spacer()
            }
            Spacer()
            Text("Connect Failured")
                .font(.sectionBigTitle)
                .foregroundStyle(.sectionTitle)
            
            Button(action: {
                model.addStatus = .scan
                Task{
                    await model.startScan()
                }
                
            }, label: {
                Text("ReScan")
                    .padding(.horizontal)
                    .font(.sectionBigTitle)
                    .foregroundStyle(.white)
            })
            .frame(height: 40)
            .background(.opButton)
            .clipCornerRadius(20)
            Spacer()
        }
        .padding(.vertical)
        //.frame(maxHeight: .infinity, alignment: .top)
    }
    
    
    @ViewBuilder
    var addingView:some View {
        VStack(spacing:30) {
            LoadingIndicator(animation: .circleTrim, color: .opButton, size: .extraLarge)
            Text("Connecting...")
                .font(.sectionBigTitle)
                .foregroundStyle(.sectionTitle)
        }
        .padding(.vertical, 80)
    }
    
    @ViewBuilder
    var connectDeviceView:some View {
        VStack(spacing:20) {
            HStack{
                Button(action: {
                    model.addStatus = .descovered
                    Task{
                        await model.startScan()
                    }
                },label: {
                    Image(systemName: "arrow.uturn.backward")
                        .foregroundStyle(.opButton)
                })
                Spacer()
            }
            Image(model.selectDevice?.deviceImage ?? "")
                .resizable()
                .scaledToFit()
                .frame(height: 200)
            
            Text(model.selectDevice?.deviceName ?? "")
                .font(.sectionTitle)
                .foregroundStyle(.sectionTitle)
            
            Button(action: {
                model.addStatus = .adding
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    model.addStatus = .addSuccess
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        model.saveAdd()
                        model.addStatus = .scanNone
                        withAnimation {
                            showAddView = false
                        }
                    }
                }
            }, label: {
                Text("Add Device")
                    .padding(.horizontal)
                    .font(.sectionBigTitle)
                    .foregroundStyle(.white)
            })
            .frame(height: 40)
            .background(.opButton)
            .clipCornerRadius(20)
            
            
        }
        .padding()
    }
    
    
    @ViewBuilder
    var scanView: some View {
        VStack {
            Text("Select the accessories you want to add to \"My DIY\"")
                .padding(.horizontal, 30)
                .padding(.top, 20)
                .font(.sectionBigTitle)
                .multilineTextAlignment(.center)
                .foregroundStyle(.sectionTitle)
                
                
            
            Text("Make sure the accessory is powered on and nearby, or can be found.")
                .padding(.horizontal, 10)
                .font(.contentTitle)
                .multilineTextAlignment(.center)
                .foregroundStyle(.ekSubtitle)
                .padding(.top, 5)
            
            Spacer()
            if model.addStatus == .scan {
                LoadingIndicator(animation: .pulseOutline, color: .opButton, size: .extraLarge)
            } else if model.addStatus == .scanNone  {
                Text("Not accessories were be found, continue Scan?")
                    .padding(.horizontal, 30)
                    .padding(.top, 30)
                    .font(.sectionBigTitle)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.sectionTitle)
            } else if model.addStatus == .descovered {
                HStack {
                    Text("Other Equipment")
                        .padding(.leading, 10)
                        .font(.contentTitle)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.ekSubtitle)
                    LoadingIndicator(animation: .pulseOutline, color: .opButton, size:.small)
                    Spacer()
                }
                List{
                    ForEach(model.discoverDevices, id: \.indentify) { device in
                        Button(action: {
                            Task{
                                await model.stopScan()
                            }
                            model.addStatus = .select
                            model.selectDevice = device
                        }) {
                            Text(device.deviceName)
                                .font(.sectionTitle)
                                .foregroundStyle(.sectionTitle)
                                .frame(maxWidth: .infinity, alignment:.leading)
                        }
                        .background(.white)
                        .buttonStyle(.borderless)
                        
                    }
                }
                .background(.white)
                .listStyle(PlainListStyle())
                .clipCornerRadius(10)
                .shadow(color: .deviceItemShadow, radius: 2, x: 2, y: 1)
                .padding(.bottom, 20)
                
            }
            Spacer()
            
            
            if model.addStatus == .scan || model.addStatus == .scanNone {
                Button {
                    if model.addStatus == .scanNone {
                        model.addStatus = .scan
                        model.setManager(deviceManager)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                            Task{
                                await self.model.startScan()
                            }
                        })
                        
                    } else {
                        model.addStatus = .descovered
                    }
                    
                } label: {
                    Text(model.addStatus == .scanNone ? "Scan":"Searching")
                        .foregroundStyle(model.addStatus == .scanNone ? .white : .opButton)
                        .padding(.all, 5)
                }
                .frame(width: 120, height: 40)
                .background(model.addStatus == .scanNone ? .opButton : .white)
                .clipCornerRadius(20)
                .padding(.bottom, 20)
            }
        }
        
    }
    
}

#Preview {
    AddDeviceView(showAddView: .constant(true))
}
