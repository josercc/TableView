//
//  TableView.swift
//  PinealAi
//
//  Created by 张行 on 2020/5/29.
//  Copyright © 2020 zhanghang. All rights reserved.
//
#if canImport(UIKit)
import UIKit

/// 一个表格的数据源
/// 可以快速搭建基于`UITableView`的列表或者复杂的UI界面，支持高度自动计算，自动缓存高度，便捷的高度刷新。
public class TableView {

    /// 数据分组对应的数组
    public var groups:[Group] = []
    /// 弱引用`UITableView`对象
    public weak var tableView:UITableView?
    /// 默认的`UITableView`数据源
    private var dataSource:TableView.DataSource
    
    /// 初始化一个`UITableView`的数据源
    /// - Parameter tableView: 需要数据托管的`UITableView`
    /// - Parameter dataSource: 自定义数据源对象 默认为空，则为默认的代理实现
    public init(tableView:UITableView,
                dataSource:TableView.DataSource? = nil) {
        self.tableView = tableView
        self.dataSource = dataSource ?? DataSource()
        self.dataSource.tableView = self
    }
    /// 添加一个`Group`
    /// - Parameter group: 添加的分组
    public typealias AddGroupBlock = (_ group:Group) -> Void
    /// 添加一个数据源分组
    /// - Parameter block: 配置分组的`Group`
    public func addGroup(_ block:AddGroupBlock) {
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
    /// 表格的`Group`对象
    public class Group {
        /// 弱引用数据源托管的`UITableView`
        public weak var tableView:UITableView?
        /// 分组对应添加的`Cell`
        public var cellls:[Cell] = []
        /// `UITableView`对应`Header`的配置
        public var header:HeaderFooter?
        /// `UITableView`对应的`Footer`的配置
        public var footer:HeaderFooter?
        /// 在`Group`添加`Cell`
        /// - Parameter cell: 添加的`Cell`对象
        public typealias AddCellBlock = (_ cell:Cell) -> Void
        /// 添加一个或者一组的`Cell`
        /// - Parameters:
        ///   - type: 对应`UITableViewCell`或者子类的类型
        ///   - block: 配置`Cell`
        ///   - identifier: 自定义标识符 默认为`UITableViewCell`对象类型的类名
        public func addCell<C:UITableViewCell>(_ type:C.Type,
                                               _ block:AddCellBlock,
                                               identifier:String = "\(C.self)") {
            guard let tableView = tableView else {
                return
            }
            tableView.register(C.self, forCellReuseIdentifier: identifier)
            let cell = Cell(identifier: identifier)
            cellls.append(cell)
            block(cell)
        }
        
        /// 在`Group`添加`Header`或者`Footer`
        /// - Parameter headerFooter: 添加的`Header`或者`Footer`对象
        public typealias AddHeaderFooterBlock = (_ headerFooter:HeaderFooter) -> Void
        /// 添加一个`Header`
        /// - Parameters:
        ///   - type: 对应`UITableViewHeaderFooterView`或者子类的类型
        ///   - block: 配置`Header`闭包
        ///   - identifier: 自定义标识符 默认为`UITableViewHeaderFooterView`对象的类名
        public func addHeader<HF:UITableViewHeaderFooterView>(_ type:HF.Type,
                                                              _ block:AddHeaderFooterBlock,
                                                              identifier:String = "\(HF.self)") {
            guard let tableView = tableView else {
                return
            }
            tableView.register(HF.self, forHeaderFooterViewReuseIdentifier: identifier)
            let header = HeaderFooter(identifier: identifier)
            self.header = header
            block(header)
        }
        
        /// 添加一个`Footer`
        /// - Parameters:
        ///   - type: `UITableViewHeaderFooterView`或者子类类型
        ///   - block: 配置`Footer`
        ///   - identifier: 自定义标识符 默认为`UITableViewHeaderFooterView`对象的类名
        public func addFooter<HF:UITableViewHeaderFooterView>(_ type:HF.Type,
                                                              _ block:AddHeaderFooterBlock,
                                                              identifier:String = "\(HF.self)") {
            guard let tableView = tableView else {
                return
            }
            tableView.register(HF.self, forHeaderFooterViewReuseIdentifier: identifier)
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
    /// `Group`添加`Cell`配置
    public class Cell {
        /// 自定义高度的回掉
        /// - Parameter tableView: 对应所在的`UITableView`
        /// - Parameter cell: 对应`TableView.Cell`对象
        /// - Parameter data: 对应的设置数据
        /// - Parameter indexPath: `UITableViewCell`对应在`UITableView`的索引
        /// - Parameter index: 对应在`TableView.Cell`对象的索引
        public typealias CustomHeightHandle<D> = (_ tableView:UITableView,
                                                  _ cell:TableView.Cell,
                                                  _ data:D,
                                                  _ indexPath:IndexPath,
                                                  _ index:Int) -> CGFloat
        /// 设置数据源 必须是数组类型 如果数据统一放在数组里面 可以放类型`String`或者`Int`的占位符，因为获取对应`UITableViewCell`的个数是通过这个属性的`.count`进行设置的
        public var data:[Any] = []
        /// 标识符 如果想设置对应标识符 需要在初始化`Cell`进行添加
        public let identifier:String
        /// 设置`Cell`中对应`UITableViewCell`的高度，默认为`UITableView.automaticDimension`。如果实现了自动计算高度的协议，则自动计算高度。一旦设置了`height`的值不等于`UITableView.automaticDimension`，则返回设置的高度，内部不会自动计算高度
        public var height:CGFloat = UITableView.automaticDimension
        /// 配置`UITableViewCell`
        var configCell:((UITableView,UITableViewCell,IndexPath,Int) -> Void)? = nil
        /// 点击`UITableViewCell`
        var didSelectCell:((UITableView,Any,IndexPath,Int) -> Void)? = nil
        /// 自定义`UITableViewCell`高度`
        var customHeightHandle:CustomHeightHandle<Any>?
        /// 存放自动计算高度的缓存
        var automaticDimensionHeights:[IndexPath:CGFloat] = [:]
        
        /// 创建一个`Cell` 请使用
        /// - Parameter identifier: 标识符
        init(identifier:String) {
            self.identifier = identifier
        }
        
        /// 配置`UITableViewCell`回掉
        /// - Parameter tableView: 所在的`UITableView`
        /// - Parameter tableViewCell: 需要配置的`UITableViewCell`对象
        /// - Parameter data: 需要设置的数据
        /// - Parameter indexPath: `UITableViewCell`所在`UITableView`的索引
        /// - Parameter index: `UITableViewCell`所在`Cell`的索引
        public typealias ConfigBlock<C:UITableViewCell, D> = (_ tableView:UITableView,
                                                              _ tableViewCell:C,
                                                              _ data:D,
                                                              _ indexPath:IndexPath,
                                                              _ index:Int) -> Void
        /// 进行配置`UITableViewCell`
        /// - Parameters:
        ///   - cellType: `UITableViewCell`的类型
        ///   - dataType: 数据的类型
        ///   - block: 配置的闭包
        public func config<T:UITableViewCell, D>(_ cellType:T.Type,
                                                 _ dataType:D.Type,
                                                 _ block:@escaping ConfigBlock<T,D>) {
            configCell = { (tableView,cell,indexPath,index) in
                guard let _cell = cell as? T, let _data = self.data[index] as? D else {
                    return
                }
                block(tableView,_cell, _data,indexPath,index)
            }
        }
        
        /// 主动调用去配置`UITableViewCell`
        /// - Parameter tableView: 所在的`UITableView`
        /// - Parameter cell: 所在的`Cell`
        /// - Parameter indexPath: `UITableViewCell`所在`UITableView`对应的索引
        /// - Parameter index: `UITableViewCell`所在`Cell`对应的索引
        public func configCell<C:UITableViewCell>(tableView:UITableView,
                                                  cell:C,
                                                  indexPath:IndexPath,
                                                  index:Int) {
            configCell?(tableView,cell,indexPath,index)
        }
        
        /// 点击`UITableViewCell`回掉
        /// - Parameter tableView: 所在的`UITableView`
        /// - Parameter tableViewCell: 点击的`UITableViewCell`对象
        /// - Parameter data: 对应的数据
        /// - Parameter indexPath: `UITableViewCell`所在`UITableView`的索引
        /// - Parameter index: `UITableViewCell`所在`Cell`的索引
        public typealias DidSelectBlock<C:UITableViewCell,D> = (_ tableView:UITableView,
                                                                _ tableViewCell:C,
                                                                _ data:D,
                                                                _ indexPath:IndexPath,
                                                                _ index:Int) -> Void
        /// 点击`UITableViewCell`
        /// - Parameters:
        ///   - cellType: `UITableViewCell`类型
        ///   - dataType: 数据类型
        ///   - block: 点击回掉
        public func didSelect<T:UITableViewCell, D>(_ cellType:T.Type,
                                                    _ dataType:D.Type,
                                                    _ block:@escaping DidSelectBlock<T,D>) {
            didSelectCell = { (tableView, data, indexPath, index) in
                guard let _data = data as? D, let cell = tableView.cellForRow(at: indexPath) as? T else {
                    return
                }
                block(tableView,cell,_data,indexPath,index)
            }
        }
        
        /// 自定义高度
        /// - Parameters:
        ///   - dataType: 数据类型
        ///   - block: 自定义高度闭包
        public func height<D>(_ dataType:D.Type,
                              _ block:@escaping CustomHeightHandle<D>) {
            customHeightHandle = { (tableView,cell,data,indexPath,index) in
                guard let data = data as? D else {
                    return self.height
                }
                return block(tableView,cell,data,indexPath,index)
            }
        }
    }
}

extension TableView {
    /// `Group`中对应的`Header`或者`Footer`的配置
    public class HeaderFooter {
        /// 配置的数据源 可以为任意类型 不管怎么设置不会影响对应`Header`或者`Footer`的个数，因为最多只能是一个
        public var data:Any?
        /// 标识符
        public let identifier:String
        /// 设置`Header`或者`Footer`的高度，默认为`UITableView.automaticDimension`暂不支持自动计算高度
        public var height:CGFloat = UITableView.automaticDimension
        /// 配置`Header`或者`Footer`的闭包
        var configHeaderFooter:((UITableView,UITableViewHeaderFooterView,Int) -> Void)? = nil
        /// 初始化`Header`或者`Footer`
        /// - Parameter identifier: 标识符
        init(identifier:String) {
            self.identifier = identifier
        }
        /// 配置`Header`或者`Footer`的闭包
        /// - Parameter tableView: 对应的`UITableView`
        /// - Parameter headerFooter: 配置的`UITableViewHeaderFooterView`对象
        /// - Parameter data: 配置的数据
        /// - Parameter section: 对应`UITableView`所在的`section`
        public typealias ConfigHandle<TF:UITableViewHeaderFooterView, D> = (_ tableView:UITableView,
                                                                            _ headerFooter:TF,
                                                                            _ data:D,
                                                                            _ section:Int) -> Void
        
        /// 配置`Header`或者`Footer`
        /// - Parameters:
        ///   - headerType: `UITableViewHeaderFooterView`类型
        ///   - dataType: 配置数据类型
        ///   - block: 配置的闭包
        public func config<TF:UITableViewHeaderFooterView, D>(_ headerType:TF.Type,
                                                              _ dataType:D.Type,
                                                              _ block:@escaping ConfigHandle<TF,D>) {
            configHeaderFooter = {[weak self] (tableView,headerFooterView,section) in
                guard let `self` = self,
                      let _data = self.data as? D,
                      let headerFooter = headerFooterView as? TF else {
                    return
                }
                block(tableView,headerFooter,_data,section)
            }
        }
    }
}
#endif
