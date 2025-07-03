//
//  SplashView.swift
//  eink
//
//  Created by Aaron on 2025/7/3.
//

import SwiftUI

struct SplashView: View {
    @State private var isActive = false

    var body: some View {
        if isActive {
            ContentView()
        } else {
            VStack {
                //set image to center
                Image(.philipsIcon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 140, height: 140)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.philipsBlue)
            .onAppear {
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
