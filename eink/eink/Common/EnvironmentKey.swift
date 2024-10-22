//
//  EnvironmentKey.swift
//  eink
//
//  Created by Aaron on 2024/10/2.
//

import Foundation
import SwiftUI

struct GoDIYViewKey: EnvironmentKey {
    static var defaultValue: ([String]?, String?, Bool?, Bool) -> Void = {
        #if DEBUG
        print("go to \($0 ?? []) \($1 ?? "") \($2 ?? false) \($3)'s options view")
        #endif
    }
}

struct SelectDesginsKey: EnvironmentKey {
    static var defaultValue:([Design]) -> Void = {_ in
        
    }
}

struct SelectDesginKey: EnvironmentKey {
    static var defaultValue:(Design, Bool) -> Void = {_,_ in
        
    }
}

extension EnvironmentValues {
    var goDIYView: ([String]?, String?, Bool?, Bool) -> Void {
        get { self[GoDIYViewKey.self] }
        set { self[GoDIYViewKey.self] = newValue }
    }
    
    var selectDesigns: ([Design]) -> Void {
        get {self[SelectDesginsKey.self]}
        set {self[SelectDesginsKey.self] = newValue}
    }
    
    var selectDesign: (Design, Bool) -> Void {
        get {self[SelectDesginKey.self]}
        set {self[SelectDesginKey.self] = newValue}
    }
}
