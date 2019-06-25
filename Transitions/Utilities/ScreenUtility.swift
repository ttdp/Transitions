//
//  ScreenUtility.swift
//  Transitions
//
//  Created by Tian Tong on 2019/6/24.
//  Copyright © 2019 TTDP. All rights reserved.
//

import UIKit

struct ScreenUtility {
    
    static let height = UIScreen.main.bounds.height
    static let width = UIScreen.main.bounds.width
    
    static let halfHeight = UIScreen.main.bounds.height / 2
    static let halfWidth = UIScreen.main.bounds.width / 2
    
    static let thirdHeight = UIScreen.main.bounds.height / 3
    static let thirdWidth = UIScreen.main.bounds.width / 3
    
    static let quarterHeight = UIScreen.main.bounds.height / 4
    static let quarterWidth = UIScreen.main.bounds.width / 4
    
    /// iPhone Notch: top + 24, bottom + 34
    static var hasNotch: Bool {
        if #available(iOS 11.0,  *) {
            return UIApplication.shared.delegate?.window??.safeAreaInsets.top ?? 0 > 24
        }
        return false
    }
    
}
