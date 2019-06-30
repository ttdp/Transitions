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
        return 0.3
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let fromView = transitionContext.view(forKey: .from)
        let toView = transitionContext.view(forKey: .to)
        guard let galleryVC = toDelegate as? GalleryGridViewController else {
            return
        }
        
        let containerView = transitionContext.containerView
        let transitionImage = galleryDetailVC.referenceImage()
        guard let fromReferenceFrame = galleryDetailVC.imageFrame() else {
            return
        }
        
        transitionImageView.image = transitionImage
        transitionImageView.frame = fromReferenceFrame
        
        [toView, fromView, transitionImageView].compactMap { $0 }.forEach {
            containerView.addSubview($0)
        }
        
        // If pop back image is not the first displayed one,
        // the galleryVC's collection cell maybe out off the screen.
        galleryVC.selectedIndexPath = galleryDetailVC.selectedIndexPath

        if galleryVC.imageFrame() == nil {
            galleryVC.adjustCollectionViewOffset()
        }
        
        let duration = self.transitionDuration(using: transitionContext)
        let spring: CGFloat = 0.9
        let animator = UIViewPropertyAnimator(duration: duration, dampingRatio: spring) {
            fromView?.alpha = 0
        }
        
        animator.addAnimations {
            let toReferenceFrame = self.toDelegate.imageFrame() ?? GalleryDetailPopTransition.defaultOffscreenFrameForDismissal(transitionImageSize: fromReferenceFrame.size, screenHeight: containerView.bounds.height)
            self.transitionImageView.frame = toReferenceFrame
        }
        
        animator.addCompletion { position in
            self.transitionImageView.removeFromSuperview()
            self.transitionImageView.image = nil
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            
            self.galleryDetailVC.transitionDidEnd()
            self.toDelegate.transitionDidEnd()
        }

        // After 0.005 to let collection view do the layout adjustment.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.005) {
            self.galleryDetailVC.transitionWillStart()
            self.toDelegate.transitionWillStart()
            
            animator.startAnimation()
        }

        if let tabBar = transitionContext.viewController(forKey: .to)?.tabBarController as? TabBarController {
            tabBar.setTabBar(hidden: false, animated: true, alongside: animator)
        }

    }
    
    // Note: Won't be called, because after adjust the collection offset,
    // the imageFrame should be retrieved, no need for default offscreen.
    static func defaultOffscreenFrameForDismissal(transitionImageSize: CGSize, screenHeight: CGFloat) -> CGRect {
        return CGRect(x: 0, y: screenHeight, width: transitionImageSize.width, height: transitionImageSize.height)
    }
    
}
