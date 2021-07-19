//
//  ViewController.swift
//  Example
//
//  Created by joser on 2021/7/19.
//

import UIKit
import TableView
import SnapKit

class ViewController: UIViewController {

    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        return tableView
    }()
    
    lazy var dataSource: TableView = {
        let dataSource = TableView(tableView: self.tableView)
        return dataSource
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(self.tableView)
        self.tableView.snp.makeConstraints { make in
            make.edges.equalTo(UIEdgeInsets.zero)
        }
        var datas:[String] = []
        var text = "asjdas;dsalk"
        for i in 0 ..< 10 {
            text += "daasdadsadsadsads"
            datas.append(text)
        }
        
        
        self.dataSource.clearData()
        self.dataSource.addGroup { group in
            group.addCell(Cell1.self) { cell in
                cell.data = datas
                cell.config(Cell1.self, String.self) { tableView, tableViewCell, data, indexPath, index in
                    tableViewCell.titleLabel.text = data
                }
            }
        }
        self.dataSource.reloadData()
    }
}

