# TableView

一个基于`Swift`封装的`UITableView`的数据源管理器,可以快速方便的进行搭建`UITableView`的界面。支持自动计算高度，支持刷新高度。

OC版本功能比较齐全的库[点击这里](https://github.com/josercc/ZHTableViewGroup)

## 安装

```swift
.Package(url: "http://github.com/josercc/TableView.git", from: "1.0.0")
```

## 使用

### 创建一个默认代理数据源

```swift
let tableView = UITableView(frame: .zero, style: .plain)
let dataSource = TableView(tableView: tableView)
```

这样就创建一个实现默认数据源和代理，我们只需要关心我们表格的怎么组成即可。怎么组成一个简单可扩展的数据源，可以看下面的教程。(In this way, we can create a default data source and proxy. We only need to care about the composition of our table.How to form a simple and extensible data source, you can see the following tutorial.)

### 创建一个自定义的代理数据源

```swift
class CustomDataSource: TableView.DataSource {}
let tableView = UITableView(frame: .zero, style: .plain)
let dataSource = TableView(tableView: tableView, dataSource: CustomDataSource())
```

对于自定义代理数据源，我们只需要创建一个类继承`TableView.DataSource`即可。对于默认实现的方法如果进行改动可以进行重写。对于没有默认实现的方法进行实现即可。

默认实现的代理和数据源方法如下

```swift
open func numberOfSections(in tableView: UITableView) -> Int
```

```swift
open func tableView(_ tableView: UITableView, 
											numberOfRowsInSection section: Int) -> Int
```

```swift
open func tableView(_ tableView: UITableView, 
											cellForRowAt indexPath: IndexPath) -> UITableViewCell
```

```swift
open func tableView(_ tableView: UITableView, 
											didSelectRowAt indexPath: IndexPath)
```

```swift
open func tableView(_ tableView: UITableView, 
											heightForRowAt indexPath: IndexPath) -> CGFloat
```

```swift
open func tableView(_ tableView: UITableView, 
											viewForHeaderInSection section: Int) -> UIView?
```

```swift
open func tableView(_ tableView: UITableView, 
											viewForFooterInSection section: Int) -> UIView?
```

```swift
open func tableView(_ tableView: UITableView, 
											heightForHeaderInSection section: Int) -> CGFloat
```

```swift
open func tableView(_ tableView: UITableView, 
											heightForFooterInSection section: Int) -> CGFloat
```

## 怎么配置代理源(How to configure proxy source)

对于`UITableView`都是最少一个`Group`分组的。随意我们的配置基于`Group`之下进行配置。

我们添加一个`Group`分组

```swift
dataSource.addGroup { group in
	/// 添加对应的Cell
}
```

对于`UITableView`的`Group`是有对应的`Header`和`Footer`，我们的`group`对象也是可以简单的添加`Header`和`Footer`的。

在已有的`Group`添加一个`Header`

```swift
group.addHeader(UITableViewHeaderFooterView.self) { header in
		/// 对于Header进行配置
}
```

> `group.addHeader()` 函数支持`UITableViewHeaderFooterView`类及其子类。

在已有的Group添加一个Footer

```swift
group.addFooter(UITableViewHeaderFooterView.self) { footer in
		/// 对于Footer进行配置
}
```

> group.addFooter()函数支持`UITableViewHeaderFooterView`类及其子类。

对于添加UITableViewCell这里称作为添加Cell,这里的Cell指代一个或者多个一样样式的UITableViewCell。对于普通的列表还是复杂的界面组成都十分的方便

在已有的Group添加一个或者多个一样样式的UITableViewCell

```swift
group.addCell(UITableViewCell.self) { cell in

}
```

不管是添加Header或者添加Footer还是添加Cell，都可以设定一个自定义的标识符。默认会将当前类的类型作为唯一标识符。代码实现如下

```swift
identifier:String = "\(C.self)"
```

如果想在一个界面一个样式走两套重用的地方使用自定义标识符十分的有用。

对于关于Header和Footer和Cell的详细配置请参考下面的说明

## 怎么设置自动获取高度

在内部实现了自动计算UITableViewCell的高度，并且做了缓存逻辑处理，在使用起来也是十分的简单。

### 实现AutomaticDimensionCell协议

将UITableViewCell类或者子类实现`AutomaticDimensionCell`协议。之后在初始化布局的最后执行下面的代码。

```swift
setBottomViewConstraints(constraints:AutomaticDimension.Constraints)
```

关于AutomaticDimension.Constraints的详细参数如下

```swift
/// 约束的顶部视图
public let topView:UIView
/// 约束和`topView`的间距
public let top:CGFloat
```

接收两个参数，分别是布局的最后一个视图，第二个参数是布局距离UITableViewCell.contentView.bottom的距离。协议在执行这个方法之后会在UITableViewCell.contentView添加一个高度为0的参考UIView,自动计算高度会根据创建UIView的maxY的大小进行设置。

⚠️值得注意的是，将之前所有依赖UITableViewCell.contentView.bottom的布局全部修改为self.ad.view.bottom。这样会在CellForRow的时候赋值完毕检测高度还没有初始化，就会自动进行初始化一个合适的高度。

### 刷新UITableViewCell的高度

这里有两个刷新UITableViewCell的高度的方法，分别是

```swift
func needReloadHeight()
```

needReloadHeight这个方法只会将当前Cell计算出self.ad.view.maxY的高度存放在缓存里面，会在下面下次调用HeightForRow的时候进行调用。

```swift
func reloadHeight(completionHandle:@escaping AutomaticDimension.ReloadCellHeightCompletion)
```

reloadHeight这个方法会先将当前Cell计算出self.ad.view.maxY的高度存放在缓存里面，立马执行刷新操作，只会重新走HeightForRow的方法而已。

这个方法有一个必须实现的闭包函数，闭包有一个参数代表这次更新是否完毕。

关于自动计算高度实现和目前市面上的参考对比。

我也体验过市面上开源Star很多的库，很多都是在HeightForRow返回一个UITableViewCell进行让自定义配置，配置代码和CellForRow的一致。

对于我发现一些问题还有一个bug。那就是我在实现自动根据文本内容更新UITextView所在的高度，或者根据加载所给定的图片更新对应的高度。

那么我们在UITableViewCell就需要一个闭包，告诉外界我需要更新高度，甚至传递回来一个高度。

如果按照市面上在CellForRow和HeightForRow就会赋值两次，可能创建了两次闭包，可能就会一直回掉一直刷新的死循环。

如果图片宽度一定，根据图片的高度和个数动态更新UITableViewCell的高度。如果提前知道图片的长宽比还好，如果不知道就需要下载完毕或者从缓存读取完毕之后才能获取。

不管是下载或者本地读取都是一个异步闭包，那么在HeightForRow执行配置完毕获取高度时候是默认状态的高度，不符合我们需要的实际高度，这就出现了BUG。

这个库的思路是在CellForRow监听needReloadHeight执行，当我们UITextView文本变化或者加载图片完毕更新对应约束之后调用needReloadHeight。会读取当前的UITableViewCell计算self.ad.view.maxY的高度进行缓存起来。

⚠️如果最后参考布局的UIView变化，需要重新调用setBottomViewConstraints进行更新，不然计算的高度就会不正确。

## 自定义UITableViewCell的高度

```swift
public func height<D>(_ dataType:D.Type,
                      _ block:@escaping CustomHeightHandle<D>)
```

这个允许自定义调用其他第三方库，或者自己去实现计算高度的逻辑。

## 详细的API

### Header和Footer的配置

设置数据源

```swift
public var data:Any?
```

设置高度

```swift
public var height:CGFloat = UITableView.automaticDimension
```

⚠️目前还不支持自动计算高度，还有自定义高度。

### Cell的配置

设置数据源

```swift
public var data:[Any] = []
```

⚠️接收一个数组，如果赋值的数据来源于其他属性，可以将这个参数设置为[""]。

设置高度

```swift
public var height:CGFloat = UITableView.automaticDimension
```

配置UITableViewCell的数据

```swift
public func config<T:UITableViewCell, D>(_ cellType:T.Type,
                                         _ dataType:D.Type,
                                         _ block:@escaping ConfigBlock<T,D>)
```

点击UITableViewCell的回掉

```swift
public func didSelect<T:UITableViewCell, D>(_ cellType:T.Type,
                                            _ dataType:D.Type,
                                            _ block:@escaping DidSelectBlock<T,D>)
```

自定义UITableViewCell的高度

```swift
public func height<D>(_ dataType:D.Type,
                      _ block:@escaping CustomHeightHandle<D>)
```

