//
//  UIView+Extension.swift
//  Transitions
//
//  Created by Tian Tong on 2019/6/24.
//  Copyright © 2019 TTDP. All rights reserved.
//

import UIKit

extension UIView {
    
    func addConstraints(format: String, views: UIView...) {
        var viewDictionary = [String: UIView]()
        
        for (index, view) in views.enumerated() {
            let key = "v\(index)"
            viewDictionary[key] = view
            
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: viewDictionary))
    }
    
}
