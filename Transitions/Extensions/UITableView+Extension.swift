//
//  UITableView+Extension.swift
//  Transitions
//
//  Created by Tian Tong on 2019/6/24.
//  Copyright © 2019 TTDP. All rights reserved.
//

import UIKit

protocol Reusable {}

extension UITableViewCell: Reusable {}

extension Reusable where Self: UITableViewCell {
    
    static var reuseId: String {
        return String(describing: self)
    }
    
}

extension UITableView {
    
    func registerCell<Cell: UITableViewCell>(_ cellClass: Cell.Type) {
        register(cellClass, forCellReuseIdentifier: cellClass.reuseId)
    }
    
    func dequeueReusableCell<Cell: UITableViewCell>(forIndexPath indexPath: IndexPath) -> Cell {
        guard let cell = self.dequeueReusableCell(withIdentifier: Cell.reuseId, for: indexPath) as? Cell else {
            fatalError("Unknow cell at \(indexPath)")
        }
        return cell
    }
    
}
