//
//  MainViewController.swift
//  Transitions
//
//  Created by Tian Tong on 2019/6/24.
//  Copyright © 2019 TTDP. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
    }
    
    // MARK: Views
    
    lazy var demoTable: DemoTableView = {
        let tableView = DemoTableView()
        tableView.registerCell(UITableViewCell.self)
        tableView.controller = self
        return tableView
    }()
    
    private func setupViews() {
        view.backgroundColor = .cyan
        
        view.addSubview(demoTable)
        view.addConstraints(format: "H:|[v0]|", views: demoTable)
        view.addConstraints(format: "V:|[v0]|", views: demoTable)
    }
    
}

// MARK: -

class DemoTableView: UITableView, UITableViewDataSource, UITableViewDelegate {
    
    var controller: MainViewController!
    var items = ["Date Picker", "Photo Detail"]

    init() {
        super.init(frame: .zero, style: .plain)
        dataSource = self
        delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: DataSource & Delegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(forIndexPath: indexPath)
        cell.selectionStyle = .none
        cell.textLabel?.text = items[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = indexPath.row
        
        let demoVC: UIViewController
        switch row {
        case 0:
            demoVC = DatePickerDemo()
        case 1:
            demoVC = PhotoDetailDemo()
        default:
            fatalError()
        }
        
        controller.navigationController?.pushViewController(demoVC, animated: true)
    }
    
}
