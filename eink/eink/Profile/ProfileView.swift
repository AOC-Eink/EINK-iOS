//
//  ProfileView.swift
//  eink
//
//  Created by Aaron on 2024/9/4.
//

import SwiftUI

struct ProfileView: View {
    
    @Environment(\.appRouter) var appRouter

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    LabeledContent {
                        Image(systemName: "chevron.forward")
                    } label: {
                        Text("Language")
                    }
                    LabeledContent {
                        Image(systemName: "chevron.forward")
                    } label: {
                        Text("Setting")
                    }
                }
                
                Section {
                    LabeledContent {
                        HStack {
                            Text("V 1.0.0")
                            Image(systemName: "chevron.forward")
                        }
                    } label: {
                        Text("About")
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        appRouter.isConnected?.toggle()
                    }) {
                        Image(systemName: "chevron.backward")
                            .foregroundColor(.plusbutton)
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text("Profile")
                        .font(.title)
                        .foregroundStyle(.mydevicestitle)
                }
            }
        }
    }
}

#Preview {
    ProfileView()
}
