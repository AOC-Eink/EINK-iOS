//
//  AlertModifier.swift
//  eink
//
//  Created by Aaron on 2024/9/21.
//

import SwiftUI

struct AlertModifier: ViewModifier {
    @StateObject private var alertManager = AlertManager()
    
    func body(content: Content) -> some View {
        content
            .environmentObject(alertManager)
            .alert(alertManager.title, isPresented: $alertManager.isPresented) {
                Button("确认", role: .destructive) {
                    alertManager.confirmAction?() ?? {}()
                }
                if alertManager.cancelAction != nil {
                    Button("取消", role: .cancel) {
                        alertManager.cancelAction?()
                    }
                }
            } message: {
                if let message = alertManager.message {
                    Text(message)
                }
            }
    }
}

extension View {
    func withAlertManager() -> some View {
        self.modifier(AlertModifier())
    }
}
