//
//  Constraints.swift
//  File
//
//  Created by joser on 2021/7/19.
//

#if canImport(UIKit)
import UIKit

public extension AutomaticDimension {
    struct Constraints {
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
