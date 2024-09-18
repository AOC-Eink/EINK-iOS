//
//  TriangleGrid.swift
//  eink
//
//  Created by Aaron on 2024/9/11.
//

import SwiftUI

//struct TriangleGridView: View {
//    let columns: Int
//    let rows: Int
//    @State private var selectedTriangle: Int?
//    
//    var body: some View {
////        VStack {
////            Spacer()
////            HStack {
////                Spacer()
//                TriangleGrid(columns: columns, rows: rows, selectedTriangle: $selectedTriangle)
////                Spacer()
////            }
////            Spacer()
////        }
//    }
//}
//
//struct TriangleGrid: View {
//    let columns: Int
//    let rows: Int
//    @Binding var selectedTriangle: Int?
//    
//    @State private var itemSize:CGFloat = 0
//    
//    
//    private var offsetY:CGFloat {
//        itemSize * 0.5 - 1
//    }
//    
//    private var paddingVertical:CGFloat {
//        (offsetY*0.5)*CGFloat(rows-1) + itemSize * 0.5
//    }
//    
//    private var totalHeight:CGFloat {
//        itemSize * CGFloat(columns - 1)
//    }
//    
//    var body: some View {
//        
//
//            HStack(spacing: 0) {
//                ForEach(0..<columns, id: \.self) { column in
//                    VStack(spacing: 0) {
//                        ForEach(0..<rows, id: \.self) { row in
//                            Triangle()
//                                .fill(selectedTriangle == column*rows + row ? Color.blue : Color.white)
//                                .aspectRatio(1, contentMode: .fit)
//                                .rotationEffect(.degrees(isUpsideDown(row: row, column: column) ? 90 : -90))
//                                .offset(y: row == 0 ? 0 : -CGFloat(row) * offsetY)
//                                .offset(x: isUpsideDown(row: row, column: column) ? 0 : -0.5)
//                                .onTapGesture {
//                                    selectedTriangle = column*rows + row
//                                    print("selectedTriangle : \(selectedTriangle ?? 0)")
//                                }
//                                .background(
//                                    GeometryReader { geometry in
//                                        Color.clear
//                                            .task {
//                                                itemSize = geometry.size.height
//                                            }
//                                    }
//                                )
//                        }
//                    }
//                    .offset(y:(offsetY*0.5)*CGFloat((rows-1)))
//                    
//                }
//            }
//            .padding(.leading, 0.5)
//            .background(Color.gray)
//        
//
//        
//        
//        //.aspectRatio(CGFloat(columns) / CGFloat(rows), contentMode: .fit)
//    }
//    
//    func isUpsideDown(row: Int, column: Int) -> Bool {
//        return (row + column) % 2 != 0
//    }
//}




struct TriangleGridView: View {
    let colors:[String]
    let columns: Int
    let rows: Int
    let triangleSize: CGFloat
    let  onTouch:((Int)->Void)
    @State private var selectedTriangle: Int?
    
    
    
    var offsetY:CGFloat {
        (triangleSize/2.0) + 3.0
    }
    
    var triangleHeight:CGFloat {
        (2 * triangleSize) / sqrt(3)
    }
    
    var totalHeight:CGFloat {
        CGFloat(rows) * triangleHeight - offsetY * CGFloat(rows - 1)
    }
    
    var body: some View {
        ZStack {
            HStack(spacing: 0) {
                ForEach(0..<columns, id: \.self) { column  in
                    VStack(spacing: 0) {
                        ForEach(0..<rows, id: \.self) { row in
                            
                            
                            
                            TriangleView(
                                isLeft: isLeft(row: row, column: column),
                                fillColor: Color.init(hex: column*rows + row < colors.count ? colors[column*rows + row] : "FFFFFF"), isSelected:
                                    selectedTriangle == column*rows + row)
                                
                            
                            
                            .frame(width: triangleSize, height: triangleHeight)
//

                            .offset(y: row == 0 ? 0 : -offsetY*CGFloat(row))
                            .offset(x: isLeft(row: row, column: column) ? 0 : 0.3)
                            .onTapGesture {
                                
                                selectedTriangle = column*rows + row
                                //print("selectedTriangle : \(selectedTriangle ?? 0)")
                                onTouch(column*rows + row)
                                
                            }
                        }
                    }
                    .offset(y:(offsetY/2.0*CGFloat((rows-1))))
                    .frame(height: totalHeight)
                    //.background(.orange)
                }
            }
            .padding(.leading, -1.0)
            .background(.gray)
            .frame(width: CGFloat(columns) * triangleSize)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        let position = value.location
                        // 计算手指划过的方形行列
                        let row = Int(position.y / triangleSize)
                        let column = Int(position.x / triangleHeight)
                        
                        selectedTriangle = column*rows + row
                        print("selectedTriangle : \(selectedTriangle ?? 0)")

                        // 确保行列在矩阵范围内
                        if row >= 0 && row < rows && column >= 0 && column < columns {
                            //selectedSquares.insert((row, column))
                            print("selectedTriangle onTouch: \(selectedTriangle ?? 0)")
                            onTouch(column*rows + row)// 标记被划过的方形
                        }
                    }
            )
        }
        .frame(height: totalHeight - triangleHeight*0.725)
        .clipped()
        
    }
    
    func isLeft(row: Int, column: Int) -> Bool {
        return (row + column) % 2 == 0
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

#Preview {
    TriangleGridView(colors: Array(repeating: "FFFFFF", count: 31), columns: 4, rows: 8, triangleSize: 50, onTouch: {_ in})
}
