//
//  PhotoDetailInteractiveDismissTransition.swift
//  Transitions
//
//  Created by Tian Tong on 2019/6/26.
//  Copyright © 2019 TTDP. All rights reserved.
//

import UIKit

class PhotoDetailInteractiveDismissTransition: NSObject {
    
    // The from- and to- viewControllers can conform to the protocol
    // in order to get updates and vend snapshotViews.
    fileprivate let fromDelegate: PhotoDetailTransitionAnimatorDelegate
    fileprivate weak var toDelegate: PhotoDetailTransitionAnimatorDelegate?
    
    // The background animation is the 'photo-detail background opacity goes to zero'.
    fileprivate var backgroundAnimation: UIViewPropertyAnimator? = nil
    
    // To avoid writting tons of boilerplate that pulls these values out of
    // the transitionContext, I'm just gonna cache them here.
    fileprivate var transitionContext: UIViewControllerContextTransitioning? = nil
    fileprivate var fromReferenceImageViewFrame: CGRect? = nil
    fileprivate var toReferenceImageViewFrame: CGRect? = nil
    fileprivate weak var fromVC: PhotoDetailViewController? = nil
    fileprivate weak var toVC: UIViewController? = nil
    
    
    // The snapshotView that is animating between two view controllers.
    fileprivate let transitionImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.accessibilityIgnoresInvertColors = true
        return imageView
    }()
    
    init(fromDelegate: PhotoDetailViewController, toDelegate: Any) {
        self.fromDelegate = fromDelegate
        self.toDelegate = toDelegate as? PhotoDetailTransitionAnimatorDelegate
        
        super.init()
    }
    
    // Called by the photo-detail screen, this function updates the state of
    // the interactive transition, based on the state of the gesture.
    func didPanWith(gestureRecognizer: UIPanGestureRecognizer) {
        let transitionContext = self.transitionContext!
        let transitionImageView = self.transitionImageView
        
        // For a given vertical-drag, we calculate our percentage complete
        // and how shrunk-down the transition-image should be.
        let transition = gestureRecognizer.translation(in: nil)
        let transitionVertical = transition.y
        
        let percentageComplete = self.percentageComplete(forVerticalDrag: transitionVertical)
        let transitionImageScale = transitionImageScaleFor(percentageComplete: percentageComplete)
        
        // Now, we inspect the guesture's state, and decide whether to update/cancel/complete.
        switch gestureRecognizer.state {
        case .possible, .began:
            break
        
        case .cancelled, .failed:
            self.completeTransition(didCancel: true)
        
        case .changed:
            // Apply a transform to our imageView, to scale/translate it into place.
            transitionImageView.transform = CGAffineTransform.identity.scaledBy(x: transitionImageScale, y: transitionImageScale).translatedBy(x: transition.x, y: transition.y)
            
            // Notify the system about the percentage-complete.
            transitionContext.updateInteractiveTransition(percentageComplete)
            
            // Update the background animation
            self.backgroundAnimation?.fractionComplete = percentageComplete
        
        case .ended:
            // Here, we decide whether to complete or cancel the transition.
            let fingerIsMovingDownwards = gestureRecognizer.velocity(in: nil).y > 0
            let transitionMadeSignificantProgress = percentageComplete > 0.1
            let shouldComplete = fingerIsMovingDownwards && transitionMadeSignificantProgress
            self.completeTransition(didCancel: !shouldComplete)
        
        @unknown default:
            break
        }
    }
    
    // If the gesture recognizer is completed/cancelled/failed,
    // we call this method to animate to our end-state and wrap things up.
    private func completeTransition(didCancel: Bool) {
        // If the gesture was cancelled, we reverse the "fade out the photo-detail background" animation.
        self.backgroundAnimation?.isReversed = didCancel
        
        let transitionContext = self.transitionContext!
        let backgroundAnimation = self.backgroundAnimation!
        
        // The cancel and complete animations have different timing values.
        let completionDuration: Double
        let completionDamping: CGFloat
        if didCancel {
            completionDuration = 0.45
            completionDamping = 0.75
        } else {
            completionDuration = 0.37
            completionDamping = 0.90
        }
        
        // The transition-image needs to animate into its final place.
        // That's either:
        // - its original spot on the photo-detail screen (if the transition was cancelled),
        // - or its place in the photo-grid (if the transition completed).
        let foregroundAnimation = UIViewPropertyAnimator(duration: completionDuration, dampingRatio: completionDamping) {
            // Reset our scale-transform on the imageView
            self.transitionImageView.transform = CGAffineTransform.identity
            
            // Note: It's important that we ask the toDelegate *here*,
            // because if the device has rotated,
            // the toDelegate needs a chance to update its layout
            // before asking for the frame.
            self.transitionImageView.frame = didCancel ? self.fromReferenceImageViewFrame! : self.toDelegate?.imageFrame() ?? self.toReferenceImageViewFrame!
        }
        
        // When the transition-image has moved into place, the animation completes,
        // and we close out the transition itself.
        foregroundAnimation.addCompletion { [weak self] position in
            self?.transitionImageView.removeFromSuperview()
            self?.transitionImageView.image = nil
            self?.toDelegate?.transitionDidEnd()
            self?.fromDelegate.transitionDidEnd()
            
            if didCancel {
                transitionContext.cancelInteractiveTransition()
            } else {
                transitionContext.finishInteractiveTransition()
            }
            transitionContext.completeTransition(!didCancel)
            self?.transitionContext = nil
        }
        
        // Update the backgroundAnimation's duration to match
        let durationFactor = CGFloat(foregroundAnimation.duration / backgroundAnimation.duration)
        backgroundAnimation.continueAnimation(withTimingParameters: nil, durationFactor: durationFactor)
        foregroundAnimation.startAnimation()
    }
    
    // For a given vertical offset, what's the percentage complete for the transition?
    // e.g. -100pts -> 0%, 0pts -> 0%, 20pts -> 10%, 200pts -> 100%, 400pts -> 100%
    func percentageComplete(forVerticalDrag verticalDrag: CGFloat) -> CGFloat {
        let maximumDelta = CGFloat(200)
        let range = (min: CGFloat(0), max: maximumDelta)
        return CGFloat.scaleAndShift(value: verticalDrag, inRange: range)
    }
    
    // The transition image scales down from 100% to a minimum of 68%,
    // based on the percentage-complete of the gesture.
    func transitionImageScaleFor(percentageComplete: CGFloat) -> CGFloat {
        let minScale = CGFloat(0.68)
        let result = 1 - (1 - minScale) * percentageComplete
        return result
    }
    
}

extension PhotoDetailInteractiveDismissTransition: UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        // Never called; this is always an interactive transition.
        fatalError()
    }
    
}

extension PhotoDetailInteractiveDismissTransition: UIViewControllerInteractiveTransitioning {
    
    // The system will call this function once at the very start;
    // it's our chance to take over and start driving the animation.
    func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        self.transitionContext = transitionContext
        let containerView = transitionContext.containerView
    
        guard
            let fromView = transitionContext.view(forKey: .from),
            let toView = transitionContext.view(forKey: .to),
            let fromImageFrame = fromDelegate.imageFrame(),
            let fromImage = fromDelegate.referenceImage(),
            let fromVC = transitionContext.viewController(forKey: .from) as? PhotoDetailViewController,
            let toVC = transitionContext.viewController(forKey: .to)
        else {
            fatalError()
        }
        
        self.fromVC = fromVC
        self.toVC = toVC
        fromVC.transitionController = self
        
        // Notify our delegates that the transition has begun.
        fromDelegate.transitionWillStart()
        toDelegate?.transitionWillStart()
        self.fromReferenceImageViewFrame = fromImageFrame
        
        // Decide where the image should move during the transition.
        // We'll replace this with a better one during the transition,
        // because the collectionView on the parent screen needs a chance to re-layout.
        self.toReferenceImageViewFrame = PhotoDetailPopTransition.defaultOffscreenFrameForDismissal(transitionImageSize: fromImageFrame.size, screenHeight: fromView.bounds.height)
        
        // Build the view-hierarchy for the animation
        containerView.addSubview(toView)
        containerView.addSubview(fromView)
        containerView.addSubview(transitionImageView)
        
        transitionImageView.image = fromImage
        transitionImageView.frame = fromImageFrame
        
        // Create the "photo-detail background fades away" animation
        // Note: The duration and damping ratio here don't matter!
        // This animation is only programmatically adjusted in the drag state,
        // and then the duration is altered in the completion state.
        self.backgroundAnimation = UIViewPropertyAnimator(duration: 1, dampingRatio: 1) {
            fromView.alpha = 0
        }
        
        if let tabBar = toVC.tabBarController as? TabBarController {
            tabBar.setTabBar(hidden: false, animated: true, alongside: backgroundAnimation)
        }
    }
    
}
