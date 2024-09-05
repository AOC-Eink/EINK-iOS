//
//  einkApp.swift
//  eink
//
//  Created by Aaron on 2024/9/3.
//

import SwiftUI

@main
struct einkApp: App {
    let persistenceController = PersistenceController.shared
    @State var appConfiguration = AppConfiguration()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(appConfiguration)
        }
    }
}


final class AppConfiguration: ObservableObject {
    /// colorScheme
    @AppStorage("showOnboarding") var showOnboarding: Bool = true
    
}
