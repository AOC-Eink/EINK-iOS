//
//  RootViewController.swift
//  eink
//
//  Created by Aaron on 2024/9/21.
//

import SwiftUI


private struct PresentFullScreenKey: EnvironmentKey {
    static let defaultValue: (AnyView) -> Void = { _ in }
}

private struct DismissFullScreenKey: EnvironmentKey {
    static let defaultValue: () -> Void = {}
}

extension EnvironmentValues {
    var presentFullScreen: (AnyView) -> Void {
        get { self[PresentFullScreenKey.self] }
        set { self[PresentFullScreenKey.self] = newValue }
    }
    
    var dismissFullScreen: () -> Void {
        get { self[DismissFullScreenKey.self] }
        set { self[DismissFullScreenKey.self] = newValue }
    }
}
