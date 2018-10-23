import Foundation

public extension Date {
    public init(year : Int, month : Int, day : Int) {
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
