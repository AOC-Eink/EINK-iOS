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
    @GestureState private var dragLocation: CGPoint = .zero
    @GestureState private var isDragging: Bool = false
    @State private var lastValidTriangleIndex: Int?
    
    var dragGesture: some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .local)
//            .updating($dragLocation) { value, state, _ in
//                state = value.location
//            }
            .updating($isDragging) { _, state, _ in
               state = true
            }
            .onChanged { value in
                if let triangleIndex = triangleAt(location: value.location) {
                    if triangleIndex != lastValidTriangleIndex {
                        lastValidTriangleIndex = triangleIndex
                        onTouch(triangleIndex)
                    }
                }
            }
            .onEnded { _ in
                if let lastValid = lastValidTriangleIndex {
                    onTouch(lastValid)
                }
                lastValidTriangleIndex = nil
            }
    }
    
    
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
                                print("onTapGesture : \(selectedTriangle ?? 0)")
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
            //.frame(width: CGFloat(columns) * triangleSize)
            
        }
        .frame(height: totalHeight - triangleHeight)//*0.725
        .clipped()
        .simultaneousGesture(dragGesture)
        .onChange(of: dragLocation) {oldValue, newValue in
            if oldValue == newValue {
                return
            }
            if let triangleIndex = triangleAt(location: newValue) {
                if triangleIndex != selectedTriangle {
                    selectedTriangle = triangleIndex
                    print("triangleAt: \(triangleIndex)")
                    onTouch(triangleIndex)
                }
            }
        }
        
    }
    
    func isLeft(row: Int, column: Int) -> Bool {
        return (row + column) % 2 == 0
    }
    
//    func triangleAt(location: CGPoint) -> Int? {
//        let column = Int(location.x / triangleSize)
//        let row = Int(location.y / (triangleHeight - offsetY))
//        
//        if column >= 0 && column < columns && row >= 0 && row < rows {
//            return column * rows + row
//        }
//        return nil
//    }
    
    func triangleAt(location: CGPoint) -> Int? {
        let column = max(0, min(columns - 1, Int(location.x / triangleSize)))
        let row = max(0, min(rows - 1, Int(location.y / (triangleHeight - offsetY))))
        return column * rows + row
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
