//
//  TriangleGrid.swift
//  eink
//
//  Created by Aaron on 2024/9/11.
//

import SwiftUI

struct TriangleGridView: View {
    let colors:[String]
    let columns: Int
    let rows: Int
    let triangleSize: CGFloat
    let onTouch:((Int?, Bool, String?)->Void)
    
    @State private var selectedTriangle: Int?
    @GestureState private var isDragging: Bool = false
    @State private var lastValidTriangleIndex: Int?
    
    var dragGesture: some Gesture {
        DragGesture(minimumDistance: 5)
            .updating($isDragging) { _, state, _ in
               state = true
            }
            .onChanged { value in
                if let triangleIndex = triangleAt(location: value.location) {
                    if triangleIndex != lastValidTriangleIndex {
                        lastValidTriangleIndex = triangleIndex
                        print("triangleAt: \(triangleIndex)")
                        onTouch(triangleIndex, false, nil)
                    }
                }
            }
            .onEnded { _ in
                if let lastValid = lastValidTriangleIndex {
                    print("lastValid: \(lastValid)")
                    onTouch(lastValid, false, nil)
                    onTouch(nil, false, colors[lastValid])
                }
                lastValidTriangleIndex = nil
            }
    }
    
    
    var offsetY:CGFloat {
        (triangleHeight/2.0) - 0.8
    }
    
    var triangleHeight:CGFloat {
        (2 * triangleSize) / sqrt(3)
    }
    
    var totalHeight:CGFloat {
        CGFloat(rows) * triangleHeight - offsetY * CGFloat(rows - 1)
    }
    
    var indexColor: (Int) -> Color {
        return { index in
            if index < colors.count {
                return Color(hex: colors[index])
            } else {
                return .designOff
            }
        }
    }
    
    
    
    var body: some View {
        ZStack {
            HStack(spacing: 0) {
                ForEach(0..<columns, id: \.self) { column  in
                    VStack(spacing: 0) {
                        ForEach(0..<rows, id: \.self) { row in
                            
                            TriangleView(
                                isLeft: isLeft(row: row, column: column),
                                fillColor: indexColor(column*rows + row),
                                isSelected:
                                    selectedTriangle == column*rows + row
                            )
                            .frame(width: triangleSize, height: triangleHeight)
                            .offset(y: row == 0 ? 0 : -offsetY*CGFloat(row))
                            //.offset(x: isLeft(row: row, column: column) ? 0 : 0.8)
                            .onTapGesture {
                                let index = column*rows + row
                                let curColor = colors[index]
                                print("onTapGesture : \(index), color: \(curColor)")
                                if selectedTriangle == column*rows + row {
                                    onTouch(index, true, curColor)
                                } else {
                                    onTouch(index, false, curColor)
                                }
                                
                                selectedTriangle = index
                                
                            }
                        }
                    }
                    .offset(y:(offsetY/2.0*CGFloat((rows-1))))
                    .offset(x: CGFloat(column) * 0.8)
                    .frame(height: totalHeight)
                }
                
                
            }
            .padding(.leading, -1.0)
            //.background(.gray)
            .simultaneousGesture(dragGesture)//highPriorityGesture
            .frame(width: CGFloat(columns) * triangleSize)
            
        }
        .frame(height: totalHeight - triangleHeight)//*0.725
        .clipped()
        
    }
    
    func isLeft(row: Int, column: Int) -> Bool {
        return (row + column) % 2 == 0
    }
    
    func triangleAt(location: CGPoint) -> Int? {
        let column = max(0, min(columns - 1, Int(location.x / triangleSize)))
        let row = max(0, min(rows - 1, Int(location.y / (triangleHeight - offsetY))))
        return column * rows + row
    }
}


#Preview {
    TriangleGridView(colors: Array(repeating: "DBDBDB", count: 31), columns: 6, rows: 9, triangleSize: 50, onTouch: {_,_,_ in})
}
