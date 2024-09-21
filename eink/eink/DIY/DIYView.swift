//
//  DIYView.swift
//  eink
//
//  Created by Aaron on 2024/9/15.
//

import SwiftUI

struct DIYView: View {
    
    let device:Device
    let model:Model = Model()
    
    @EnvironmentObject var alertManager: AlertManager
    @Environment(\.appRouter) var appRouter
    
    @State var colors:[String] = Array(repeating: "DBDBDB", count: 64)
    
    @State private var selectIndex:Int?
    
    @Binding var isPresented:Bool
    
    @State var currentColor:String?
    
    
    var hGirds:Int {
        device.deviceType.shape[0]
    }
    var vGirds:Int {
        device.deviceType.shape[1]
    }
    
    var hexString:String {
        colors.joined(separator: ",")
    }
    
    var randonName:String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ" // 包含大小写字母
            return String((0..<8).map { _ in letters.randomElement()! })
    }
    
    
    
    var body: some View {
        VStack{
            HStack {
                Button(action: {
                    isPresented = false
                }) {
                    Image(systemName: "chevron.down")
                        .foregroundColor(.plusbutton)
                }
                Spacer()
                Button(action: {
                    alertManager.showAlert(
                        message: "Are you sure to clear current design?",
                        confirmAction: {
                            colors = Array(repeating: "DBDBDB", count: 64)
                        }
                    )
                }) {
                    Image(systemName: "arrow.clockwise")
                        .foregroundColor(.plusbutton)
                }
            }
            .padding(.horizontal)
            Spacer()
            TriangleGridView(colors: colors, columns: hGirds, rows: vGirds, triangleSize: 50, onTouch: {index, isRepeat, preColor in
                
                guard let touchIndex = index else { return }
                guard currentColor != nil else {
                    alertManager.showAlert(
                        message: "Please select a paint color."
                    )
                    return
                }
                
                selectIndex = index
                print("selectIndex : \(touchIndex)")
                
                if let color = currentColor{
                    if isRepeat && preColor == currentColor {
                        colors[touchIndex] = "DBDBDB"
                        print("repeat reset color : DBDBDB")
                    } else {
                        print("TriangleGridView color : \(color)")
                        colors[touchIndex] = color
                    }
                    
                }
                
            })
            .clipCornerRadius(20)
//            .overlay(
//                RoundedRectangle(cornerRadius: 20)
//                    .stroke(.deviceItemShadow, lineWidth: 1)
//            )
            .shadow(color: .deviceItemShadow, radius: 5, x: 2, y: 2)

            Spacer()
            
            DIYPanel(colors:  [
                ("green", "497A64"),
                ("yellow", "DFBE24"),
                ("blue", "2B78B9"),
                ("black", "3F384A"),
                ("red", "A45942")
            ], onTouch: { color in
                    currentColor = color
                    guard let touchColor = color else {
                        selectIndex = nil
                        return
                    }
                    print("color : \(touchColor)")
                    if let index = selectIndex {
                    colors[index] = touchColor
                    }
                },
                onSave: {
                
                    CoreDataStack.shared.insetOrUpdateDesign(
                        name: randonName,
                        item: Design(deviceId: device.indentify,
                                     vGrids: vGirds,
                                     hGrids: hGirds,
                                     name: randonName,
                                     colors: hexString,
                                     favorite: false)
                    )
                    
                    isPresented = false
                },
                onEmploy: {
                    
                }
            )
            
        }
        .background(.white)
    }
}

#Preview {
    DIYView(device: DeviceManager().devices.first!, isPresented: .constant(false))
}
