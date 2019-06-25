//
//  TabBarController.swift
//  Transitions
//
//  Created by Tian Tong on 2019/6/25.
//  Copyright © 2019 TTDP. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
    }
    
    func setupViews() {
        view.backgroundColor = .white
        
        let mainNavigation = UINavigationController(rootViewController: MainViewController())
        mainNavigation.tabBarItem = UITabBarItem(tabBarSystemItem: .favorites, tag: 0)
        
        let secondNavigation = UINavigationController(rootViewController: SecondViewController())
        secondNavigation.tabBarItem = UITabBarItem(tabBarSystemItem: .more, tag: 1)
        
        viewControllers = [mainNavigation, secondNavigation]
    }
    
}
