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
