//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport

struct Point {
    let x: Date
    let y: Float
}

struct GraphItem {
    let identifier: String
    let color: UIColor
    let average: Float
    let points: [Point]
}

private enum Region {
    case title
    case verticalAxis
    case horizontalAxis
    case graph
}

class GraphView: UIView {
    var items: [GraphItem] = []
    
    // MARK: - Colors
    var gradientStartColor: UIColor = UIColor.blue.withAlphaComponent(0.85)
    var gradientEndColor: UIColor = UIColor.blue
    var axisTextColor = UIColor.white
    var titleColor = UIColor.white
    var axisColor = UIColor(hex: 0xF5B7B1)
    
    // MARK: - Text
    var titleText: String = "Title"
    
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
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        contentMode = .redraw
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    override func draw(_ rect: CGRect) {
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
        let proportion: CGFloat = CGFloat(relativePoint) / CGFloat(stretch) * graphHeight
        return yMinValue - proportion
    }
    
    // MARK: - Labels
    private func drawTitleLabel() {
        guard let item = items.first, item.points.count > 0 else {
            return
        }
        
        let rect = regionSlices[.title]!
        let labelRect = CGRect(x: rect.origin.x, y: rect.origin.y, width: rect.size.width, height: rect.size.height)
        draw(string: self.titleText, in: labelRect, color: self.titleColor, fontSize: 16)
    }
    
    private func drawYAxisLabels() {
        let rect = regionSlices[.verticalAxis]!
        let stretch = maxYValue - minYValue
        let maxValue = maxYValue
        let threeQuarterValue = maxYValue - stretch / 4
        let halfValue = maxYValue - stretch / 2
        let oneQuarterValue = maxYValue - stretch * 3 / 4
        let minValue = minYValue
        
        let y = rect.origin.y - 5
        let x = rect.origin.x
        let height = rect.size.height
        let width = rect.size.width - 5
        let color = self.axisTextColor
        draw(string: "$\(maxValue)", in: CGRect(x: x, y: y, width: width, height: 30), color: color, fontSize: 10)
        draw(string: "$\(threeQuarterValue)", in: CGRect(x: x, y: y + height / 4, width: width, height: 30), color: color, fontSize: 10)
        draw(string: "$\(halfValue)", in: CGRect(x: x, y: y + height / 2, width: width, height: 30), color: color, fontSize: 10)
        draw(string: "$\(oneQuarterValue)", in: CGRect(x: x, y: y + height * 3 / 4, width: width, height: 30), color: color, fontSize: 10)
        draw(string: "$\(minValue)", in: CGRect(x: x, y: y + height, width: width, height: 30), color: color, fontSize: 10)
    }
    
    private func drawXAxisLabels() {
        guard let item = items.first, item.points.count > 0 else {
            return
        }
        
        let rect = regionSlices[.horizontalAxis]!
        let spacing: CGFloat = rect.size.width / CGFloat(item.points.count)
        var x = rect.origin.x - 8
        
        for point in item.points {
            let monthString = monthFormatter.string(from: point.x)
            let labelRect = CGRect(x: x, y: rect.origin.y + 5, width: 22, height: rect.size.height)
            draw(string: monthString, in: labelRect, color: self.axisTextColor, fontSize: 11)
            x += spacing
        }
    }
}

extension GraphView {
    private func draw(string: String, in rect: CGRect, color: UIColor, fontSize: CGFloat) {
        let nsstring = string as NSString
        var attributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.foregroundColor: color,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: fontSize)
        ]
        
        var wordSize = nsstring.size(withAttributes: attributes)
        var wordRect = rect
        var tempFontSize = fontSize
        while wordSize.width > rect.size.width && tempFontSize >= 7 {
            tempFontSize -= 1
            attributes[NSAttributedString.Key.font] = UIFont.systemFont(ofSize: tempFontSize)
            wordSize = nsstring.size(withAttributes: attributes)
        }
        
        // Center the text, may not want this if the text barely fits
        wordRect.origin.x = rect.minX + (rect.width - wordSize.width) / 2.0
        nsstring.draw(in: wordRect, withAttributes: attributes)
    }
}


extension Date {
    init(year : Int, month : Int, day : Int) {
        let calendar = Calendar.current
        var dateComponent = DateComponents()
        dateComponent.year = year
        dateComponent.month = month
        dateComponent.day = day
        self.init(timeInterval:0, since:calendar.date(from: dateComponent)!)
    }
    
    fileprivate var calender: Calendar {
        return Calendar.current
    }
    
    mutating func nextMonth() {
        self = createNextMonth()
    }
    
    fileprivate func createNextMonth() -> Date {
        guard let date = self.calender.date(byAdding: .month, value: 1, to: self) else {
            return Date()
        }
        
        var components = self.calender.dateComponents([.month, .year], from: date)
        components.day = 1
        return self.calender.date(from: components)!
    }
}

extension UIColor {
    convenience init(hex: Int) {
        let red = CGFloat(hex >> 16) / 255.0
        let green = CGFloat((hex >> 8) & 0xFF) / 255.0
        let blue = CGFloat(hex & 0xFF) / 255.0
        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}

func createGraphItems() -> [GraphItem] {
    let colors = [UIColor(hex: 0x117A65), UIColor(hex: 0xEC7063), UIColor(hex: 0x7D3C98),
                  UIColor(hex: 0x5DADE2), UIColor(hex: 0xE67E22), UIColor(hex: 0x95A5A6),
                  UIColor(hex: 0x922B21), UIColor(hex: 0x1A5276), UIColor(hex: 0xF4D03F),
                  UIColor(hex: 0x52BE80)]
    let startDate = Date(year: 2017, month: 1, day: 1)
    let endDate = Date(year: 2017, month: 12, day: 31)
    var currentMonth = startDate
    var items: [GraphItem] = []
    
    for index in 0 ... 9 {
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
        let color = colors[index]
        let item = GraphItem(identifier: "Jelly Fish", color: color, average: 0.0, points: points)
        items.append(item)
        currentMonth = startDate
    }
    
    return items
}

let graph = GraphView(frame: CGRect(x: 0, y: 0, width: 400, height: 400))
graph.items = createGraphItems()
graph.titleText = "Analysis"
graph.gradientStartColor = UIColor(hex: 0x273746)
graph.gradientEndColor = UIColor(hex: 0x566573)
graph.setNeedsDisplay()

