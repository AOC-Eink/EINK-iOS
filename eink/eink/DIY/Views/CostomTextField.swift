//
//  CostomTextField.swift
//  eink
//
//  Created by Aaron on 2024/9/22.
//

import SwiftUI

struct CustomTextField: View {
    let placeholder: String
    @Binding var text: String
    @State private var isEditing = false
    
    var body: some View {
        VStack(alignment: .leading) {
            TextField(placeholder, text: $text, onEditingChanged: { editing in
                self.isEditing = editing
            })
            .padding(.all, 6)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isEditing ? Color.blue : Color.deviceItemShadow, lineWidth: 1)
            )
            
            if text.isEmpty {
                Text("This name cannot be empty")
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
    }
}

