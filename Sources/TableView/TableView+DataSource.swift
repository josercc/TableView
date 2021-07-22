//
//  TableView+DataSource.swift
//  PinealAi
//
//  Created by 张行 on 2020/6/2.
//  Copyright © 2020 zhanghang. All rights reserved.
//

#if canImport(UIKit)
import UIKit

extension TableView {
    /// 代理和数据源
    open class DataSource:NSObject, UITableViewDataSource, UITableViewDelegate {
        /// 弱引用的`TableView`
        public weak var tableView:TableView?

        open func numberOfSections(in tableView: UITableView) -> Int {
            return self.tableView?.groups.count ?? 0
        }
        
        open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            guard let group = self.tableView?.groups[section] else {
                return 0
            }
            return group.cellCount()
        }
        
        open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            guard let group = self.tableView?.groups[indexPath.section],
                  let cellIndex = group.cellIndex(indexPath: indexPath) else {
                return UITableViewCell()
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIndex.0.identifier, for: indexPath)
            if let block = cellIndex.0.configCell {
                block(tableView,cell,indexPath,cellIndex.1)
            }
            if let automaticDimensionCell = cell as? AutomaticDimensionCell {
                automaticDimensionCell.ad.needReloadCellHeightHandle = {
                    cell.contentView.layoutIfNeeded()
                    cellIndex.0.automaticDimensionHeights[indexPath] = automaticDimensionCell.ad.view.frame.maxY
                }
                automaticDimensionCell.ad.reloadCellHeightHandle = { completionHandle in
                    automaticDimensionCell.needReloadHeight()
                    if #available(iOS 11.0, *) {
                        tableView.performBatchUpdates({}, completion: {completionHandle($0)})
                    } else {
                        tableView.beginUpdates()
                        tableView.endUpdates()
                        completionHandle(true)
                    }
                }
                if !cellIndex.0.automaticDimensionHeights.keys.contains(indexPath)
                    && cellIndex.0.height == UITableView.automaticDimension {
                    automaticDimensionCell.needReloadHeight()
                }
            }
            return cell
        }
        
        open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            guard let group = self.tableView?.groups[indexPath.section],
                  let cellIndex = group.cellIndex(indexPath: indexPath) else {
                return
            }
            if let block = cellIndex.0.didSelectCell {
                block(tableView,cellIndex.0.data[cellIndex.1],indexPath,cellIndex.1)
            }
        }
        
        open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            guard let group = self.tableView?.groups[indexPath.section],
                  let cellIndex = group.cellIndex(indexPath: indexPath) else {
                return UITableView.automaticDimension
            }
            if let customHeightHandle = cellIndex.0.customHeightHandle {
                let data = cellIndex.0.data[cellIndex.1]
                return customHeightHandle(tableView,cellIndex.0,data,indexPath,cellIndex.1)
            }
            if let automaticDimensionHeight = cellIndex.0.automaticDimensionHeights[indexPath],
               cellIndex.0.height == UITableView.automaticDimension{
                return automaticDimensionHeight
            }
            return cellIndex.0.height
        }
        
        open func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
            guard let header = self.tableView?.groups[section].header,
                  let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: header.identifier) else {
                return nil
            }
            if let block = header.configHeaderFooter {
                block(tableView,headerView,section)
            }
            return headerView
        }
        
        open func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
            guard let footer = self.tableView?.groups[section].footer,
                  let footerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: footer.identifier) else {
                return nil
            }
            if let block = footer.configHeaderFooter {
                block(tableView,footerView,section)
            }
            return footerView
        }
        
        open func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
            guard let header = self.tableView?.groups[section].header else {
                return 0
            }
            return header.height
        }
        
        open func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
            guard let footer = self.tableView?.groups[section].footer else {
                return 0
            }
            return footer.height
        }
    }
}

#endif
