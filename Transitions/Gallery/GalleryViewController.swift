//
//  GalleryViewController.swift
//  Transitions
//
//  Created by Tian Tong on 2019/6/26.
//  Copyright © 2019 TTDP. All rights reserved.
//

import UIKit

class GalleryViewController: UIViewController {
    
    fileprivate var lastSelectedIndexPath: IndexPath? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
    }
    
    // MARK: Views
    
    lazy var galleryCollection: GalleryCollectionView = {
        let collectionView = GalleryCollectionView()
        collectionView.registerCell(GalleryCollectionCell.self)
        collectionView.controller = self
        return collectionView
    }()
    
    private func setupViews() {
        view.backgroundColor = .white
        
        view.addSubview(galleryCollection)
        view.addConstraints(format: "H:|[v0]|", views: galleryCollection)
        view.addConstraints(format: "V:|[v0]|", views: galleryCollection)
    }
    
}

class GalleryCollectionView: UICollectionView {
    
    var controller: GalleryViewController!
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        
        backgroundColor = .white
        dataSource = self
        delegate = self
    }
    
    convenience init() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 2
        layout.minimumInteritemSpacing = 2
        
        self.init(frame: .zero, collectionViewLayout: layout)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class GalleryCollectionCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Views
    
    lazy var photoView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private func setupViews() {
        addSubview(photoView)
        addConstraints(format: "H:|[v0]|", views: photoView)
        addConstraints(format: "V:|[v0]|", views: photoView)
    }
    
}

extension GalleryCollectionView: UICollectionViewDataSource {
    
    var images: [UIImage] {
        return (31...60).map { UIImage(named: "LA\($0)")! }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 30
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(forIndexPath: indexPath) as GalleryCollectionCell
        let image = images[indexPath.row]
        cell.photoView.image = image
        return cell
    }
    
}

extension GalleryCollectionView: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let galleryDetailVC = GalleryDetailViewController()
        galleryDetailVC.selectedIndexPath = indexPath
        galleryDetailVC.images = images
        
        controller.lastSelectedIndexPath = indexPath
        controller.navigationController?.pushViewController(galleryDetailVC, animated: true)
    }
    
}

extension GalleryCollectionView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width - 6) / 4
        return CGSize(width: width, height: width)
    }
    
}

extension GalleryViewController: GalleryDetailTransitionAnimatorDelegate {
    
    func transitionWillStart() {
        guard let lastSelected = lastSelectedIndexPath else { return }
        galleryCollection.cellForItem(at: lastSelected)?.isHidden = true
    }
    
    func transitionDidEnd() {
        guard let lastSelected = lastSelectedIndexPath else { return }
        galleryCollection.cellForItem(at: lastSelected)?.isHidden = false
    }
    
    func referenceImage() -> UIImage? {
        guard let lastSelected = lastSelectedIndexPath, let cell = galleryCollection.cellForItem(at: lastSelected) as? GalleryCollectionCell
            else {
                return nil
        }
        return cell.photoView.image
    }
    
    func imageFrame() -> CGRect? {
        guard let lastSelected = lastSelectedIndexPath, let cell = galleryCollection.cellForItem(at: lastSelected) as? GalleryCollectionCell
            else {
                return nil
        }
        
        return galleryCollection.convert(cell.frame, to: view)
    }
    
}
