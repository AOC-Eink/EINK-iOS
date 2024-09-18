//
//  TriangleView.swift
//  eink
//
//  Created by Aaron on 2024/9/16.
//

import SwiftUI

struct TriangleView: View {
    let isLeft:Bool
    let fillColor:Color
    let isSelected:Bool
    
    var direction:Directions {
        if isLeft {
            Directions.left
        } else {
            Directions.right
        }
    }
    
    var body: some View {
        VStack {
            CustomTriangle(showBorder: isSelected, direction:direction)
                .fillAndBorder(fillColor)
        }
        
        
    }
}

#Preview {
    TriangleView(isLeft: true, fillColor: .green, isSelected: true)
}

struct CustomTriangle: Shape {
    
    var showBorder: Bool
    var direction:Directions
        
    init(showBorder: Bool = false, direction:Directions = .left) {
        self.showBorder = showBorder
        self.direction = direction
    }
    
    
    func path(in rect: CGRect) -> Path {
        
        switch direction {
        case .left:
            pathLeftRotated(in: rect)
        case .right:
            pathRightRotated(in: rect)
        }
    }
    
    func fillAndBorder<Fill: ShapeStyle>(_ fillStyle: Fill) -> some View{
        ZStack {
            self.fill(fillStyle)
                //.scaleEffect(showBorder ? 0.8 : 1)
                .animation(.easeInOut, value: showBorder)
                
            
        }
    }
}


struct EquilateralTriangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let height = rect.width * sqrt(3) / 2
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + height))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + height))
        path.closeSubpath()
        return path
    }
}


func pathRightRotated(in rect: CGRect) -> Path {
    var path = Path()
    path.move(to: CGPoint(x: rect.maxX, y: rect.midY))
    path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
    path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
    path.closeSubpath()

    return path
}

func pathLeftRotated(in rect: CGRect) -> Path {
    var path = Path()
    path.move(to: CGPoint(x: rect.minX, y: rect.midY))
    path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
    path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
    path.closeSubpath()
    return path
}
enum Directions {
    case left
    case right
}



//extension RightRotatedTriangle {
//    func fill<Fill: ShapeStyle>(_ fillStyle: Fill) -> some View {
//        self.fill(fillStyle)
//            .overlay(
//                self.stroke(Color.white, lineWidth: 2)
//                    .opacity(showBorder ? 1 : 0)
//            )
//    }
//}

struct RightRotatedTriangle: Shape {
    var showBorder: Bool
    init(showBorder: Bool = false) {
        self.showBorder = showBorder
        
    }
    func path(in rect: CGRect) -> Path {
        pathRightRotated(in: rect)
    }
    
    func fillAndBorder<Fill: ShapeStyle>(_ fillStyle: Fill) -> some View {
        ZStack {
            if showBorder {
                self.stroke(fillStyle, lineWidth: 4)
            }
        }
    }
}
