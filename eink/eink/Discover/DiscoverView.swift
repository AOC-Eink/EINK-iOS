//
//  DiscoverView.swift
//  eink
//
//  Created by Aaron on 2024/9/5.
//

import SwiftUI

struct DiscoverView: View {
    @Environment(\.appRouter) var appRouter
    
    var body: some View {
        
        NavigationView {
            VStack(alignment:.leading, spacing: 10){
                
                HStack(alignment:.center, spacing: 10){
                    Image("eink.logo")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 40, height: 40)
                    
                    Text("My Devices")
                    
                    Spacer()
                        
                }
                
                
                Text("7 Devies")
                
                Spacer()
                

                Button(action: {
                    appRouter.isConnected = true
                }, label: {
                    Text("Select")
                })
                .padding(.bottom, 100)
            }
            .padding()
            
            .toolbar {

                ToolbarItem {
                    Button(action: {}) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
        }
        }
    }
}

#Preview {
    DiscoverView()
}
