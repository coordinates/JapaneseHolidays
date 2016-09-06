import UIKit
import XCTest
@testable import JapaneseHolidays

class Tests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testHolidaysFor2016() {
        // 2016年の祝日
        let testcases: [(year:Int, month:Int, day:Int, isHoliday:Bool)] = [
            (2016,  1,  1, true),
            (2016,  1, 11, true),
            (2016,  2, 11, true),
            (2016,  3, 20, true),
            (2016,  3, 21, true),
            (2016,  4, 29, true),
            (2016,  5,  3, true),
            (2016,  5,  4, true),
            (2016,  5,  5, true),
            (2016,  7, 18, true),
            (2016,  9, 19, true),
            (2016,  9, 22, true),
            (2016, 10, 10, true),
            (2016, 11,  3, true),
            (2016, 11, 23, true),
            (2016, 12, 23, true),
        ]

        for item in testcases {
            let isHoliday = self.isHoliday(item.year, month: item.month, day: item.day)
            XCTAssert(isHoliday == item.isHoliday, "failed")
        }
    }
    
    func isHoliday(year: Int, month: Int, day: Int) -> Bool {
        guard let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian) else {
            return false
        }
        let components = NSDateComponents()
        components.era = 1
        components.year = year
        components.month = month
        components.day = day
        guard calendar.dateFromComponents(components) != nil else {
            return false
        }
        return true
    }
}
