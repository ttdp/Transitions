//
//  PhotoGirdViewController.swift
//  Transitions
//
//  Created by Tian Tong on 2019/6/25.
//  Copyright © 2019 TTDP. All rights reserved.
//

import UIKit

class PhotoGridViewController: UIViewController {
    
    fileprivate var lastSelectedIndexPath: IndexPath? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
    }
    
    // MARK: Views
    
    lazy var photoGrid: PhotoGridView = {
        let collectionView = PhotoGridView()
        collectionView.registerCell(PhotoGridCell.self)
        collectionView.controller = self
        return collectionView
    }()
    
    private func setupViews() {
        view.addSubview(photoGrid)
        view.addConstraints(format: "H:|[v0]|", views: photoGrid)
        view.addConstraints(format: "V:|[v0]|", views: photoGrid)
    }
    
}

extension PhotoGridViewController: PhotoDetailTransitionAnimatorDelegate {
    
    func transitionWillStart() {
        guard let lastSelected = lastSelectedIndexPath else { return }
        photoGrid.cellForItem(at: lastSelected)?.isHidden = true
    }
    
    func transitionDidEnd() {
        guard let lastSelected = lastSelectedIndexPath else { return }
        photoGrid.cellForItem(at: lastSelected)?.isHidden = false
    }
    
    func referenceImage() -> UIImage? {
        guard
            let lastSelected = lastSelectedIndexPath,
            let cell = photoGrid.cellForItem(at: lastSelected) as? PhotoGridCell
        else {
            return nil
        }
        
        return cell.photoView.image
    }
    
    func imageFrame() -> CGRect? {
        guard
            let lastSelected = lastSelectedIndexPath,
            let cell = photoGrid.cellForItem(at: lastSelected) as? PhotoGridCell
            else {
                return nil
        }
        
        return photoGrid.convert(cell.frame, to: view)
    }
    
}

class PhotoGridView: UICollectionView {
    
    var controller: PhotoGridViewController!
    
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

class PhotoGridCell: UICollectionViewCell {
    
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

extension PhotoGridView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 60
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(forIndexPath: indexPath) as PhotoGridCell
        cell.backgroundColor = .green
        
        let row = indexPath.row
        let photoNumber: String
        switch row {
        case 0...8:
            photoNumber = "0\(row + 1)"
        case 9...59:
            photoNumber = "\(row + 1)"
        default:
            fatalError("No photo at \(row)")
        }
        let photoName = "LA\(photoNumber)"
        
        // Small size above No.30, big size below No.30
        if row >= 30 {
            cell.photoView.image = UIImage(named: photoName)
        } else {
            cell.photoView.image = nil
        }
        
        return cell
    }
    
}

extension PhotoGridView: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        controller.lastSelectedIndexPath = indexPath
        let cell = collectionView.cellForItem(at: indexPath) as! PhotoGridCell
        let image = cell.photoView.image
        
        let photoDetailVC = PhotoDetailViewController()
        photoDetailVC.photoView.image = image
        
        controller.navigationController?.pushViewController(photoDetailVC, animated: true)
    }
    
}

extension PhotoGridView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width - 6) / 4
        return CGSize(width: width, height: width)
    }
    
}
