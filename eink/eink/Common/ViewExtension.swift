//
//  ViewExtension.swift
//  eink
//
//  Created by Aaron on 2024/9/13.
//

import Foundation
import SwiftUI

struct RoundedRightAngleTriangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let curveSize: CGFloat = 13.0 // 控制曲线大小
        
        // 三角形的三个顶点
        let topLeft = CGPoint(x: rect.minX, y: rect.minY)
        let TopRight = CGPoint(x: rect.maxX, y: rect.minY)
        let bottomRight = CGPoint(x: rect.maxX, y: rect.maxY)
        
        // 开始绘制路径
        path.move(to: topLeft)
        
        // 添加到右上角的线
        path.addLine(to: CGPoint(x: TopRight.x, y: TopRight.y - curveSize))
    
        
        // 添加到右下角的线
        path.addLine(to: bottomRight)
        
        // 完成闭合路径
        path.closeSubpath()
        
        return path
    }
}

struct TopBottomInsetShape: Shape {
    let topInset: CGFloat
    let bottomInset: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY + topInset))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + topInset))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - bottomInset))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY - bottomInset))
        path.closeSubpath()
        return path
    }
}

extension View {
    func clipCornerRadius(_ cornerRadius:CGFloat) -> some View {
        clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
    
    func rightHalfRadius(_ cornerRadius:CGFloat) -> some View {
        clipShape(RightHalfRoundedRectangle(radius: cornerRadius))
    }
    
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
    
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

struct RightHalfRoundedRectangle: Shape {
    var radius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let topLeft = rect.origin
        let topRight = CGPoint(x: rect.maxX, y: rect.minY)
        let bottomLeft = CGPoint(x: rect.minX, y: rect.maxY)
        let bottomRight = CGPoint(x: rect.maxX, y: rect.maxY)
        
        path.move(to: CGPoint(x: topLeft.x, y: topLeft.y))
        path.addLine(to: CGPoint(x: topRight.x - radius, y: topRight.y))
        path.addArc(center: CGPoint(x: topRight.x - radius, y: topRight.y + radius), radius: radius, startAngle: .degrees(-90), endAngle: .degrees(0), clockwise: false)
        path.addLine(to: CGPoint(x: bottomRight.x, y: bottomRight.y - radius))
        path.addArc(center: CGPoint(x: bottomRight.x - radius, y: bottomRight.y - radius), radius: radius, startAngle: .degrees(0), endAngle: .degrees(90), clockwise: false)
        path.addLine(to: CGPoint(x: bottomLeft.x, y: bottomLeft.y))
        path.closeSubpath()
        
        return path
    }
}

public extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
    
//    func setBackdropSize() -> some View {
//        modifier(SetBackdropSizeModifier())
//    }

    @ViewBuilder
    func safeTask(priority: _Concurrency.TaskPriority = .userInitiated, @_inheritActorContext _ action: @escaping @Sendable () async -> Void) -> some View {
        if #available(iOS 16.4, macOS 13.3, *) {
            self
                .task(priority: priority, action)
        } else {
            onAppear {
                Task(priority: priority, operation: action)
            }
        }
    }
}




