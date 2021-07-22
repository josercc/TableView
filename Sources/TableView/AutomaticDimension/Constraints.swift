//
//  Constraints.swift
//  File
//
//  Created by joser on 2021/7/19.
//

#if canImport(UIKit)
import UIKit
public extension AutomaticDimension {
    /// 设置自动计算高度底部视图的约束条件
    struct Constraints {
        /// 初始化约束条件
        /// - Parameters:
        ///   - topView: `self.ad.view`约束的`top view`视图
        ///   - top: `self.ad.view`距离`top view`的距离
        public init(topView: UIView, top: CGFloat) {
            self.topView = topView
            self.top = top
        }
        
        /// 约束的顶部视图
        public let topView:UIView
        /// 约束和`topView`的间距
        public let top:CGFloat
    }
}
#endif
