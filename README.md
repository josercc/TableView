# TableView

一个基于`Swift`封装的`UITableView`的数据源管理器

![image-20200915161256661](https://gitee.com/joser_zhang/upic/raw/master/uPic/image-20200915161256661.png)

## 安装

```swift
.Package(url: "http://pineal.ai:30000/pineal-ios/sub-modules/TableView.git", from: "1.0.0")
```

## 使用

### 创建一个数据源

```swift
public init(tableView:UITableView?)
```

对于`UITableView`不用设置数据源和代理

### 添加数据

#### 添加一个分组

```swift
public func addGroup(_ block:((Group) -> Void))
```

这个`Group`对应`UITableView`的分组，只能添加一个`Header`和一个`Footer`。

##### 添加一个或者一组样式

```swift
public func addCell<T:UITableViewCell>(_ type:T.Type = T.self, _ block:(Cell) -> Void)
```

##### 添加一个Header

```swift
public func addHeader<T:UITableViewHeaderFooterView>(_ type:T.Type, _ block:(HeaderFooter) -> Void)
```

##### 添加一个Footer

```swift
public func addFooter<T:UITableViewHeaderFooterView>(_ type:T.Type, _ block:(HeaderFooter) -> Void)
```

### 加载界面

```swift
public func reloadData()
```

### 清理数据源

⚠️对于页面需要刷新数据源的需要先调用清理数据源方法

```swift
public func clearData()
```

### 一个简单的例子

```swift
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
```

