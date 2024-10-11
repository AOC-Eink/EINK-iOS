//
//  LogView.swift
//  eink
//
//  Created by Aaron Hou on 2024/10/11.
//

import SwiftUI

import SwiftUI

struct LogOverlayView: View {

    @State private var showExportSheet = false
    @Environment(DeviceManager.self) var deviceManager
    @State private var scrollProxy: ScrollViewProxy? = nil
    @State private var latestLogId: String = ""
    @State private var tempFileURL: URL?
    
    var body: some View {
        VStack {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 2) {
                        ForEach(Array(deviceManager.discoverInfo.enumerated()), id: \.offset) {index, log in
                            Text(log)
                                .font(.system(size: 12, design: .monospaced))
                                .foregroundColor(.green)
                        }
                    }
                    .padding(8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .background(Color.black)
                .onAppear {
                    scrollProxy = proxy
                }
            }

            HStack {
                CustomButton(title: "Export") {
                    Task {
                        if let fileURL = await createAndShareLogFile(logs: deviceManager.discoverInfo) {
                            self.tempFileURL = fileURL
                            self.showExportSheet = true
                            print("File created and ready to share")
                        }
                
                    }
                    
                }
            }
        }
        .background(Color.black.opacity(0.8))
        .foregroundColor(.white)
        .sheet(isPresented: $showExportSheet) {
            if let fileURL = tempFileURL {
                ActivityViewController(activityItems: [fileURL])
            }
            
        }
    }
    
    
    func logsToString() -> String {
        return deviceManager.discoverInfo.joined(separator: "\n")
    }
    

    func createAndShareLogFile(logs:[String]) async -> URL? {
        let logsString = logs.joined(separator: "\n")
        let tempDir = FileManager.default.temporaryDirectory
        let fileName = "logs_\(Date().timeIntervalSince1970).txt"
        let fileURL = tempDir.appendingPathComponent(fileName)
        
        do {
            try logsString.write(to: fileURL, atomically: true, encoding: .utf8)
            //self.tempFileURL = fileURL
            
            debugPrint("fileURL:\(fileURL)")
            return fileURL
        } catch {
            print("Error creating log file: \(error)")
            return nil
        }
    }
}

struct ActivityViewController: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}


