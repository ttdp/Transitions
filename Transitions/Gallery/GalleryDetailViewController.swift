//
//  GalleryDetailViewController.swift
//  Transitions
//
//  Created by Tian Tong on 2019/6/26.
//  Copyright © 2019 TTDP. All rights reserved.
//

import UIKit

class GalleryDetailViewController: UIViewController {
    
    var images: [UIImage] = []
    
    var isAppeared: Bool = false
    var initialIndexPath: IndexPath?
    var currentIndexPath: IndexPath? {
        return detailCollection.indexPathsForVisibleItems.first
    }
    
    var selectedIndexPath: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupPanGesture()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let indexPath = initialIndexPath {
            detailCollection.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
        }
        
        // When viewDidAppear be called first time, the collection should scroll to the initial position,
        // then the collection cell may be changed from initial position. In this case,
        // we use 'isAppeard' to judge if needs update initial indexPath in the willDisplay method,
        // becasue if pan gesture cancelled from other cell, viewDidAppear will be called again,
        // and the collection should scroll to the other cell's position.
        isAppeared = true
    }
    
    // MARK: Views
    
    lazy var detailCollection: GalleryDetailCollectionView = {
        let collectionView = GalleryDetailCollectionView()
        collectionView.registerCell(GalleryDetailCollectionCell.self)
        collectionView.controller = self
        return collectionView
    }()
    
    private func setupViews() {
        view.backgroundColor = .white
        
        view.addSubview(detailCollection)
        view.addConstraints(format: "H:|[v0]|", views: detailCollection)
        view.addConstraints(format: "V:|[v0]|", views: detailCollection)
    }
    
    // MARK: Pan Gesture
    
    private let dismissPanGesture = UIPanGestureRecognizer()
    
    var isInteractiveDismissing: Bool = false
    
    weak var transitionController: GalleryDetailInteractiveDismissTransition? = nil
    
    private func setupPanGesture() {
        view.addGestureRecognizer(dismissPanGesture)
        dismissPanGesture.addTarget(self, action: #selector(panGestureDidChange))
    }
    
    @objc private func panGestureDidChange(_ gesture: UIPanGestureRecognizer) {
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
        
        self.transitionController?.didPanWith(gestureRecognizer: gesture)
    }
    
}

extension GalleryDetailViewController: GalleryDetailTransitionAnimatorDelegate {
    
    func transitionWillStart() {
        detailCollection.isHidden = true
    }
    
    func transitionDidEnd() {
        detailCollection.isHidden = false
    }
    
    func referenceImage() -> UIImage? {
        guard let indexPath = currentIndexPath else {
            return nil
        }
        return images[indexPath.row]
    }
    
    func imageFrame() -> CGRect? {
        guard let image = referenceImage() else { return nil }
        
        let rect = CGRect.makeRect(aspectRatio: image.size, insideRect: view.bounds)
        
        // Note: Needs extra 2.5(has notch) or 7.5(no notch) y to be
        // the exactly size with toView
        let offsetY: CGFloat = ScreenUtility.hasNotch ? 2.5 : 7.5
        let fixedRect = CGRect(x: rect.origin.x, y: rect.origin.y + offsetY, width: rect.size.width, height: rect.size.height)
        
        return fixedRect
    }
    
}
