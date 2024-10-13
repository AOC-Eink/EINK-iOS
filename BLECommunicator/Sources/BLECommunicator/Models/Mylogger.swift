//
//  File.swift
//  
//
//  Created by Aaron on 2024/10/13.
//

import Foundation
import os.log

public class Logger {
    public static let shared = Logger()
    private let logFileName = "app_log.txt"
    private let logFileURL: URL
    
    private init() {
        debugPrint("Logger init")
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        logFileURL = documentsDirectory.appendingPathComponent(logFileName)
        
        // 检查并删除现有日志文件
        if FileManager.default.fileExists(atPath: logFileURL.path) {
            try? FileManager.default.removeItem(at: logFileURL)
        }
        
        // 创建新的日志文件
        FileManager.default.createFile(atPath: logFileURL.path, contents: nil, attributes: nil)
    }
    
    public func log(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        //let timestamp = ISO8601DateFormatter().string(from: Date())
        let customFormatTime = getCurrentTime(format: "yyyy-MM-dd HH:mm:ss")
        let logMessage = "[\(customFormatTime)] [\(file.components(separatedBy: "/").last ?? "")] [\(function):\(line)] \(message)"
        
        print(logMessage)
        
        if let data = (logMessage + "\n").data(using: .utf8) {
            if let fileHandle = try? FileHandle(forWritingTo: logFileURL) {
                fileHandle.seekToEndOfFile()
                fileHandle.write(data)
                fileHandle.closeFile()
            }
        }
    }
    
    func getCurrentTime(format: String = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ") -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.timeZone = TimeZone.current
        formatter.locale = Locale.current
        return formatter.string(from: Date())
    }
    
    public func getLogFileURL() -> URL {
        return logFileURL
    }
}
