
import SwiftUI

class AHlertManager: ObservableObject {
    @Published var isPresented = false
    @Published var title = ""
    @Published var message: String?
    @Published var confirmAction: (() -> Void)?
    @Published var cancelAction: (() -> Void)?
    
    func showAlert(title: String = "Notice", message: String? = nil, confirmAction: (() -> Void)? = nil, cancelAction: (() -> Void)? = nil) {
        self.title = title
        self.message = message
        self.confirmAction = confirmAction
        self.cancelAction = cancelAction
        self.isPresented = true
    }
}
