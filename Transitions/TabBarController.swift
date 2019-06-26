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
    
    fileprivate var isTabBarHidden: Bool = false
    
//    fileprivate var isTabBarOffScreen: Bool {
//        return !tabBar.frame.intersects(view.frame)
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
    }
    
    func setupViews() {
        view.backgroundColor = .white
        
        let mainNavigation = DateTableNavigationController(rootViewController: DateTableViewController())
        mainNavigation.tabBarItem = UITabBarItem(tabBarSystemItem: .favorites, tag: 0)
        
        let secondNavigation = PhotoGridNavigationController(rootViewController: PhotoGridViewController())
        secondNavigation.tabBarItem = UITabBarItem(tabBarSystemItem: .more, tag: 1)
        
        viewControllers = [mainNavigation, secondNavigation]
    }
    
}

// MARK: - Animator

extension TabBarController {
    
    func setTabBar(hidden: Bool, animated: Bool = true, alongside animator: UIViewPropertyAnimator? = nil) {
        guard isTabBarHidden != hidden else { return }
        isTabBarHidden = hidden
        
        let offsetY = hidden ? tabBar.frame.height : -tabBar.frame.height
        let endFrame = tabBar.frame.offsetBy(dx: 0, dy: offsetY)
        let vc = selectedViewController
        
        var newInsets: UIEdgeInsets? = vc?.additionalSafeAreaInsets
        let originalInsets = newInsets
        newInsets?.bottom -= offsetY
        
        func set(childViewController cvc: UIViewController?, additionalSafeArea: UIEdgeInsets) {
            cvc?.additionalSafeAreaInsets = additionalSafeAreaInsets
            cvc?.view.setNeedsLayout()
        }
        
        if hidden, let insets = newInsets {
            set(childViewController: vc, additionalSafeArea: insets)
        }
        
        guard animated else {
            tabBar.frame = endFrame
            tabBar.isHidden = isTabBarHidden
            return
        }
        
        if tabBar.isHidden, !hidden {
            tabBar.isHidden = false
        }
        
        weak var tabBarRef = self.tabBar
        if let animator = animator {
            animator.addAnimations {
                tabBarRef?.frame = endFrame
            }
            
            animator.addCompletion { position in
                let insets = (position == .end) ? newInsets : originalInsets
                if !hidden, let insets = insets {
                    set(childViewController: vc, additionalSafeArea: insets)
                }
                if position == .end {
                    tabBarRef?.isHidden = hidden
                }
            }
        } else {
            UIView.animate(withDuration: 0.3, animations: {
                tabBarRef?.frame = endFrame
            }) { didFinish in
                if !hidden, didFinish, let insets = newInsets {
                    set(childViewController: vc, additionalSafeArea: insets)
                }
                tabBarRef?.isHidden = hidden
            }
        }
    }
    
}
