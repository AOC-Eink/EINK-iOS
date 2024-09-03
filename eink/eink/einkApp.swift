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

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
