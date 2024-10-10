//
//  einkApp.swift
//  eink
//
//  Created by Aaron on 2024/9/3.
//

import SwiftUI

@main
struct einkApp: App {
    let persistenceController = CoreDataStack.shared
    @State var appConfiguration = AppConfiguration()
    @State var deviceManager = DeviceManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(appConfiguration)
                .environment(deviceManager)
                
        }
    }
}



final class AppConfiguration: ObservableObject {
    /// colorScheme
    @AppStorage("showOnboarding") var showOnboarding: Bool = true
    
    
    
}

enum SupportDevices:Hashable, CaseIterable{
    case phoneCase
    case clock
    
    var guideTips:String {
        switch self {
            case .clock:
                return "Display personalized Electronic Paper"
            case .phoneCase:
                return "Display personalized Electronic Paper"
        }
    }
    
    var guideImage:String {
        switch self {
            case .clock:
                return "eink.clock.tour"
            case .phoneCase:
                return "eink.case.tour"
        }
    }
    
}
