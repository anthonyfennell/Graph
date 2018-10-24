# Graph
A line and bar graph for displaying dates related to floating points.
```swift
let graph = BarGraphView(frame: CGRect(x: xOffset, y: y, width: width, height: height))
graph.items = createSinglePointItems()
graph.titleText = "Bar Graph"
graph.gradientStartColor = UIColor(hex: 0x273746)
graph.gradientEndColor = UIColor(hex: 0x566573)
```

<img src="https://github.com/anthonyfennell/Graph/blob/master/graph2.png" width=400>
