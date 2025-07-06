//
//  textView.swift
//  eink
//
//  Created by Aaron on 2025/7/6.
//

import SwiftUI

struct TestView: View {
    var body: some View {
        
        HStack {
            Text("第一个")
                .frame(maxWidth: .infinity)
                .background(Color.red)
            Text("第二个0000000")
                .frame(maxWidth: .infinity)
                .background(Color.green)
            Text("第三个")
                .frame(maxWidth: .infinity)
                .background(Color.blue)
        }
        .frame(height: 60)
        .padding()
    }
}

#Preview {
    
    TestView()
    
}
