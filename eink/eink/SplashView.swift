//
//  SplashView.swift
//  eink
//
//  Created by Aaron on 2025/7/3.
//

import SwiftUI

struct SplashView: View {
    @State private var isActive = false
    @State private var showFirstIcon = true

    var body: some View {
        if isActive {
            ContentView()
        } else {
            VStack {
                Spacer()
                Image(showFirstIcon ? .launchIcon1 : .launchIcon2)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 140, height: 140)
                
                Spacer()
                
                Image(.wordmark)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 140, height: 140)
                    .padding(.bottom, 50)
                
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.philipsBlue2)
            .onAppear {
                // Animation timer
                Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
                    showFirstIcon.toggle()
                }
                // Splash duration
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation {
                        isActive = true
                    }
                }
            }
        }
    }
}

#Preview {
    SplashView()
}
