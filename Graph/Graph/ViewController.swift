//
//  ViewController.swift
//  Graph
//
//  Created by Anthony Fennell on 10/23/18.
//  Copyright © 2018 Anthony Fennell. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    let colors = [UIColor(hex: 0x117A65), UIColor(hex: 0xEC7063), UIColor(hex: 0x7D3C98),
                  UIColor(hex: 0x5DADE2), UIColor(hex: 0xE67E22), UIColor(hex: 0x95A5A6),
                  UIColor(hex: 0x922B21), UIColor(hex: 0x1A5276), UIColor(hex: 0xF4D03F),
                  UIColor(hex: 0x52BE80)]
    weak var barGraph: BarGraphView?
    weak var lineGraph: LineGraphView?
    weak var barGraph2: BarGraphView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addGraphs()
        addTapGesture()
    }
    
    func addTapGesture() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(updateGraphData))
        gesture.numberOfTapsRequired = 2
        gesture.numberOfTouchesRequired = 1
        view.addGestureRecognizer(gesture)
    }
    
    @objc func updateGraphData() {
        self.lineGraph?.items = createGraphItems()
        self.barGraph?.items = createSinglePointItems()
        
        self.lineGraph?.setNeedsDisplay()
        self.barGraph?.setNeedsDisplay()
    }
    
    func addGraphs() {
        let yOffset: CGFloat = 0
        let xOffset: CGFloat = 5
        let height = (view.bounds.size.height) / 2.0 - yOffset
        let width = view.bounds.size.width - xOffset * 2
        var y: CGFloat = yOffset
        
        let graph1 = BarGraphView(frame: CGRect(x: xOffset, y: y, width: width, height: height))
        graph1.items = createSinglePointItems()
        graph1.titleText = "Bar Graph"
        graph1.gradientStartColor = UIColor(hex: 0x273746)
        graph1.gradientEndColor = UIColor(hex: 0x566573)
        self.scrollView.addSubview(graph1)
        self.barGraph = graph1
        
        y += height
        let graph2 = LineGraphView(frame: CGRect(x: xOffset, y: y, width: width, height: height))
        graph2.items = createGraphItems()
        graph2.titleText = "Line Graph"
        graph2.gradientStartColor = UIColor(hex: 0x273746)
        graph2.gradientEndColor = UIColor(hex: 0x566573)
        self.scrollView.addSubview(graph2)
        self.lineGraph = graph2
        
        y += height
        let graph3 = BarGraphView(frame: CGRect(x: xOffset, y: y, width: width, height: height))
        graph3.items = createSinglePointItems()
        graph3.titleText = "Bar Graph"
        graph3.gradientStartColor = UIColor(hex: 0x273746)
        graph3.gradientEndColor = UIColor(hex: 0x566573)
        self.scrollView.addSubview(graph3)
        self.barGraph2 = graph3
        
        self.scrollView.showsHorizontalScrollIndicator = true
        self.scrollView.contentSize = CGSize(width: view.bounds.size.width, height: height * 3 + yOffset)
    }

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
            let y = Float.random(in: -300 ... 500)
            let point = Point(x: date, y: y)
            let color = colors[index % lastIndex]
            let item = GraphItem(identifier: "Beans", color: color, average: 0.0, points: [point])
            items.append(item)
        }
        return items.sorted { $0.points.first!.y > $1.points.first!.y }
    }
}

