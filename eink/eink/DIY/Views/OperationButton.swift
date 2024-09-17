//
//  OperationButton.swift
//  eink
//
//  Created by Aaron on 2024/9/15.
//

import SwiftUI

import SwiftUI

struct CustomButton: View {
    let title: String
    var bgColor: Color = .opButton
    var action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        
        Button(action: {
            withAnimation(.easeInOut(duration: 0.1)) {
                self.isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    self.isPressed = false
                }
                self.action()
            }
        }) {
            Text(title)
                .font(.sectionTitle)
                .foregroundColor(.white)
                .padding(.horizontal)
                .padding(.vertical, 10)
                .frame(minWidth: 0, maxWidth: .infinity)
                .background(bgColor)
                .cornerRadius(10)
//                .overlay(
//                    RoundedRectangle(cornerRadius: 10)
//                        .stroke(Color.white, lineWidth: 2)
//                )
        }
        .shadow(color: .gray.opacity(0.4), radius: 5, x: 0, y: 5)
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .offset(y: isPressed ? 2 : 0)
        
    }
}


#Preview {
    CustomButton(title: "Press Me") {
        print("Button pressed!")
    }
    .padding()
}
