//
//  DIYView.swift
//  eink
//
//  Created by Aaron on 2024/9/15.
//

import SwiftUI

struct DIYView: View {
    
    let device:Device
    
    @State var colors:[String] = Array(repeating: "FFFFFF", count: 64)
    
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
            Spacer()
            TriangleGridView(colors: colors, columns: hGirds, rows: vGirds, triangleSize: 50, onTouch: {index in
                selectIndex = index
                print("selectIndex : \(index)")
                if let color = currentColor {
                    print("TriangleGridView color : \(color)")
                    colors[index] = color
                    
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
                print("color : \(color)")
                currentColor = color
                    if let index = selectIndex {
                        
                        colors[index] = color
                        
                    }
                }
                ,onSave: {
                
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
                }
                ,onEmploy: {
                    
                }
            )
            
        }
        .background(.white)
    }
}

#Preview {
    DIYView(device: DeviceManager().devices.first!, isPresented: .constant(false))
}
