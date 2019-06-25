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
