//
//  TableView.swift
//  PinealAi
//
//  Created by 张行 on 2020/5/29.
//  Copyright © 2020 zhanghang. All rights reserved.
//

import UIKit

/// 一个表格的数据源
public class TableView {
    /// 数据分组对应的数组
    public var groups:[Group] = []
    /// 弱引用`UITableView`对象
    public weak var tableView:UITableView?
    private var dataSource:TableView.DataSource
    
    /// 初始化一个`UITableView`的数据源
    /// - Parameter tableView: 需要数据托管的`UITableView`
    public init(tableView:UITableView?, dataSource:TableView.DataSource? = nil) {
        self.tableView = tableView
        self.dataSource = dataSource ?? DataSource()
        self.dataSource.tableView = self
    }
    
    /// 添加一个数据源分组
    /// - Parameter block: 配置分组的`Group`
    public func addGroup(_ block:((Group) -> Void)) {
        let group = Group()
        group.tableView = tableView
        groups.append(group)
        block(group)
    }
    
    /// 设置`UITableView`数据源代理并刷新
    public func reloadData() {
        tableView?.dataSource = dataSource
        tableView?.delegate = dataSource
        tableView?.reloadData()
    }
    
    /// 清理之前添加的数据源 防止重复添加
    public func clearData() {
        groups.removeAll()
    }
}

extension TableView {
    public class Group {
        /// 弱引用数据源托管的`UITableView`
        public weak var tableView:UITableView?
        /// 分组对应添加的`Cell`
        public var cellls:[Cell] = []
        /// `UITableView`对应`Header`的配置
        public var header:HeaderFooter?
        /// `UITableView`对应的`Footer`的配置
        public var footer:HeaderFooter?
        /// 添加一个或者一组的`Cell`
        /// - Parameters:
        ///   - type: 对应`UITableViewCell`或者子类的类型
        ///   - block: 配置`Cell`
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
        
        /// 添加一个`Header`
        /// - Parameters:
        ///   - type: 对应`UITableViewHeaderFooterView`或者子类的类型
        ///   - block: 配置`HeaderFooter`
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
        
        /// 添加一个`Footer`
        /// - Parameters:
        ///   - type: `UITableViewHeaderFooterView`或者子类类型
        ///   - block: 配置`HeaderFooter`
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
        
        /// 获取对应分组下面`UITableViewCell`个数
        /// - Returns: `UITableViewCell`个数
        public func cellCount() -> Int {
            var count = 0
            for cell in cellls {
                count += cell.data.count
            }
            return count
        }
        
        /// 获取`IndexPath`对应`Cell`和在`Cell`的索引
        /// - Parameter indexPath: 当前的`IndexPath`
        /// - Returns: 对应`Cell`数据源和`Cell`对应的索引的元组
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
        /// 自定义高度的回掉
        public typealias CustomHeightHandle<D> = (_ tableView:UITableView,
                                                                     _ cell:TableView.Cell,
                                                                     _ data:D,
                                                                     _ indexPath:IndexPath,
                                                                     _ index:Int) -> CGFloat
        public var data:[Any] = []
        public let identifier:String
        public var height:CGFloat = UITableView.automaticDimension
        var configCell:((UITableView,UITableViewCell,IndexPath,Int) -> Void)? = nil
        var didSelectCell:((UITableView,Any,IndexPath,Int) -> Void)? = nil
        var customHeightHandle:CustomHeightHandle<Any>?
        
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
        /// 进行配置
        public func configCell<C:UITableViewCell>(tableView:UITableView,
                                                     cell:C,
                                                     indexPath:IndexPath,
                                                     index:Int) {
            configCell?(tableView,cell,indexPath,index)
        }
        
        public func didSelect<T:UITableViewCell, D>(_ cellType:T.Type, _ dataType:D.Type, _ block:@escaping ((UITableView, T, D, IndexPath, Int) -> Void)) {
            didSelectCell = { (tableView, data, indexPath, index) in
                guard let _data = data as? D, let cell = tableView.cellForRow(at: indexPath) as? T else {
                    return
                }
                block(tableView,cell,_data,indexPath,index)
            }
        }
        
        public func height<D>(_ dataType:D.Type,
                              _ block:@escaping CustomHeightHandle<D>) {
            customHeightHandle = { (tableView,cell,data,indexPath,index) in
                guard let data = data as? D else {
                    return UITableView.automaticDimension
                }
                return block(tableView,cell,data,indexPath,index)
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

