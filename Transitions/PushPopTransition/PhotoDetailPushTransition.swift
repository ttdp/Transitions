//
//  PhotoDetailPushTransition.swift
//  Transitions
//
//  Created by Tian Tong on 2019/6/25.
//  Copyright © 2019 TTDP. All rights reserved.
//

import UIKit

protocol PhotoDetailTransitionAnimatorDelegate: class {
    
    /// Called just-before the transition animation begins.
    /// Use this to prepare for the transition.
    func transitionWillStart()
    
    /// Called right-after the transition animation ends.
    /// Use this to clean up after the transition.
    func transitionDidEnd()
    
    /// The animator needs a UIImageView for the transition;
    /// eg the Photo Detail screen should provide a snapshotView of its image,
    /// and a collectionView should do the same for its image views.
    func referenceImage() -> UIImage?
    
    /// The location oncreen for the imageView provided in `referenceImageView(for:)`
    func imageFrame() -> CGRect?
    
}

class PhotoDetailPushTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    fileprivate let fromDelegate: PhotoDetailTransitionAnimatorDelegate
    fileprivate let photoDetailVC: PhotoDetailViewController
    
    fileprivate let transitionImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.accessibilityIgnoresInvertColors = true
        return imageView
    }()
    
    init?(fromDelegate: Any, toPhotoDetailVC photoDetailVC: PhotoDetailViewController) {
        guard let fromDelegate = fromDelegate as? PhotoDetailTransitionAnimatorDelegate else {
            return nil
        }
        
        self.fromDelegate = fromDelegate
        self.photoDetailVC = photoDetailVC
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
        [fromView, toView].compactMap { $0 }.forEach { containerView.addSubview($0) }
        
        let transitionImage = fromDelegate.referenceImage()!
        transitionImageView.image = transitionImage
        
        let transitionFrame = fromDelegate.imageFrame() ?? PhotoDetailPushTransition.defaultOffscreenFrameForPresentation(image: transitionImage, forView: toView!)
        transitionImageView.frame = transitionFrame
        containerView.addSubview(transitionImageView)
        
        let toReferenceFrame = PhotoDetailPushTransition.calculateZoomInImageFrame(image: transitionImage, forView: toView!)
        
        fromDelegate.transitionWillStart()
        photoDetailVC.transitionWillStart()
        
        // Now is the animation
        let duration = transitionDuration(using: transitionContext)
        let sping: CGFloat = 0.95
        let animator = UIViewPropertyAnimator(duration: duration, dampingRatio: sping) {
            self.transitionImageView.frame = toReferenceFrame
            toView?.alpha = 1
        }
        
        // Once the animation is completed, we'll need to clean up.
        animator.addCompletion { position in
            self.transitionImageView.removeFromSuperview()
            self.transitionImageView.image = nil
            
            // Tell UIKit we're done with the transition.
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            
            // Tell our view controller that we're done.
            self.photoDetailVC.transitionDidEnd()
            self.fromDelegate.transitionDidEnd()
        }
        
        guard let tabBar = transitionContext.viewController(forKey: .from)?.tabBarController as? TabBarController else {
            return
        }
        tabBar.setTabBar(hidden: true, animated: true, alongside: animator)
        
        // Here, we kick off the animation.
        animator.startAnimation()
    }
    
    private static func defaultOffscreenFrameForPresentation(image: UIImage, forView view: UIView) -> CGRect {
        var result = PhotoDetailPushTransition.calculateZoomInImageFrame(image: image, forView: view)
        result.origin.y = view.bounds.height
        return result
    }
 
    private static func calculateZoomInImageFrame(image: UIImage, forView view: UIView) -> CGRect {
        let reck = CGRect.makeRect(aspectRatio: image.size, insideRect: view.bounds)
        return reck
    }
    
}
