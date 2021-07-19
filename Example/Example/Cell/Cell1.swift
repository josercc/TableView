//
//  Cell1.swift
//  Cell1
//
//  Created by joser on 2021/7/19.
//

import UIKit
import TableView
import SnapKit

class Cell1: UITableViewCell, AutomaticDimensionCell {
    
    lazy var titleLabel:UILabel = {
        let label = UILabel(frame: .zero)
        label.preferredMaxLayoutWidth = UIScreen.main.bounds.width - 16 - 16
        label.numberOfLines = 0
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.addSubview(self.titleLabel)
        self.titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(16)
            make.trailing.equalTo(-16)
            make.top.equalTo(10)
        }
        self.setBottomViewConstraints(constraints: .init(topView: self.titleLabel, top: 10))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
