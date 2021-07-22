//
//  AutomaticDimension.swift
//  File
//
//  Created by joser on 2021/7/19.
//

import Foundation
#if canImport(UIKit)
import UIKit

/// 自动计算高度对象 主要集中处理关联对象内容
public class AutomaticDimension {
    /// 布局对应的底部视图
    /// 如果想做到自动计算高度 则需要`UITableView`所有的`UIView`基于`view`进行布局。不能和`UITableView`的`ContentView.bottom`设置约束
    /// 一是如果和`UITableViewCell.contentView.bottom`产生约束，那么就会有约束冲突的出现，对于计算真正的高度不准确，产生`BUG`出现
    public lazy var view:UIView = {
        let v = UIView(frame: .zero)
        return v
    }()
    /// 需要刷新高度闭包
    typealias NeedReloadCellHeightHandle = () -> Void
    /// 需要刷新高度闭包
    var needReloadCellHeightHandle:NeedReloadCellHeightHandle?
    
    /// 立即刷新`Cell`高度完毕闭包
    /// - Parameter isCompletion: 是否刷新完毕
    public typealias ReloadCellHeightCompletion = (_ isCompletion:Bool) -> Void
    /// 立即执行刷新高度操作
    /// - Parameter completionHandle: 刷新完毕需要执行`completionHandle`
    typealias ReloadCellHeightHandle = (_ completionHandle:@escaping ReloadCellHeightCompletion) -> Void
    /// 需要刷新`UITableViewCell`高度闭包
    var reloadCellHeightHandle:ReloadCellHeightHandle?
}
#endif
