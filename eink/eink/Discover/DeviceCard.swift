//
//  DeviceCard.swift
//  eink
//
//  Created by Aaron on 2024/9/6.
//

import SwiftUI

struct DeviceCard: View {
    
    let name:String
    let status:String
    let image:String
    
    
    var body: some View {
        
        
        VStack(alignment:.leading) {
            Text(name)
                .font(.deviceCount)
                .foregroundStyle(.mydevicestitle)
            
            Text(status)
                .font(.deviceCount)
                .foregroundStyle(.ekSubtitle)
            
            
            HStack(alignment:.top){
                Image(image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    //.padding()
                Spacer()
            }
            .padding(.leading, 10)
            .padding(.top, 1)
        }
        .padding()
        .background(Color.white) // 设置背景色
        .cornerRadius(10) // 设置圆角
        .shadow(color: .deviceItemShadow, radius: 5, x: 0, y: 0)
        .padding(.all, 5)
        .aspectRatio(4/3, contentMode: .fit)
        
        
        
    }
}

#Preview {
    DeviceCard(name: "E-INK Phone Case",
               status: "Unconnected",
               image: "eink.case.device")
}
