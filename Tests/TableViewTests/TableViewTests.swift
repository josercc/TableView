import XCTest
@testable import TableView

final class TableViewTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        class Cell1: UITableViewCell {}
        class Cell2: UITableViewCell {}
        let tableView = UITableView(frame: .zero, style: .plain)
        let dataSource = TableView(tableView: tableView)
        dataSource.clearData()
        dataSource.addGroup { (group) in
            group.addCell(Cell1.self) { (cell) in
                cell.data = ["1"]
                cell.config(Cell1.self, String.self) { (tableView, cell, data, indexPath, index) in
                    cell.textLabel?.text = data
                }
            }
            group.addCell(Cell2.self) { (cell) in
                cell.data = ["2","3"]
                cell.config(Cell2.self, String.self) { (tableView, cell, data, indexPath, index) in
                    cell.textLabel?.text = data
                }
            }
        }
        dataSource.reloadData()
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
