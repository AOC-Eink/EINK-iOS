//
//  OnboardingView.swift
//  eink
//
//  Created by Aaron on 2024/9/6.
//

import SwiftUI

struct OnboardingPageView: View {
    let imageName: String
    var title: String?
    let description: String
    let showDoneButton: Bool
    var nextAction: (() -> Void)?
    
    var body: some View {
        
        VStack(alignment:.center) {


            Spacer()
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                //.frame(height: 250)
                .foregroundColor(.mint)
            
            Spacer()

            if let showTitle = title {
                Text(showTitle)
                    .font(.title3)
                    .fontWeight(.light)
            }
            
            
            Text(description)
                .font(.title2)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .padding(.bottom, showDoneButton ? 0:50)
                .foregroundColor(.gray)
            
            if showDoneButton {
                Button("Lets get started") {
                    nextAction?()
                }
                .buttonStyle(.bordered)
                .padding(.top)
                .padding(.bottom, 50)
                
            }
        }
        .padding()
    }
}

#Preview {
    OnboardingPageView(imageName: "eink.clock.tour",
                       description: "Display personalized Electronic Paper",
                       showDoneButton: true)
}
