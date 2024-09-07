//
//  GuideView.swift
//  eink
//
//  Created by Aaron on 2024/9/5.
//

import SwiftUI

struct GuideView: View {
    
    @EnvironmentObject var appConfig:AppConfiguration
    
    
    var pageCount:Int {SupportDevices.allCases.count}
    @State private var selection: Int = 0
    
    
    var body: some View {
        
        VStack(alignment:.leading){
            
            
            TabView(selection: $selection) {
                
                ForEach(Array(SupportDevices.allCases.enumerated()), id: \.element) {index, item in
                    OnboardingPageView(imageName: item.guideImage,
                                       description: item.guideTips,
                                       showDoneButton: index == pageCount-1,
                                       nextAction:
                                        (index < pageCount-1) ? goNext : {
                        appConfig.showOnboarding = false
                    }
                    )
                    .tag(index)
                }
                
                
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
        }
        
    }
    
    func goNext() {
        print("goNext")
        withAnimation {
            selection += 1
        }
    }
}

#Preview {
    GuideView()
}
