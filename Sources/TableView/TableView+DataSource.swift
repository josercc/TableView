//
//  TableView+DataSource.swift
//  PinealAi
//
//  Created by 张行 on 2020/6/2.
//  Copyright © 2020 zhanghang. All rights reserved.
//

import UIKit

extension TableView {
    open class DataSource:NSObject, UITableViewDataSource, UITableViewDelegate {
        public weak var tableView:TableView?
        public init(_ tableView:TableView?) {
            self.tableView = tableView
            super.init()
        }
        
        open func numberOfSections(in tableView: UITableView) -> Int {
            guard let count = self.tableView?.groups.count else {
                return 0
            }
            return count
        }
        
        open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            guard let groups = self.tableView?.groups else {
                return 0
            }
            return groups[section].cellCount()
        }
        
        open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            guard let groups = self.tableView?.groups else {
                return UITableViewCell()
            }
            let group = groups[indexPath.section]
            guard let cellIndex = group.cellIndex(indexPath: indexPath) else {
                return UITableViewCell()
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIndex.0.identifier, for: indexPath)
            if let block = cellIndex.0.configCell {
                block(tableView,cell,indexPath,cellIndex.1)
            }
            return cell
        }
        
        open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            guard let groups = self.tableView?.groups else {
                return
            }
            let group = groups[indexPath.section]
            guard let cellIndex = group.cellIndex(indexPath: indexPath) else {
                return
            }
            if let block = cellIndex.0.didSelectCell {
                block(tableView,cellIndex.0.data[cellIndex.1],indexPath,cellIndex.1)
            }
        }
        
        open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            guard let groups = self.tableView?.groups else {
                return UITableView.automaticDimension
            }
            let group = groups[indexPath.section]
            guard let cellIndex = group.cellIndex(indexPath: indexPath) else {
                return UITableView.automaticDimension
            }
            return cellIndex.0.height
        }
        
        open func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
            guard let groups = self.tableView?.groups else {
                return nil
            }
            let group = groups[section]
            guard let header = group.header, let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: header.identifier) else {
                return nil
            }
            if let block = header.configHeaderFooter {
                block(tableView,headerView,section)
            }
            return headerView
        }
        
        open func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
            guard let groups = self.tableView?.groups else {
                return nil
            }
            let group = groups[section]
            guard let footer = group.footer, let footerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: footer.identifier) else {
                return nil
            }
            if let block = footer.configHeaderFooter {
                block(tableView,footerView,section)
            }
            return footerView
        }
        
        open func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
            guard let groups = self.tableView?.groups else {
                return 0
            }
            let group = groups[section]
            guard let header = group.header else {
                return 0
            }
            return header.height
        }
        
        open func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
            guard let groups = self.tableView?.groups else {
                return 0
            }
            let group = groups[section]
            guard let footer = group.footer else {
                return 0
            }
            return footer.height
        }
    }
}
