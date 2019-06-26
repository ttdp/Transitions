//
//  PhotoDetailViewController.swift
//  Transitions
//
//  Created by Tian Tong on 2019/6/25.
//  Copyright © 2019 TTDP. All rights reserved.
//

import UIKit

class PhotoDetailViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        setupViews()
        configureDismissGesture()
    }
    
    // MARK: Views

    lazy var photoView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .white
        imageView.accessibilityIgnoresInvertColors = true
        return imageView
    }()
    
    private func setupViews() {
        view.addSubview(photoView)
        view.addConstraints(format: "H:|[v0]|", views: photoView)
        view.addConstraints(format: "V:|[v0]|", views: photoView)
    }
    
//    // MARK: Photo Collection View
//
//    lazy var photoCollection: PhotoDetailCollectionView = {
//        let collectionView = PhotoDetailCollectionView()
//        collectionView.registerCell(PhotoDetailCollectionCell.self)
//        collectionView.controller = self
//        return collectionView
//    }()
//
//    private func setupViews() {
//        view.addSubview(photoCollection)
//        view.addConstraints(format: "H:|[v0]|", views: photoCollection)
//        view.addConstraints(format: "V:|[v0]|", views: photoCollection)
//    }
    
    // MARK: - Drag To Dismiss
    
    private let dismissPanGesture = UIPanGestureRecognizer()
    
    var isInteractiveDismissing: Bool = false
    
    // By holding this as a property, we can then notify it about the current
    // state of the pan-gesture as the user moves their finger around.
    weak var transitionController: PhotoDetailInteractiveDismissTransition? = nil
    
    // We'll call this in viewDidLoad to set up the gesture
    private func configureDismissGesture() {
        view.addGestureRecognizer(dismissPanGesture)
        dismissPanGesture.addTarget(self, action: #selector(dismissPanGestureDidChange))
    }
    
    @objc private func dismissPanGestureDidChange(_ gesture: UIPanGestureRecognizer) {
        // Decide whether we're interactively-dismissing, and notify our navigation controller.
        switch gesture.state {
        case .began:
            isInteractiveDismissing = true
            navigationController?.popViewController(animated: true)
        case .cancelled, .failed, .ended:
            isInteractiveDismissing = false
        case .changed, .possible:
            break
        @unknown default:
            break
        }
        
        // Here's where we pass up the current-state of our gesture
        // to our 'PhotoDetailInteractiveDismissTransition':
        self.transitionController?.didPanWith(gestureRecognizer: gesture)
    }
    
}

extension PhotoDetailViewController: PhotoDetailTransitionAnimatorDelegate {
    
    func transitionWillStart() {
        photoView.isHidden = true
    }
    
    func transitionDidEnd() {
        photoView.isHidden = false
    }
    
    func referenceImage() -> UIImage? {
        return photoView.image
    }
    
    func imageFrame() -> CGRect? {
        let rect = CGRect.makeRect(aspectRatio: photoView.image!.size, insideRect: photoView.bounds)
        return rect
    }
    
}
