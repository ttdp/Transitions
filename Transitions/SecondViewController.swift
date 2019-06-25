//
//  SecondViewController.swift
//  Transitions
//
//  Created by Tian Tong on 2019/6/25.
//  Copyright © 2019 TTDP. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
    }
    
    // MARK: Views
    
    lazy var demoCollection: DemoCollectionView = {
        let collectionView = DemoCollectionView()
        collectionView.registerCell(UICollectionViewCell.self)
        collectionView.controller = self
        return collectionView
    }()
    
    private func setupViews() {
        view.addSubview(demoCollection)
        view.addConstraints(format: "H:|[v0]|", views: demoCollection)
        view.addConstraints(format: "V:|[v0]|", views: demoCollection)
    }
    
}

class DemoCollectionView: UICollectionView {
    
    var controller: SecondViewController!
    
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

extension DemoCollectionView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let width = (collectionView.frame.width - 6) / 4
        print(width)
        return 60
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
        cell.backgroundColor = .green
        return cell
    }
    
}

extension DemoCollectionView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width - 6) / 4
        return CGSize(width: width, height: width)
    }
    
}
