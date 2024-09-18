//
//  GestureView.swift
//  eink
//
//  Created by Aaron on 2024/9/18.
//

import SwiftUI

//struct Square: Hashable {
//    let row: Int
//    let column: Int
//}
//
//struct MatrixTouchView: View {
//    let columns = 8 // 定义方形矩阵的列数
//    let rows = 8    // 定义方形矩阵的行数
//    let squareSize: CGFloat = 40 // 每个方形的边长
//
//    @State private var selectedSquares: Set<Square> = [] // 保存被划过的方形位置
//
//    var body: some View {
//        VStack(spacing: 0) {
//            // 创建方形矩阵
//            ForEach(0..<rows, id: \.self) { row in
//                HStack(spacing: 0) {
//                    ForEach(0..<columns, id: \.self) { column in
//                        Rectangle()
//                            .fill(selectedSquares.contains(Square(row: row, column: column)) ? Color.green : Color.blue) // 划过的变成绿色
//                            .frame(width: squareSize, height: squareSize)
//                            .border(Color.black, width: 1)
//                    }
//                }
//            }
//        }
//        .gesture(
//            DragGesture(minimumDistance: 0)
//                .onChanged { value in
//                    let position = value.location
//                    // 计算手指划过的方形行列
//                    let row = Int(position.y / squareSize)
//                    let column = Int(position.x / squareSize)
//
//                    // 确保行列在矩阵范围内
//                    if row >= 0 && row < rows && column >= 0 && column < columns {
//                        selectedSquares.insert(Square(row: row, column: column))// 标记被划过的方形
//                    }
//                }
//        )
//    }
//}


struct Triangle1: Shape {
    let isUpward: Bool

    func path(in rect: CGRect) -> Path {
        var path = Path()
        if isUpward {
            // 上三角形
            path.move(to: CGPoint(x: rect.midX, y: rect.minY)) // 顶点
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY)) // 右下
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY)) // 左下
        } else {
            // 下三角形
            path.move(to: CGPoint(x: rect.midX, y: rect.maxY)) // 底部中点
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY)) // 右上
            path.addLine(to: CGPoint(x: rect.minX, y: rect.minY)) // 左上
        }
        path.closeSubpath()
        return path
    }
}

struct TriangleShape: Hashable {
    let row: Int
    let column: Int
    let isUpward: Bool
}

struct TriangleGridView1: View {
    let rows = 7
    let columns = 7
    let triangleSize: CGFloat = 50

    @State private var selectedTriangles: Set<TriangleShape> = [] // (row, column, isUpward)

    var body: some View {
        VStack(spacing: 0) {
            // 创建三角形网格
            ForEach(0..<rows, id: \.self) { row in
                HStack(spacing: 0) {
                    ForEach(0..<columns, id: \.self) { column in
                        let isUpward = (row + column) % 2 == 0 // 交替布局上下三角形
                        Triangle1(isUpward: isUpward)
                            .fill(selectedTriangles.contains(TriangleShape(row: row, column: column, isUpward: isUpward)) ? Color.green : Color.blue)
                            .frame(width: triangleSize, height: triangleSize)
                            .onTapGesture {
                                // 点击或手指滑过触发颜色变化
                                selectedTriangles.insert(TriangleShape(row: row, column: column, isUpward: isUpward))
                            }
                    }
                }
            }
        }
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    let location = value.location
                    // 计算触摸点对应的行列
                    let row = Int(location.y / triangleSize)
                    let column = Int(location.x / triangleSize)

                    // 判断当前触摸点位于上三角还是下三角
                    let isUpward = (row + column) % 2 == 0

                    if row >= 0 && row < rows && column >= 0 && column < columns {
                        selectedTriangles.insert(TriangleShape(row: row, column: column, isUpward: isUpward)) // 保存被划过的三角形
                    }
                }
        )
    }
}





#Preview {
    TriangleGridView1()
}
