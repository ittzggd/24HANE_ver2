//
//  UserDefaultsExtension.swift
//  HANE24
//
//  Created by Katherine JANG on 12/13/23.
//

import Foundation

extension UserDefaults {
    static var shared: UserDefaults {
        let appGroupId = HaneWidgetConstant.appGroupName
        return UserDefaults(suiteName: appGroupId)!
    }
}
