//
//  GalleryDetailPopTransition.swift
//  Transitions
//
//  Created by Tian Tong on 2019/6/29.
//  Copyright © 2019 TTDP. All rights reserved.
//

import UIKit

class GalleryDetailPopTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    fileprivate let galleryDetailVC: GalleryDetailViewController
    fileprivate let toDelegate: GalleryDetailTransitionAnimatorDelegate
    
    fileprivate let transitionImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.accessibilityIgnoresInvertColors = true
        return imageView
    }()
    
    init?(fromGalleryDetailVC galleryDetailVC: GalleryDetailViewController, toDelegate: Any) {
        guard let toDelegate = toDelegate as? GalleryDetailTransitionAnimatorDelegate else {
            return nil
        }
        
        self.galleryDetailVC = galleryDetailVC
        self.toDelegate = toDelegate
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.38
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let toView = transitionContext.view(forKey: .to)
        let fromView = transitionContext.view(forKey: .from)
        
        let containerView = transitionContext.containerView
        let fromReferenceFrame = galleryDetailVC.imageFrame()!
        
        let transitionImage = galleryDetailVC.referenceImage()
        transitionImageView.image = transitionImage
        transitionImageView.frame = fromReferenceFrame
        
        [toView, fromView].compactMap { $0 }.forEach {
            containerView.addSubview($0)
        }
        containerView.addSubview(transitionImageView)
        
        guard let galleryVC = toDelegate as? GalleryViewController else {
            return
        }
        galleryVC.lastSelectedIndexPath = galleryDetailVC.selectedIndexPath
        
        galleryDetailVC.transitionWillStart()
        toDelegate.transitionWillStart()
        
        let duration = transitionDuration(using: transitionContext)
        let spring: CGFloat = 0.9
        let animator = UIViewPropertyAnimator(duration: duration, dampingRatio: spring) {
            fromView?.alpha = 0
        }
        
        animator.addCompletion { position in
            self.transitionImageView.removeFromSuperview()
            self.transitionImageView.image = nil
            
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            self.toDelegate.transitionDidEnd()
            self.galleryDetailVC.transitionDidEnd()
        }
        
//        if let tabBar = transitionContext.viewController(forKey: .to)?.tabBarController as? TabBarController {
//            tabBar.setTabBar(hidden: false, animated: true, alongside: animator)
//        }
        
        animator.startAnimation()
        
        // If pop back image is not the first displayed one, its galleryVC's collection cell maybe outoff the screen.
        if toDelegate.imageFrame() == nil {
            galleryVC.adjustCollectionViewOffset()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.005) {
            animator.addAnimations {
                let toReferenceFrame = self.toDelegate.imageFrame() ?? GalleryDetailPopTransition.defaultOffscreenFrameForDismissal(transitionImageSize: fromReferenceFrame.size, screenHeight: containerView.bounds.height)
                self.transitionImageView.frame = toReferenceFrame
            }
        }
    }
    
    // Note: Not used
    static func defaultOffscreenFrameForDismissal(transitionImageSize: CGSize, screenHeight: CGFloat) -> CGRect {
        print(#function)
        return CGRect(x: 0, y: screenHeight, width: transitionImageSize.width, height: transitionImageSize.height)
    }
    
}
