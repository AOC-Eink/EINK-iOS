//
//  GuideView.swift
//  eink
//
//  Created by Aaron on 2024/9/5.
//

import SwiftUI

struct GuideView: View {
    
    @EnvironmentObject var appConfig:AppConfiguration
    
    
    var body: some View {
        
        VStack(alignment:.leading){
            Text("Guide")
                .padding(.top, 100)
            
            Spacer()
            
            Button(action: {
                appConfig.showOnboarding = false
            }, label: {
                Text("Start")
            })
            .padding(.bottom, 100)
            
        }
        
        
    }
}

#Preview {
    GuideView()
}
