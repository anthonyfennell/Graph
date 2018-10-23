//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport

let colors = [UIColor(hex: 0x117A65), UIColor(hex: 0xEC7063), UIColor(hex: 0x7D3C98),
              UIColor(hex: 0x5DADE2), UIColor(hex: 0xE67E22), UIColor(hex: 0x95A5A6),
              UIColor(hex: 0x922B21), UIColor(hex: 0x1A5276), UIColor(hex: 0xF4D03F),
              UIColor(hex: 0x52BE80)]

func createGraphItems() -> [GraphItem] {
    let startDate = Date(year: 2017, month: 1, day: 1)
    let endDate = Date(year: 2017, month: 12, day: 31)
    var currentMonth = startDate
    let lastIndex = colors.count - 1
    var items: [GraphItem] = []
    
    for index in 0 ... lastIndex {
        var points: [Point] = []
        let startValue = Float.random(in: 2 ... 500)
        let multiplier = Float.random(in: 0.1 ... 1.5)
        let goingUp = Bool.random()
        let upDown: Float = goingUp ? 1 : -1
        print("Start \(startValue)")
        print("Up? \(goingUp)")
        print("Multiplier \(multiplier)")
        var y = startValue * upDown
        while currentMonth <= endDate {
            y = y * multiplier
            print(y)
            let point = Point(x: currentMonth, y: y)
            points.append(point)
            currentMonth.nextMonth()
        }
        print("--------")
        let color = colors[index % lastIndex]
        let item = GraphItem(identifier: "Jelly Fish", color: color, average: 0.0, points: points)
        items.append(item)
        currentMonth = startDate
    }
    
    return items
}

func createSinglePointItems() -> [GraphItem] {
    let lastIndex = colors.count - 1
    var items: [GraphItem] = []
    for index in 0 ... lastIndex {
        let date = Date(year: 2017, month: 2, day: 4)
        let y = Float.random(in: -100 ... 500)
        let point = Point(x: date, y: y)
        let color = colors[index % lastIndex]
        let item = GraphItem(identifier: "Beans", color: color, average: 0.0, points: [point])
        items.append(item)
    }
    return items
}

let graph = GraphView(frame: CGRect(x: 0, y: 0, width: 400, height: 400))
graph.items = createGraphItems()
graph.titleText = "Analysis"
graph.gradientStartColor = UIColor(hex: 0x273746)
graph.gradientEndColor = UIColor(hex: 0x566573)
graph.setNeedsDisplay()

