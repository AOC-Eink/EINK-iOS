//
//  RoundedBorderModifier.swift
//  eink
//
//  Created by Aaron on 2024/9/22.
//

import SwiftUI

struct RoundedBorderModifier: ViewModifier {
    let cornerRadius: CGFloat
    let borderWidth: CGFloat
    let borderColor: Color
    let isCircle:Bool
    
    func body(content: Content) -> some View {
        content
            
            .clipShape(CircleOrRoundedRectangle(isCircle: isCircle, cornerRadius: cornerRadius))
            .overlay(
                CircleOrRoundedRectangle(isCircle: isCircle, cornerRadius: cornerRadius)
                    .stroke(borderWidth > 0 ? borderColor : .clear, lineWidth: borderWidth)
            )
            .shadow(color: .deviceItemShadow, radius: 5, x: 2, y: 2)
    }
}

extension View {
    func roundedBorder(
        cornerRadius: CGFloat,
        borderWidth: CGFloat = 0,
        borderColor: Color = .black,
        isCircle: Bool = false
    ) -> some View {
        self.modifier(RoundedBorderModifier(
            cornerRadius: cornerRadius,
            borderWidth: borderWidth,
            borderColor: borderColor, 
            isCircle: isCircle
        ))
    }
}

struct CircleOrRoundedRectangle: Shape {
    var isCircle: Bool
    var cornerRadius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        if isCircle {
            return Circle().path(in: rect)
        } else {
            return RoundedRectangle(cornerRadius: cornerRadius).path(in: rect)
        }
    }
}

