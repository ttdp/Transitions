//
//  GalleryDetailPushTransition.swift
//  Transitions
//
//  Created by Tian Tong on 2019/6/28.
//  Copyright © 2019 TTDP. All rights reserved.
//

import UIKit

protocol GalleryDetailTransitionAnimatorDelegate: class {
    func transitionWillStart()
    func transitionDidEnd()
    func referenceImage() -> UIImage?
    func imageFrame() -> CGRect?
}

class GalleryDetailPushTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    fileprivate let fromDelegate: GalleryDetailTransitionAnimatorDelegate
    fileprivate let galleryDetailVC: GalleryDetailViewController
    
    fileprivate let transitionImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.accessibilityIgnoresInvertColors = true
        return imageView
    }()
    
    init?(fromDelegate: Any, toGalleryDetailVC galleryDetailVC: GalleryDetailViewController) {
        guard let fromDelegate = fromDelegate as? GalleryDetailTransitionAnimatorDelegate else {
            return nil
        }
        
        self.fromDelegate = fromDelegate
        self.galleryDetailVC = galleryDetailVC
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.38
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let toView = transitionContext.view(forKey: .to)
        let fromView = transitionContext.view(forKey: .from)
        let containerView = transitionContext.containerView
        toView?.alpha = 0
        
        // Add fromView and toView to the containerView
        [fromView, toView].compactMap { $0 }.forEach {
            containerView.addSubview($0)
        }
        
        let transitionImage = fromDelegate.referenceImage()!
        transitionImageView.image = transitionImage
        
        let transitionFrame = fromDelegate.imageFrame() ?? GalleryDetailPushTransition.defaultOffscreenFrameForPresentation(image: transitionImage, forView: toView!)
        transitionImageView.frame = transitionFrame
        containerView.addSubview(transitionImageView)
        
        let toReferenceFrame = GalleryDetailPushTransition.calculateZoomInImageFrame(image: transitionImage, forView: toView!)
        
        fromDelegate.transitionWillStart()
        galleryDetailVC.transitionWillStart()
        
        // Here animation goes
        let duration = transitionDuration(using: transitionContext)
        let spring: CGFloat = 0.95
        let animator = UIViewPropertyAnimator(duration: duration, dampingRatio: spring) {
            self.transitionImageView.frame = toReferenceFrame
            toView?.alpha = 1
        }
        
        // Once the animation is completed, we'll need to clean up.
        animator.addCompletion { position in
            self.transitionImageView.removeFromSuperview()
            self.transitionImageView.image = nil
            
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            
            self.galleryDetailVC.transitionDidEnd()
            self.fromDelegate.transitionDidEnd()
        }
        
//        if let tabBar = transitionContext.viewController(forKey: .from)?.tabBarController as? TabBarController {
//            tabBar.setTabBar(hidden: true, animated: true, alongside: animator)
//        }
        
        animator.startAnimation()
    }
    
    private static func defaultOffscreenFrameForPresentation(image: UIImage, forView view: UIView) -> CGRect {
        var result = GalleryDetailPushTransition.calculateZoomInImageFrame(image: image, forView: view)
        result.origin.y = view.bounds.height
        return result
    }
    
    private static func calculateZoomInImageFrame(image: UIImage, forView view: UIView) -> CGRect {
        let rect = CGRect.makeRect(aspectRatio: image.size, insideRect: view.bounds)
        
        // Note: Needs extra 2.5(has notch) or 7.5(no notch) y to be
        // the exactly size with toView
        let offsetY: CGFloat = ScreenUtility.hasNotch ? 2.5 : 7.5
        let fixedRect = CGRect(x: rect.origin.x, y: rect.origin.y + offsetY, width: rect.size.width, height: rect.size.height)
        return fixedRect
    }
    
}
