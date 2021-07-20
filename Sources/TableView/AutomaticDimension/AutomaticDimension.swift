//
//  AutomaticDimension.swift
//  File
//
//  Created by joser on 2021/7/19.
//

import Foundation
import UIKit

/// 自动计算高度对象
public class AutomaticDimension {
    /// 布局对应的底部视图
    public lazy var view:UIView = {
        let v = UIView(frame: .zero)
        return v
    }()
    /// 需要刷新高度
    public typealias NeedReloadCellHeightHandle = () -> Void
    var needReloadCellHeightHandle:NeedReloadCellHeightHandle?
    
    /// 刷新`Cell`高度完毕
    /// - Parameter isCompletion: 是否刷新完毕
    public typealias ReloadCellHeightCompletion = (_ isCompletion:Bool) -> Void
    /// 立即执行刷新高度操作
    public typealias ReloadCellHeightHandle = (_ completionHandle:@escaping ReloadCellHeightCompletion) -> Void
    var reloadCellHeightHandle:ReloadCellHeightHandle?
}
