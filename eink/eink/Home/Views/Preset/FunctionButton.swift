//
//  FunctionButton.swift
//  eink
//
//  Created by Aaron on 2025/7/8.
//
import SwiftUI
struct FunctionButton: View {
    let image: String
    let text: String
    let active: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                Image(systemName: image)
                    .font(.system(size: 24))
                    .foregroundColor(active ? .primary : .secondary)
                Text(text)
                    .font(.caption)
                    .foregroundColor(active ? .primary : .secondary)
            }
            .padding()
//            .background(Color(UIColor.systemBackground))
//            .cornerRadius(10)
        }
        .buttonStyle(PlainButtonStyle())
    }
}


#Preview {
    FunctionButton(image: "gear", text: "Settings", active: true) {
        print("Settings tapped")
    }
}


struct FunctionArea: View {
    let functions: [(image: String, text: String, active:Bool, action: () -> Void)]
    
    var body: some View {
        HStack(spacing: 20) {
            ForEach(functions, id: \.text) { function in
                FunctionButton(image: function.image, text: function.text, active: function.active, action: function.action)
                    .frame(maxWidth: .infinity)
                    
            }
        }
        .padding()
    }
}




