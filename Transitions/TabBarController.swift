//
//  TabBarController.swift
//  Transitions
//
//  Created by Tian Tong on 2019/6/25.
//  Copyright © 2019 TTDP. All rights reserved.
//

import UIKit

/** A custom tab-bar-controller that:
 -  keeps its tab bar hidden appropriately
 -  animates its tab bar in/out nicely
 **/
class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
    }
    
    func setupViews() {
        view.backgroundColor = .white
        
        let mainNavigation = UINavigationController(rootViewController: MainViewController())
        mainNavigation.tabBarItem = UITabBarItem(tabBarSystemItem: .favorites, tag: 0)
        
        let secondNavigation = PhotoGridNavigationController(rootViewController: PhotoGridViewController())
        secondNavigation.tabBarItem = UITabBarItem(tabBarSystemItem: .more, tag: 1)
        
        viewControllers = [mainNavigation, secondNavigation]
    }
    
    // MARK: Animator
    
    func setTabBar(hidden: Bool, animated: Bool = true, alongside animator: UIViewPropertyAnimator? = nil) {
        
    }
    
}
