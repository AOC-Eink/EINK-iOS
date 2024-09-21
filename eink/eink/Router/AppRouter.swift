//
//  AppRouter.swift
//  eink
//
//  Created by Aaron on 2024/9/4.
//

import Foundation
import SwiftUI

@Observable
class AppRouter {
    
    var router:Router?
    var isConnected:Bool?
    
    func updateRouter(_ route: Router) {
        router = route
    }
}

enum Router: Hashable {
    
    case home(HomeRoute?)
    case catagory(CatagoryRoute?)
    case addDIY(AddRouter?)
    case favorites(FavoritesRoute?)
    case profile(ProfileRoute?)
    
    var id: Router { self }
    
}

enum HomeRoute: Hashable {
    case deviceHome(Int)
}

enum CatagoryRoute: Hashable {
    case category(String)
    case item(String)
}

enum AddRouter: Hashable {
    case new
}

enum FavoritesRoute: Hashable {
    case list
}

enum ProfileRoute: Hashable {
    case detail
}


struct NavigateEnvironmentKey:EnvironmentKey {
    static var defaultValue: (AppRouter)->Void = {
        #if DEBUG
        print("go to \($0)'s route view")
        #endif
    }
}

struct RouteEnvironmentKey:EnvironmentKey {
    static var defaultValue:AppRouter = AppRouter()
}

extension EnvironmentValues {
//    var router:(AppRouter)->Void {
//        get { self[NavigateEnvironmentKey.self] }
//        set { self[NavigateEnvironmentKey.self] = newValue }
//    }
    
    var appRouter: AppRouter {
        get { self[RouteEnvironmentKey.self] }
        set { self[RouteEnvironmentKey.self] = newValue }
    }
}
