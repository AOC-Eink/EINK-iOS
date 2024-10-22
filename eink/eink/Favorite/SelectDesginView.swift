//
//  SelectDesginView.swift
//  eink
//
//  Created by Aaron on 2024/10/22.
//

import SwiftUI

struct SelectDesginView: View {
    
    let device:Device
    let designs:[Design]
    
    @State private var selectDesins:[Design] = []
    @Binding var showAddView:Bool
    @Environment(\.selectDesigns) private var selected
    
    var body: some View {
        VStack{
            
            ScrollView {
                PresetGridView(device: device, designs: designs, pageType: .select)
            }
            .padding(.all, 6)
            
            HStack{
                
                Text("已选择 \(selectDesins.count) 个图案")
                    .font(.sectionBoldTitle)
                    .foregroundStyle(.sectionTitle)
                    
                
                Spacer()
                Button {
                    selected(selectDesins)
                    showAddView.toggle()
                } label: {
                    Text("完成")
                        .font(.sectionBoldTitle)
                        .foregroundStyle(.opButton)
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .trailing)
                }

            }
            .padding(.horizontal)
            .frame(height: 44)
            
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
    }
}

//#Preview {
//    SelectDesginView()
//}
