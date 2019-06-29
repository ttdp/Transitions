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
    var selectedIndexPath: IndexPath? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let indexPath = selectedIndexPath {
            detailCollection.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
        }
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
    
}

extension GalleryDetailViewController: GalleryDetailTransitionAnimatorDelegate {
    
    func transitionWillStart() {
        detailCollection.isHidden = true
    }
    
    func transitionDidEnd() {
        detailCollection.isHidden = false
    }
    
    func referenceImage() -> UIImage? {
//        guard let indexPath = selectedIndexPath else {
//            return nil
//        }
//
//        let cell = detailCollection.cellForItem(at: indexPath) as! GalleryDetailCollectionCell
//        return cell.photoView.image
        return nil
    }
    
    func imageFrame() -> CGRect? {
//        guard let indexPath = selectedIndexPath else {
//            return nil
//        }
//
//        let cell = detailCollection.cellForItem(at: indexPath) as! GalleryDetailCollectionCell
//        let rect = CGRect.makeRect(aspectRatio: cell.photoView.image!.size, insideRect: cell.photoView.bounds)
//        return rect
        return nil
    }
    
}
