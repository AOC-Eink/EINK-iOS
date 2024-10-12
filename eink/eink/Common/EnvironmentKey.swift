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

extension EnvironmentValues {
    var goDIYView: ([String]?, String?, Bool?, Bool) -> Void {
        get { self[GoDIYViewKey.self] }
        set { self[GoDIYViewKey.self] = newValue }
    }
}
