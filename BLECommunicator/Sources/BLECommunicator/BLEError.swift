//
//  File.swift
//  
//
//  Created by Aaron on 2024/9/24.
//

import Foundation

public enum BLEError: Error {
    case bluetoothUnavailable
    case deviceNotFound
    case connectionFailed
    case serviceNotFound
    case characteristicNotFound
    case writeError
    case readError
    case deviceNotConnected
    case connectionTimeout
    case noData
}
