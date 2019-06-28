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
        imageView.accessibilityIgnoresInvertColors = false
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
        
    }
    
}
