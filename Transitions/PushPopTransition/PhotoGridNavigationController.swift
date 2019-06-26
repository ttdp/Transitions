//
//  PhotoGridNavigationController.swift
//  Transitions
//
//  Created by Tian Tong on 2019/6/25.
//  Copyright © 2019 TTDP. All rights reserved.
//

import UIKit

class PhotoGridNavigationController: UINavigationController {
    
    fileprivate var currentAnimationTransition: UIViewControllerAnimatedTransitioning? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
    }
    
}

extension PhotoGridNavigationController: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        // Whenever we push on a photo-detail screen,
        // we'll return an animation.
        let result: UIViewControllerAnimatedTransitioning?
        
        if let photoDetailVC = toVC as? PhotoDetailViewController, operation == .push {
            // Return a custom push animation.
            result = PhotoDetailPushTransition(fromDelegate: fromVC, toPhotoDetailVC: photoDetailVC)
        } else if let photoDetailVC = fromVC as? PhotoDetailViewController, operation == .pop {
            // Check if it is a pan gesture dismiss
            if photoDetailVC.isInteractiveDismissing {
                result = PhotoDetailInteractiveDismissTransition(fromDelegate: photoDetailVC, toDelegate: toVC)
            } else {
                result = PhotoDetailPopTransition(toDelegate: toVC, fromPhotoDetailVC: photoDetailVC)
            }
        } else {
            result = nil
        }
        
        currentAnimationTransition = result
        return result
    }
    
    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return currentAnimationTransition as? UIViewControllerInteractiveTransitioning
    }
    
//    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
//        currentAnimationTransition = nil
//    }
    
}
