//
//  GalleryGridNavigationController.swift
//  Transitions
//
//  Created by Tian Tong on 2019/6/26.
//  Copyright © 2019 TTDP. All rights reserved.
//

import UIKit

class GalleryGridNavigationController: UINavigationController {
    
    fileprivate var currentAnimationTransition: UIViewControllerAnimatedTransitioning? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
    }
    
}

extension GalleryGridNavigationController: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let transition: UIViewControllerAnimatedTransitioning?
        
        if let galleryDetailVC = toVC as? GalleryDetailViewController, operation == .push {
            transition = GalleryDetailPushTransition(fromDelegate: fromVC, toGalleryDetailVC: galleryDetailVC)
        } else if let galleryDetailVC = fromVC as? GalleryDetailViewController, operation == .pop {
            if galleryDetailVC.isInteractiveDismissing {
                transition = GalleryDetailInteractiveDismissTransition(fromDelegate: galleryDetailVC, toDelegate: toVC)
            } else {
                transition = GalleryDetailPopTransition(fromGalleryDetailVC: galleryDetailVC, toDelegate: toVC)
            }
        } else {
            transition = nil
        }
        
        currentAnimationTransition = transition
        return transition
    }
    
    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return currentAnimationTransition as? UIViewControllerInteractiveTransitioning
    }
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        currentAnimationTransition = nil
    }
    
}

extension GalleryGridNavigationController {
    
    var shouldHideTabBar: Bool {
        let galleryDetailNavStack = self.viewControllers.contains(where: { (vc) -> Bool in
            return vc.isKind(of: GalleryDetailViewController.self)
        })
        
        let isPoppingFromGalleryDetail = (self.currentAnimationTransition?.isKind(of: GalleryDetailPopTransition.self) ?? false)
        
        if isPoppingFromGalleryDetail {
            return false
        } else {
            return galleryDetailNavStack
        }
    }
    
}
