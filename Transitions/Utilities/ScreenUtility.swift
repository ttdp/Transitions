//
//  ScreenUtility.swift
//  Transitions
//
//  Created by Tian Tong on 2019/6/24.
//  Copyright © 2019 TTDP. All rights reserved.
//

import UIKit

struct ScreenUtility {
    
    /// iPhone Notch: top + 24, bottom + 34
    static var hasNotch: Bool {
        if #available(iOS 11.0,  *) {
            return UIApplication.shared.delegate?.window??.safeAreaInsets.top ?? 0 > 24
        }
        return false
    }
    
}
