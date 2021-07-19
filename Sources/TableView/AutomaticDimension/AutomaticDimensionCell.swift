//
//  AutomaticDimensionCell.swift
//  
//
//  Created by joser on 2021/7/19.
//

import UIKit
import SnapKit

/// 自动计算高度协议
public protocol AutomaticDimensionCell: UITableViewCell {}

public extension AutomaticDimensionCell {
    
    var ad:AutomaticDimension {
        guard let ad = objc_getAssociatedObject(self,
                                                &AutomaticDimensionKey.automaticDismension) as? AutomaticDimension else {
            let ad = AutomaticDimension()
            objc_setAssociatedObject(self,
                                     &AutomaticDimensionKey.automaticDismension,
                                     ad,
                                     .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return ad
        }
        return ad
    }
    
    /// 需要进行刷新高度
    func needReloadHeight() {
        self.ad.needReloadCellHeightHandle?()
    }
    
    /// 设置底部视图的约束
    /// - Parameter constraints: 约束条件
    func setBottomViewConstraints(constraints:AutomaticDimension.Constraints) {
        if let superview = self.ad.view.superview {
            assert(superview == self.contentView, "self.ad.view must add in UITableViewCell ContentView")
        } else {
            self.contentView.addSubview(self.ad.view)
        }
        self.ad.view.snp.remakeConstraints { make in
            make.top.equalTo(constraints.topView.snp.bottom).offset(constraints.top)
            make.leading.trailing.equalTo(self.contentView)
            make.height.equalTo(0)
        }
    }
}

