//
//  PhotoDetailPopTransition.swift
//  Transitions
//
//  Created by Tian Tong on 2019/6/26.
//  Copyright © 2019 TTDP. All rights reserved.
//

import UIKit

class PhotoDetailPopTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    fileprivate let toDelegate: PhotoDetailTransitionAnimatorDelegate
    fileprivate let photoDetailVC: PhotoDetailViewController
    
    fileprivate let transitionImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.accessibilityIgnoresInvertColors = true
        return imageView
    }()
    
    init?(toDelegate: Any, fromPhotoDetailVC photoDetailVC: PhotoDetailViewController) {
        guard let toDelegate = toDelegate as? PhotoDetailTransitionAnimatorDelegate else {
            return nil
        }
        
        self.toDelegate = toDelegate
        self.photoDetailVC = photoDetailVC
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.38
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let toView = transitionContext.view(forKey: .to)
        let fromView = transitionContext.view(forKey: .from)
        
        let containerView = transitionContext.containerView
        let fromReferenceFrame = photoDetailVC.imageFrame()!
        
        let transitionImage = photoDetailVC.referenceImage()
        transitionImageView.image = transitionImage
        transitionImageView.frame = fromReferenceFrame
        
        [toView, fromView].compactMap { $0 }.forEach { containerView.addSubview($0) }
        containerView.addSubview(transitionImageView)
        
        photoDetailVC.transitionWillStart()
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
            self.photoDetailVC.transitionDidEnd()
        }
        
        guard let tabBar = transitionContext.viewController(forKey: .to)?.tabBarController as? TabBarController else {
            return
        }
        tabBar.setTabBar(hidden: false, animated: true, alongside: animator)
        
        // Here, we kick off the animation.
        animator.startAnimation()
        
        // By delaying 0.005s, I get a layout-refresh on toViewController,
        // which means its collectionView has updated its layout,
        // and our toDelegate?.imageFrame() is accurate.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.005) {
            animator.addAnimations {
                let toReferenceFrame = self.toDelegate.imageFrame() ?? PhotoDetailPopTransition.defaultOffscreenFrameForDismissal(transitionImageSize: fromReferenceFrame.size, screenHeight: containerView.bounds.height)
                self.transitionImageView.frame = toReferenceFrame
            }
        }
    }
    
    static func defaultOffscreenFrameForDismissal(transitionImageSize: CGSize, screenHeight: CGFloat) -> CGRect {
        return CGRect(x: 0, y: screenHeight, width: transitionImageSize.width, height: transitionImageSize.height)
    }
    
}
