//
//  LineGraphView.swift
//  Graph
//
//  Created by Anthony Fennell on 10/23/18.
//  Copyright © 2018 Anthony Fennell. All rights reserved.
//

import UIKit

public class LineGraphView: GraphView {
    public override func drawGraphPoints() {
        for item in items {
            let path = UIBezierPath()
            path.lineWidth = self.lineWidth
            item.color.set()
            drawGraph(inPath: path, atPoints: item.points)
        }
    }
    
    private func drawGraph(inPath path: UIBezierPath, atPoints points: [Point]) {
        guard points.count > 0 else {
            return
        }
        
        var cgPoint: CGPoint
        for (index, point) in points.enumerated() {
            cgPoint = CGPoint(x: columnXPoint(index), y: columnYPoint(point.y))
            if index == 0 {
                path.move(to: cgPoint)
            } else {
                path.addLine(to: cgPoint)
            }
            drawCircle(atPoint: cgPoint)
        }
        path.stroke()
    }
}
