//
//  BarGraphView.swift
//  Graph
//
//  Created by Anthony Fennell on 10/23/18.
//  Copyright © 2018 Anthony Fennell. All rights reserved.
//

import UIKit

public class BarGraphView: GraphView {
    private let barSpacing: CGFloat = 6
    
    public override func drawGraphPoints() {
        guard items.count > 0 else {
            return
        }
        
        let zeroYPoint = columnYPoint(0)
        let graphRegion = regionSlices[.graph]!
        let spacing = graphRegion.size.width / CGFloat(items.count) - barSpacing
        var x: CGFloat = graphRegion.origin.x + barSpacing / 2
        for item in items {
            let path = UIBezierPath()
            path.lineWidth = self.lineWidth
            item.color.set()
            if let point = item.points.first {
                let rect = CGRect(x: x, y: graphRegion.origin.y, width: spacing, height: graphRegion.size.height)
                drawGraph(withPoint: point, inRect: rect, zeroPoint: zeroYPoint)
            }
            x += spacing + barSpacing
        }
    }
    
    private func drawGraph(withPoint point: Point, inRect rect: CGRect, zeroPoint: CGFloat) {
        let y = columnYPoint(point.y)
        let width = rect.size.width
        let barRect: CGRect
        if point.y < 0 {
            // Downward
            barRect = CGRect(x: rect.origin.x, y: zeroPoint, width: width, height: y - zeroPoint)
        } else {
            // Upward
            barRect = CGRect(x: rect.origin.x, y: zeroPoint - (zeroPoint - y), width: width, height: zeroPoint - y)
        }
        UIRectFill(barRect)
        UIColor.lightGray.set()
        UIRectFrame(barRect)
    }
    
    public override func drawXAxisLabels() {
        guard items.count > 0 else {
            return
        }
        
        let rect = regionSlices[.horizontalAxis]!
        let spacing: CGFloat = rect.size.width / CGFloat(items.count) - barSpacing
        var x = rect.origin.x + barSpacing / 2
        let y = rect.origin.y + 5
        
        for item in items {
            let rect = CGRect(x: x, y: y, width: spacing, height: rect.size.height)
            drawHorizontalCenter(string: item.identifier, in: rect, color: self.axisTextColor, fontSize: 10)
            x += spacing + barSpacing
        }
    }
}
