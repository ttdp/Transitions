//
//  DateTableViewController.swift
//  Transitions
//
//  Created by Tian Tong on 2019/6/24.
//  Copyright © 2019 TTDP. All rights reserved.
//

import UIKit

class DateTableViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let addButton = UIBarButtonItem(title: "Add", style: .done, target: self, action: #selector(addDate))
        navigationItem.rightBarButtonItem = addButton
        
        setupViews()
    }
    
    // MARK: Views
    
    lazy var dateTable: DateTableView = {
        let tableView = DateTableView()
        tableView.registerCell(UITableViewCell.self)
        tableView.controller = self
        return tableView
    }()
    
    private func setupViews() {
        view.addSubview(dateTable)
        view.addConstraints(format: "H:|[v0]|", views: dateTable)
        view.addConstraints(format: "V:|[v0]|", views: dateTable)
    }
    
    // MARK: Actions
    
    @objc func addDate() {
        let datePicker = DatePickerViewController()
        datePicker.delegate = self
        
        present(datePicker, animated: true)
    }
    
}

extension DateTableViewController: DatePickerViewControllerDelegate {
    
    func datePicker(didSelect date: Date) {
        let dateString = date.localString
        dateTable.items.append(dateString)
        
        let indexPath = IndexPath(row: dateTable.items.count - 1, section: 0)
        dateTable.insertRows(at: [indexPath], with: .automatic)
    }
    
}

// MARK: -

class DateTableView: UITableView, UITableViewDataSource, UITableViewDelegate {
    
    var controller: DateTableViewController!
    var items = ["2019-06-26 08:07:00"]

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
    
}
