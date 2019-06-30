//
//  GalleryDetailInteractiveDismissTransition.swift
//  Transitions
//
//  Created by Tian Tong on 2019/6/29.
//  Copyright © 2019 TTDP. All rights reserved.
//

import UIKit

class GalleryDetailInteractiveDismissTransition: NSObject {
    
    fileprivate let fromDelegate: GalleryDetailTransitionAnimatorDelegate
    fileprivate weak var toDelegate: GalleryDetailTransitionAnimatorDelegate?
    
    fileprivate var backgroundAnimation: UIViewPropertyAnimator? = nil
    fileprivate var transitionContext: UIViewControllerContextTransitioning? = nil
    
    fileprivate var fromReferenceImageViewFrame: CGRect? = nil
    fileprivate var toReferenceImageViewFrame: CGRect? = nil
    fileprivate weak var fromVC: GalleryDetailViewController? = nil
    fileprivate weak var toVC: UIViewController? = nil
    
    fileprivate let transitionImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.accessibilityIgnoresInvertColors = true
        return imageView
    }()
    
    init(fromDelegate: GalleryDetailViewController, toDelegate: Any) {
        self.fromDelegate = fromDelegate
        self.toDelegate = toDelegate as? GalleryDetailTransitionAnimatorDelegate
        super.init()
    }
    
    func didPanWith(gestureRecognizer: UIPanGestureRecognizer) {
        let transitionContext = self.transitionContext!
        let transitionImageView = self.transitionImageView
        
        let transition = gestureRecognizer.translation(in: nil)
        let transitionVertical = transition.y
        
        let percentageComplete = self.percentageComplete(forVerticalDrag: transitionVertical)
        let transitionImageScale = self.transitionImageScale(for: percentageComplete)
        
        switch gestureRecognizer.state {
        case .possible, .began:
            break
        
        case .cancelled, .failed:
            self.completeTransition(didCancel: true)
        
        case .changed:
            transitionImageView.transform = CGAffineTransform.identity.scaledBy(x: transitionImageScale, y: transitionImageScale).translatedBy(x: transition.x, y: transition.y)
            
            transitionContext.updateInteractiveTransition(percentageComplete)
            
            self.backgroundAnimation?.fractionComplete = percentageComplete
        
        case .ended:
            let fingerIsMovingDownwards = gestureRecognizer.velocity(in: nil).y > 0
            let transitionMadeSignificantProgress = percentageComplete > 0.1
            let shouldComplete = fingerIsMovingDownwards && transitionMadeSignificantProgress
            self.completeTransition(didCancel: !shouldComplete)
            
        @unknown default:
            break
        }
    }
    
    private func completeTransition(didCancel: Bool) {
        self.backgroundAnimation?.isReversed = didCancel
        
        guard
            let transitionContext = self.transitionContext,
            let backgroundAnimation = self.backgroundAnimation
        else {
            return
        }
        
        let completionDuration: Double
        let completionDamping: CGFloat
        
        if didCancel {
            completionDuration = 0.45
            completionDamping = 0.75
        } else {
            completionDuration = 0.37
            completionDamping = 0.90
        }
        
        let foregroundAnimation = UIViewPropertyAnimator(duration: completionDuration, dampingRatio: completionDamping) {
            self.transitionImageView.transform = CGAffineTransform.identity
            self.transitionImageView.frame = didCancel ? self.fromReferenceImageViewFrame! : self.toDelegate?.imageFrame() ?? self.toReferenceImageViewFrame!
        }
        
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
        
        let durationFactor = CGFloat(foregroundAnimation.duration / backgroundAnimation.duration)
        backgroundAnimation.continueAnimation(withTimingParameters: nil, durationFactor: durationFactor)
        foregroundAnimation.startAnimation()
    }
    
    func percentageComplete(forVerticalDrag verticalDrag: CGFloat) -> CGFloat {
        let maximumDelta = CGFloat(200)
        let range = (min: CGFloat(0), max: maximumDelta)
        return CGFloat.scaleAndShift(value: verticalDrag, inRange: range)
    }
    
    func transitionImageScale(for percentageComplete: CGFloat) -> CGFloat {
        let minScale = CGFloat(0.68)
        let result = 1 - (1 - minScale) * percentageComplete
        return result
    }
    
}

extension GalleryDetailInteractiveDismissTransition: UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        fatalError()
    }
    
}

extension GalleryDetailInteractiveDismissTransition: UIViewControllerInteractiveTransitioning {
    
    func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        self.transitionContext = transitionContext
        let containerView = transitionContext.containerView
        
        guard
            let fromView = transitionContext.view(forKey: .from),
            let toView = transitionContext.view(forKey: .to),
            let fromImageFrame = fromDelegate.imageFrame(),
            let fromImage = fromDelegate.referenceImage(),
            let fromVC = transitionContext.viewController(forKey: .from) as? GalleryDetailViewController,
            let toVC = transitionContext.viewController(forKey: .to) as? GalleryViewController
        else {
            fatalError()
        }
        
        self.fromVC = fromVC
        self.toVC = toVC
        fromVC.transitionController = self
        
        toVC.selectedIndexPath = fromVC.selectedIndexPath
        
        if toDelegate?.imageFrame() == nil {
            toVC.adjustCollectionViewOffset()
        }
        
        self.fromReferenceImageViewFrame = fromImageFrame
        self.toReferenceImageViewFrame = self.toDelegate?.imageFrame()

        [toView, fromView, transitionImageView].forEach {
            containerView.addSubview($0)
        }
        
        transitionImageView.image = fromImage
        transitionImageView.frame = fromImageFrame
        
        self.backgroundAnimation = UIViewPropertyAnimator(duration: 1, dampingRatio: 1) {
            fromView.alpha = 0
        }
        
        // After 0.005 to let collection view do the layout adjustment.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.005) {
            self.fromDelegate.transitionWillStart()
            self.toDelegate?.transitionWillStart()
        }
        
//        if let tabBar = toVC.tabBarController as? TabBarController {
//            tabBar.setTabBar(hidden: false, animated: true, alongside: backgroundAnimation)
//        }
    }
    
}
