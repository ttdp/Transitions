//
//  GalleryNavigationController.swift
//  Transitions
//
//  Created by Tian Tong on 2019/6/26.
//  Copyright © 2019 TTDP. All rights reserved.
//

import UIKit

class GalleryNavigationController: UINavigationController {
    
    fileprivate var currentAnimationTransition: UIViewControllerAnimatedTransitioning? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
    }
    
}

extension GalleryNavigationController: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let transition: UIViewControllerAnimatedTransitioning?
        
        if let galleryDetailVC = toVC as? GalleryDetailViewController, operation == .push {
            transition = GalleryDetailPushTransition(fromDelegate: fromVC, toGalleryDetailVC: galleryDetailVC)
        } else {
            transition = nil
        }
        
        currentAnimationTransition = transition
        return transition
    }
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        currentAnimationTransition = nil
    }
    
}
