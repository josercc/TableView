//
//  TableView.swift
//  PinealAi
//
//  Created by 张行 on 2020/5/29.
//  Copyright © 2020 zhanghang. All rights reserved.
//

import UIKit

public class TableView {
    public var groups:[Group] = []
    public weak var tableView:UITableView?
    private lazy var dataSource:TableView.DataSource = { TableView.DataSource(self) }()
    
    public init(tableView:UITableView?) {
        self.tableView = tableView
    }
    
    public func addGroup(_ block:((Group) -> Void)) {
        let group = Group()
        group.tableView = tableView
        groups.append(group)
        block(group)
    }
    
    public func reloadData() {
        tableView?.dataSource = dataSource
        tableView?.delegate = dataSource
        tableView?.reloadData()
    }
    
    public func clearData() {
        groups.removeAll()
    }
}

extension TableView {
    public class Group {
        public weak var tableView:UITableView?
        public var cellls:[Cell] = []
        public var header:HeaderFooter?
        public var footer:HeaderFooter?
        public func addCell<T:UITableViewCell>(_ type:T.Type = T.self, _ block:(Cell) -> Void) {
            let identifier = "\(T.self)"
            guard let tableView = tableView else {
                return
            }
            tableView.register(T.self, forCellReuseIdentifier: identifier)
            let cell = Cell(identifier: identifier)
            cellls.append(cell)
            block(cell)
        }
        
        public func addHeader<T:UITableViewHeaderFooterView>(_ type:T.Type, _ block:(HeaderFooter) -> Void) {
            let identifier = "\(T.self)"
            guard let tableView = tableView else {
                return
            }
            tableView.register(T.self, forHeaderFooterViewReuseIdentifier: identifier)
            let header = HeaderFooter(identifier: identifier)
            self.header = header
            block(header)
        }
        
        public func addFooter<T:UITableViewHeaderFooterView>(_ type:T.Type, _ block:(HeaderFooter) -> Void) {
            let identifier = "\(T.self)"
            guard let tableView = tableView else {
                return
            }
            tableView.register(T.self, forHeaderFooterViewReuseIdentifier: identifier)
            let header = HeaderFooter(identifier: identifier)
            self.footer = header
            block(header)
        }
        
        public func cellCount() -> Int {
            var count = 0
            for cell in cellls {
                count += cell.data.count
            }
            return count
        }
        
        public func cellIndex(indexPath:IndexPath) -> (Cell,Int)? {
            var count = 0
            for cell in cellls {
                let max = count + cell.data.count
                if indexPath.row < max {
                    return (cell,(indexPath.row - count))
                }
                count = max
            }
            return nil
        }
    }
}

extension TableView {
    public class Cell {
        public var data:[Any] = []
        public let identifier:String
        public var height:CGFloat = UITableView.automaticDimension
        var configCell:((UITableView,UITableViewCell,IndexPath,Int) -> Void)? = nil
        var didSelectCell:((UITableView,Any,IndexPath,Int) -> Void)? = nil
        
        public init(identifier:String) {
            self.identifier = identifier
        }
        
        public func config<T:UITableViewCell, D>(_ cellType:T.Type, _ dataType:D.Type, _ block:@escaping ((UITableView, T, D, IndexPath, Int) -> Void)) {
            configCell = { (tableView,cell,indexPath,index) in
                guard let _cell = cell as? T, let _data = self.data[index] as? D else {
                    return
                }
                block(tableView,_cell, _data,indexPath,index)
            }
        }
        public func didSelect<T:UITableViewCell, D>(_ cellType:T.Type, _ dataType:D.Type, _ block:@escaping ((UITableView, T, D, IndexPath, Int) -> Void)) {
            didSelectCell = { (tableView, data, indexPath, index) in
                guard let _data = data as? D, let cell = tableView.cellForRow(at: indexPath) as? T else {
                    return
                }
                block(tableView,cell,_data,indexPath,index)
            }
        }
    }
}

extension TableView {
    public class HeaderFooter {
        public var data:Any?
        public let identifier:String
        public var height:CGFloat = UITableView.automaticDimension
        var configHeaderFooter:((UITableView,UITableViewHeaderFooterView,Int) -> Void)? = nil
        public init(identifier:String) {
            self.identifier = identifier
        }
        
        public func config<T:UITableViewHeaderFooterView, D>(_ headerType:T.Type, _ dataType:D.Type, _ block:@escaping ((UITableView,T,D,Int) -> Void)) {
            configHeaderFooter = {[weak self] (tableView,headerFooterView,section) in
                guard let `self` = self, let _data = self.data as? D, let headerFooter = headerFooterView as? T else {
                    return
                }
                block(tableView,headerFooter,_data,section)
            }
        }
    }
}

