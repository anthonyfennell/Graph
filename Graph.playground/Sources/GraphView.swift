import UIKit
import Foundation
import PlaygroundSupport

public struct Point {
    public let x: Date
    public let y: Float
    
    public init(x: Date, y: Float) {
        self.x = x
        self.y = y
    }
}

public struct GraphItem {
    public let identifier: String
    public let color: UIColor
    public let average: Float
    public let points: [Point]
    
    public init(identifier: String, color: UIColor, average: Float, points: [Point]) {
        self.identifier = identifier
        self.color = color
        self.average = average
        self.points = points
    }
}

private enum Region {
    case title
    case verticalAxis
    case horizontalAxis
    case graph
}

public struct StringItem {
    public let nsstring: NSString
    public let wordSize: CGSize
    public let attributes: [NSAttributedString.Key: Any]
    
    public init(nsstring: NSString, wordSize: CGSize, attributes: [NSAttributedString.Key: Any]) {
        self.nsstring = nsstring
        self.wordSize = wordSize
        self.attributes = attributes
    }
}

public class GraphView: UIView {
    public var items: [GraphItem] = []
    
    // MARK: - Colors
    public var gradientStartColor: UIColor = UIColor.blue.withAlphaComponent(0.85)
    public var gradientEndColor: UIColor = UIColor.blue
    public var axisTextColor = UIColor.white
    public var titleColor = UIColor.white
    public var axisColor = UIColor(hex: 0xF5B7B1)
    
    // MARK: - Text
    public var titleText: String = "Title"
    
    private let axisLineWidth: CGFloat = 2.0
    private let lineWidth: CGFloat = 1.5
    private let circleRadius: CGFloat = 2.0
    private let dashPattern: [CGFloat] = [2.0, 3.0]
    private let zeroDashPattern: [CGFloat] = [5.0, 5.0]
    private let graphInset = UIEdgeInsets(top: 30, left: 45, bottom: 30, right: 0)
    private let monthFormatter = DateFormatter()
    
    private var maxYValue: Int = 0
    private var minYValue: Int = 0
    private var regionSlices: [Region: CGRect] = [:]
    
    
    // MARK: - Life Cycle
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        contentMode = .redraw
        setup()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public override func draw(_ rect: CGRect) {
        setMaxMinValues()
        sliceRegions(for: rect)
        drawBackgroundGradient(inRect: rect)
        drawGraphAxis()
        drawHorizontalAxisLines()
        drawVerticalAxisLines()
        drawZeroAxis()
        drawGraphPoints()
        drawTitleLabel()
        drawYAxisLabels()
        drawXAxisLabels()
    }
    
    private func setup() {
        monthFormatter.dateFormat = "MMM"
    }
    
    private func sliceRegions(for bounds: CGRect) {
        regionSlices = [:]
        let rect = bounds.insetBy(dx: 5, dy: 5)
        var slices: (slice: CGRect, remainder: CGRect)
        var remainder: CGRect
        
        slices = rect.divided(atDistance: graphInset.top, from: .minYEdge)
        regionSlices[.title] = slices.slice
        remainder = slices.remainder
        
        slices = remainder.divided(atDistance: graphInset.left, from: .minXEdge)
        let tempLeftSlice = slices.slice
        remainder = slices.remainder
        regionSlices[.verticalAxis] = tempLeftSlice.divided(atDistance: graphInset.bottom, from: .maxYEdge).remainder
        
        slices = remainder.divided(atDistance: graphInset.bottom, from: .maxYEdge)
        regionSlices[.graph] = slices.remainder
        regionSlices[.horizontalAxis] = slices.slice
    }
    
    private func setMaxMinValues() {
        var maxValue: Float = 0
        var minValue: Float = 0
        for item in items {
            for point in item.points {
                if point.y < minValue {
                    minValue = point.y
                }
                if point.y > maxValue {
                    maxValue = point.y
                }
            }
        }
        maxYValue = Int(maxValue)
        minYValue = Int(minValue)
    }
    
    // MARK: - Gradient
    private func drawBackgroundGradient(inRect rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        let colors = [gradientStartColor.cgColor, gradientEndColor.cgColor]
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let colorLocations: [CGFloat] = [0.0, 1.0]
        let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: colorLocations)
        let startPoint = CGPoint.zero
        let endPoint = CGPoint(x: 0, y: rect.height)
        context?.drawLinearGradient(gradient!, start: startPoint, end: endPoint, options: CGGradientDrawingOptions.drawsBeforeStartLocation)
    }
    
    // MARK: - Axis
    private func drawGraphAxis() {
        let path = UIBezierPath()
        self.axisColor.set()
        path.lineWidth = self.axisLineWidth
        let rect = regionSlices[.graph]!
        path.move(to: CGPoint(x: rect.origin.x, y: rect.origin.y))
        path.addLine(to: CGPoint(x: rect.origin.x, y: rect.origin.y + rect.size.height))
        path.addLine(to: CGPoint(x: rect.origin.x + rect.size.width, y: rect.origin.y + rect.size.height))
        path.stroke()
    }
    
    private func drawHorizontalAxisLines() {
        let path = UIBezierPath()
        self.axisColor.set()
        let rect = regionSlices[.graph]!
        let height = rect.size.height
        let spacing = height / 4.0
        var slices = rect.divided(atDistance: spacing, from: .minYEdge)
        
        while slices.slice.size.height.rounded() >= spacing.rounded() {
            let rect = slices.slice
            path.move(to: CGPoint(x: rect.origin.x, y: rect.origin.y + rect.size.height))
            path.addLine(to: CGPoint(x: rect.origin.x + rect.width, y: rect.origin.y + rect.size.height))
            slices = slices.remainder.divided(atDistance: spacing, from: .minYEdge)
        }
        path.setLineDash(dashPattern, count: dashPattern.count, phase: 0.0)
        path.stroke()
    }
    
    private func drawVerticalAxisLines() {
        guard let item = items.first, item.points.count > 0 else {
            return
        }
        
        let path = UIBezierPath()
        self.axisColor.set()
        let rect = regionSlices[.graph]!
        let spacing = rect.width / CGFloat(item.points.count)
        var x = rect.origin.x
        for _ in item.points {
            let y = rect.origin.y
            path.move(to: CGPoint(x: x, y: y))
            path.addLine(to: CGPoint(x: x, y: rect.origin.y + rect.size.height))
            x += spacing
        }
        path.setLineDash(dashPattern, count: dashPattern.count, phase: 2.0)
        path.stroke()
    }
    
    // MARK: - Graph Points
    private func drawGraphPoints() {
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
    
    private func drawCircle(atPoint point: CGPoint) {
        let path = UIBezierPath(arcCenter: point, radius: self.circleRadius, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)
        path.fill()
    }
    
    private func drawZeroAxis() {
        guard minYValue < 0 else {
            return
        }
        let rect = regionSlices[.graph]!
        let path = UIBezierPath()
        path.lineWidth = self.axisLineWidth
        path.move(to: CGPoint(x: rect.origin.x, y: columnYPoint(0)))
        path.addLine(to: CGPoint(x: rect.origin.x + rect.size.width, y: columnYPoint(0)))
        UIColor.red.set()
        path.setLineDash(zeroDashPattern, count: zeroDashPattern.count, phase: 0.0)
        path.stroke()
    }
    
    // MARK: - Layout Point
    private func columnXPoint(_ column: Int) -> CGFloat {
        let rect = regionSlices[.graph]!
        guard let item = items.first, item.points.count > 0 else {
            return rect.origin.x
        }
        
        let spacer = rect.size.width / CGFloat(item.points.count)
        return rect.origin.x + CGFloat(column) * spacer
    }
    
    private func columnYPoint(_ graphPoint: Float) -> CGFloat {
        let rect = regionSlices[.graph]!
        let graphHeight = rect.size.height
        let yMinValue = rect.origin.y + graphHeight
        let stretch: Float = Float(maxYValue - minYValue)
        var relativePoint: Float
        if graphPoint < 0 {
            relativePoint = stretch - Float(maxYValue) + graphPoint
        } else {
            relativePoint = graphPoint - Float(minYValue)
        }
        
        guard graphHeight > 0 && stretch > 0 else {
            return 0
        }
        
        let proportion: CGFloat = CGFloat(relativePoint) / CGFloat(stretch) * graphHeight
        return yMinValue - proportion
    }
    
    // MARK: - Labels
    private func drawTitleLabel() {
        let rect = regionSlices[.title]!
        let labelRect = CGRect(x: rect.origin.x, y: rect.origin.y, width: rect.size.width, height: rect.size.height)
        drawHorizontalCenter(string: self.titleText, in: labelRect, color: self.titleColor, fontSize: 16)
    }
    
    private func drawYAxisLabels() {
        guard let item = items.first, item.points.count > 0 else {
            return
        }
        
        let rect = regionSlices[.verticalAxis]!
        let stretch = maxYValue - minYValue
        let maxValue = maxYValue
        let threeQuarterValue = maxYValue - stretch / 4
        let halfValue = maxYValue - stretch / 2
        let oneQuarterValue = maxYValue - stretch * 3 / 4
        let minValue = minYValue
        
        var y = rect.origin.y - 15
        let x = rect.origin.x
        let height = rect.size.height
        let width = rect.size.width - 5
        let spacing = height / 4
        let stringHeight: CGFloat = 30
        let fontSize: CGFloat = 10
        let color = self.axisTextColor
        drawCenterYRightAlignedX(string: "$\(maxValue)", in: CGRect(x: x, y: y, width: width, height: stringHeight),
                                 color: color, fontSize: fontSize)
        y += spacing
        drawCenterYRightAlignedX(string: "$\(threeQuarterValue)", in: CGRect(x: x, y: y, width: width, height: stringHeight),
                                 color: color, fontSize: fontSize)
        y += spacing
        drawCenterYRightAlignedX(string: "$\(halfValue)", in: CGRect(x: x, y: y, width: width, height: stringHeight), color:
            color, fontSize: fontSize)
        y += spacing
        drawCenterYRightAlignedX(string: "$\(oneQuarterValue)", in: CGRect(x: x, y: y, width: width, height: stringHeight),
                                 color: color, fontSize: fontSize)
        y += spacing
        drawCenterYRightAlignedX(string: "$\(minValue)", in: CGRect(x: x, y: y, width: width, height: stringHeight), color:
            color, fontSize: fontSize)
    }
    
    private func drawXAxisLabels() {
        guard let item = items.first, item.points.count > 0 else {
            return
        }
        
        let rect = regionSlices[.horizontalAxis]!
        let spacing: CGFloat = rect.size.width / CGFloat(item.points.count)
        var x = rect.origin.x - 10
        
        for point in item.points {
            let monthString = monthFormatter.string(from: point.x)
            let labelRect = CGRect(x: x, y: rect.origin.y + 5, width: 22, height: rect.size.height)
            drawHorizontalCenter(string: monthString, in: labelRect, color: self.axisTextColor, fontSize: 10)
            x += spacing
        }
    }
}

extension GraphView {
    private func drawHorizontalCenter(string: String, in rect: CGRect, color: UIColor, fontSize: CGFloat) {
        let item = makeString(text: string, rect: rect, color: color, fontSize: fontSize)
        var wordRect = rect
        wordRect.origin.x = rect.minX + (rect.width - item.wordSize.width) / 2.0
        item.nsstring.draw(in: wordRect, withAttributes: item.attributes)
    }
    
    private func drawCenterYRightAlignedX(string: String, in rect: CGRect, color: UIColor, fontSize: CGFloat) {
        let item = makeString(text: string, rect: rect, color: color, fontSize: fontSize)
        var wordRect = rect
        wordRect.origin.y = rect.minY + (rect.height - item.wordSize.height) / 2.0
        wordRect.origin.x = rect.maxX - item.wordSize.width
        item.nsstring.draw(in: wordRect, withAttributes: item.attributes)
    }
    
    private func makeString(text: String, rect: CGRect, color: UIColor, fontSize: CGFloat) -> StringItem {
        let nsstring = text as NSString
        var attributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.foregroundColor: color,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: fontSize)
        ]
        var wordSize = nsstring.size(withAttributes: attributes)
        var tempFontSize = fontSize
        while wordSize.width > rect.size.width && tempFontSize >= 6 {
            tempFontSize -= 1
            attributes[NSAttributedString.Key.font] = UIFont.systemFont(ofSize: tempFontSize)
            wordSize = nsstring.size(withAttributes: attributes)
        }
        return StringItem(nsstring: nsstring, wordSize: wordSize, attributes: attributes)
    }
}
