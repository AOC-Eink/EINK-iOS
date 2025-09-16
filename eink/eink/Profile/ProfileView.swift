//
//  ProfileView.swift
//  eink
//
//  Created by Aaron on 2024/9/4.
//

import SwiftUI
import BLECommunicator

struct ProfileView: View {
    
    //@Environment(\.appRouter) var appRouter
    @State private var appVersion: String = "1.0.0"
    
    init() {
        //Get App version
       appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }

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
                            Text("v \(appVersion)")
                            Image(systemName: "chevron.forward")
                        }
                    } label: {
                        Text("About")
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
//                ToolbarItem(placement: .navigationBarLeading) {
//                    Button(action: {
//                        //appRouter.isConnected?.toggle()
//                    }) {
//                        Image(systemName: "chevron.backward")
//                            .foregroundColor(.plusbutton)
//                    }
//                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        exportLog()
                    }) {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(.opButton)
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text("Profile")
                        .font(.navTitle)
                        .foregroundStyle(.black)
                }
            }
        }
    }
    
    func exportLog() {
        let logFileURL = Logger.shared.getLogFileURL()
        let activityVC = UIActivityViewController(activityItems: [logFileURL], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootViewController = window.rootViewController {
            rootViewController.present(activityVC, animated: true, completion: nil)
        }
    }
}

#Preview {
    ProfileView()
}
