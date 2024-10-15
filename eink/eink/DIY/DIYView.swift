//
//  DIYView.swift
//  eink
//
//  Created by Aaron on 2024/9/15.
//

import SwiftUI

struct DIYView: View {
    
    let model:Model
    
    @Environment(\.appRouter) var appRouter
    
    
    @State private var selectIndex:Int?
    
    @Binding var isPresented:Bool
    
    @State var currentColor:String?
    
    @Environment(\.displayScale) var displayScale
    
    var itemWidth: CGFloat {
        let baseWidth: CGFloat = model.itemWidth
        
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
    
    var body: some View {
        VStack{
            topbarView
            Spacer()
            ZStack(alignment:.topLeading){
                
                TriangleGridView(colors: model.colors,
                                 columns: model.hGirds,
                                 rows: model.vGirds,
                                 triangleSize: itemWidth,
                                 heightRatio: model.device.heightRatio,
                                 onTouch: {index, isRepeat, preColor in
                    
                    guard let touchIndex = index else { return }
                    guard currentColor != nil else {
                        AlertWindow.show(title: "Reminder", message: "Please select a paint color.")
                        return
                    }
                    
                    selectIndex = index
                    print("selectIndex : \(touchIndex)")
                    
                    if let color = currentColor{
                        if isRepeat || preColor == color {
                            if preColor == "DBDBDB" {
                                model.colors[touchIndex] = color
                            } else {
                                model.colors[touchIndex] = "DBDBDB"
                            }
                            
                            print("repeat reset color : DBDBDB")
                            
                        } else {
                            print("TriangleGridView color : \(color)")
                            model.colors[touchIndex] = color
                        }
                        
                    }
                    
                })
                .roundedBorder(cornerRadius: model.device.inkStyle.cornerRadius,
                               borderWidth: model.device.inkStyle.borderWidth,
                               borderColor: model.device.inkStyle.borderColor,
                               isCircle: model.device.inkStyle.isCircle
                )
                
            }
            

            Spacer()
            colorPanel
        }
        .background(.white)
    }
    
    @ViewBuilder
    var topbarView: some View {
        HStack {
            Button(action: {
                isPresented = false
            }) {
                Image(systemName: "chevron.down")
                    .foregroundColor(.plusbutton)
            }
            Spacer()
            Button(action: {
                AlertWindow.showOKAndCancel(title: "Reminder",
                                            message: "Are you sure to clear current design?",
                                            onTapOk: {
                    model.clearDesgin()
                })
            }) {
                Image(systemName: "arrow.clockwise")
                    .foregroundColor(.plusbutton)
            }
        }
        .padding(.horizontal)
    }
    
    @ViewBuilder
    var colorPanel: some View {
        DIYPanel(colors: model.panelColors,
                 name: model.diyName, 
                 initFavorite: model.initFavorite,
                 onTouch: { color in
                currentColor = color
                guard let touchColor = color else {
                    selectIndex = nil
                    return
                }
                print("color : \(touchColor)")
                if let index = selectIndex {
                    model.colors[index] = touchColor
                }
            },
            onSave: { isFavorite, name in
                
                model.saveDesgin(name, isFavorite)
                
                isPresented = false
            },
            onEmploy: {
            
                Task{
                    do {
                        try await model.applay()
                    } catch  {
                        await AlertWindow.show(title: "Apply failured", message: "\(error.localizedDescription)")
                    }
                    
                }
            }
        )
    }
}

#Preview {
    DIYView(model: DIYView.Model(DeviceManager().showDevices.last!), isPresented: .constant(false))
}
