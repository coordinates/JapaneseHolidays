//
//  JapaneseHolidays.swift
//  JapaneseHoliday
//
//  Created by Masayoshi Ukida on 2016/07/12.
//  Copyright (c) 2016 Masayoshi Ukida. All rights reserved.
//

import Foundation

public class JapaneseDummy {
    public func dummy() {
        let date = NSDate()
        date.japaneseHoliday()
        date.isJapaneseHoliday()
    }
}

extension String {
    var localized: String {
        let bundle = NSBundle(forClass: JapaneseDummy.self)
        return NSLocalizedString(self, tableName: nil, bundle: bundle, value: "", comment: "")
    }
}

public struct JapaneseHoliday: CustomStringConvertible {
    enum Weekday: Int {
        case Sunday = 1
        case Monday = 2
        case Tuesday = 3
        case Wednesday = 4
        case Thursday = 5
        case Friday = 6
        case Saturday = 7
    }

    private(set) public var title: String
    private(set) public var isObserved: Bool
    private(set) public var year: Int
    private(set) public var month: Int
    var day: Int
    
    private var date: NSDate

    private static let absoluteHolidays:[(title:String, fromYear:Int, toYear:Int, month:Int, day:Int)] = [
        ("New Year's Day".localized, 1948, NSIntegerMax, 1, 1),
        ("Coming of Age Day".localized, 1948, 1999, 1, 15),
        ("Foundation Day".localized, 1967, NSIntegerMax, 2, 11),
        ("The Emperor's Birthday".localized, 1948, 1988, 4, 29),
        ("Greenery Day".localized, 1989, 2006, 4, 29),
        ("Shōwa Day".localized, 2007, NSIntegerMax, 4, 29),
        ("Constitution Memorial Day".localized, 1948, NSIntegerMax, 5, 3),
        ("Greenery Day".localized, 2007, NSIntegerMax, 5, 4),
        ("Children's Day".localized, 1948, NSIntegerMax, 5, 5),
        ("Marine Day".localized, 1996, 2002, 7, 20),
        ("Mountain Day".localized, 2016, NSIntegerMax, 8, 11),
        ("Respect-for-the-Aged Day".localized, 1966, 2002, 9, 15),
        ("Health and Sports Day".localized, 1966, 1999, 10, 10),
        ("Culture Day".localized, 1948, NSIntegerMax, 11, 3),
        ("Labour Thanksgiving Day".localized, 1948, NSIntegerMax, 11, 23),
        ("The Emperor's Birthday".localized, 1989, NSIntegerMax, 12, 23),
        ]
    
    private static let mondayHolidays:[(title:String, fromYear:Int, toYear:Int, month:Int, weekOfMonth:Int)] = [
        ("Coming of Age Day".localized, 2000, NSIntegerMax, 1, 2),
        ("Marine Day".localized, 2003, NSIntegerMax, 7, 3),
        ("Respect-for-the-Aged Day".localized, 2003, NSIntegerMax, 9, 3),
        ("Health and Sports Day".localized, 2000, NSIntegerMax, 10, 2),
        ]
    
    private static let equinoxHolidays:[(title:String, fromYear:Int, toYear:Int, month:Int, basePoint:Double, movePoint:Double, moveYear:Int, resetYear:Int)] = [
        ("Vernal Equinox Day".localized, 1900, 1979, 3, 20.8357, 0.242194, 1980, 1983),
        ("Vernal Equinox Day".localized, 1980, 2099, 3, 20.8431, 0.242194, 1980, 1980),
        ("Autumnal Equinox Day".localized, 1900, 1979, 9, 23.2588, 0.242194, 1980, 1983),
        ("Autumnal Equinox Day".localized, 1980, 2099, 9, 23.2488, 0.242194, 1980, 1980),
    ]
    
    private static let imperialHolidays:[(title:String, year:Int, month:Int, day:Int)] = [
        ("Marriage of Crown Prince Akihito".localized, 1959, 4, 10),
        ("State Funeral of the Shōwa Emperor".localized, 1989, 2, 24),
        ("Official Enthronement Ceremony of Emperor Akihito".localized, 1990, 11, 12),
        ("Marriage of Crown Prince Naruhito".localized, 1993, 6, 9),
        ]
    
    private static var calendar: NSCalendar? = {
        let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        calendar?.locale = NSLocale(localeIdentifier: "ja_JP")
        if let timezone = NSTimeZone(name: "Asia/Tokyo") {
            calendar?.timeZone = timezone
        }
        
        return calendar
    }()
    
    private static var bundle: NSBundle = {
        let bundle = NSBundle(forClass: JapaneseDummy.self)
        return bundle
    }()
    
    public var description: String {
        let dateString = String(format: "%04d-%02d-%02d", self.year, self.month, self.day)
        return String(dateString + ": " + self.title)
    }
    
    init?(title: String, date: NSDate, isObserved: Bool? = false) {
        self.title = title
        self.date = date
        self.isObserved = isObserved!
        
        guard let calendar = JapaneseHoliday.calendar else {
            return nil
        }
        
        self.year = calendar.component(.Year, fromDate: date)
        self.month = calendar.component(.Month, fromDate: date)
        self.day = calendar.component(.Day, fromDate: date)
    }
    
    public static func holidays(year year: Int) -> [JapaneseHoliday] {
        var holidays: [JapaneseHoliday] = []
        guard let calendar = JapaneseHoliday.calendar else {
            return holidays
        }
        
        // 月別に祝日を取得
        for month in 1...12 {
            holidays += self.holidays(year: year, month: month)
        }
        
        //1973年（昭和48年）4月12日 - 改正・施行。
        //  祝日が日曜日の場合はその翌日の月曜日を休日とする振替休日を制定。
        // 振替休日・国民の休日が発生することも考えられるため前後１ヶ月を取得
        if year >= 1973 {
            holidays += self.holidays(year: year-1, month: 12)
            holidays += self.holidays(year: year+1, month: 1)
        }
        
        var tmpHolidays = holidays
        for item in holidays {
            guard year > 1973 || (year == 1973 && item.month > 4) else {
                continue
            }

            // 祝日は日曜か？
            let weekday = calendar.component(.Weekday, fromDate: item.date)
            guard weekday == Weekday.Sunday.rawValue else {
                continue
            }
            
            // 振替
            var nextDate = item.date
            var nextWeekday = weekday
            repeat {
                nextDate = nextDate.dateByAddingTimeInterval(86400)
                nextWeekday = calendar.component(.Weekday, fromDate: nextDate)
            } while (nextWeekday == Weekday.Sunday.rawValue || 0 < holidays.filter { $0.date.compare(nextDate) == .OrderedSame }.count)
            
            if let holiday = JapaneseHoliday(title: item.title  + " " + "'Observed'".localized,
                                           date: nextDate,
                                           isObserved: true) {
                tmpHolidays.append(holiday)
            }
        }
        holidays = tmpHolidays

        // 国民の休日
        // 1985年12月27日 に祝日法が改正され即日施行
        if year > 1985 {
            for item in holidays {
                // 明後日の祝日を確認
                let afterDate = item.date.dateByAddingTimeInterval(86400 * 2)
                guard 0 < (holidays.filter { $0.date.compare(afterDate) == .OrderedSame }.count) else {
                    continue
                }
                
                // 明日が平日かを確認
                let tomorrowDate = item.date.dateByAddingTimeInterval(86400)
                let tomorrowWeekday = calendar.component(.Weekday, fromDate: tomorrowDate)
                guard tomorrowWeekday != Weekday.Sunday.rawValue else {
                    continue
                }
                // 明日が祝日ではないことを確認
                guard 0 == (holidays.filter { $0.date.compare(tomorrowDate) == .OrderedSame }.count) else {
                    continue
                }
                
                if let holiday = JapaneseHoliday(title: "People's Day".localized,
                                                  date: tomorrowDate) {
                    tmpHolidays.append(holiday)
                }
            }
            
            holidays = tmpHolidays
        }
        
        // 並び替え
        holidays.sortInPlace({
            (a, b) in
            
            if a.date.compare(b.date) == .OrderedAscending {
                return true
            }
            
            return false
        })

        // filter
        holidays = holidays.filter { $0.year == year }
        
        return holidays
    }
    
    private static func holidays(year year: Int, month: Int) -> [JapaneseHoliday] {
        var holidays: [JapaneseHoliday] = []
        
        guard let calendar = JapaneseHoliday.calendar else {
            return holidays
        }
        
        // 国民の祝日に関する法律は、1948年（昭和23年）7月20日に公布・即日施行
        guard year > 1948 || (year == 1948 || month > 7) else {
            return holidays
        }
        
        // 春分・秋分の日は2099年までのサポートのため
        guard year < 2100 else {
            return holidays
        }
        
        // absolute holidays
        for item in JapaneseHoliday.absoluteHolidays {
            guard item.fromYear <= year && year <= item.toYear else {
                continue
            }
            guard item.month == month else {
                continue
            }
            
            let components = NSDateComponents()
            components.era = 1
            components.year = year
            components.month = month
            components.day = item.day
            
            guard let date = calendar.dateFromComponents(components) else {
                continue
            }
            
            if let holiday = JapaneseHoliday(title: item.title,
                                              date: date) {
                holidays.append(holiday)
            }
        }
        
        // mondayHoliday
        for item in JapaneseHoliday.mondayHolidays {
            guard item.fromYear <= year && year <= item.toYear else {
                continue
            }
            guard month == item.month else {
                continue
            }
            
            let components = NSDateComponents()
            components.era = 1
            components.year = year
            components.month = month
            components.weekOfMonth = item.weekOfMonth + 1
            components.weekday = Weekday.Monday.rawValue
            
            guard let date = calendar.dateFromComponents(components) else {
                continue
            }
            
            if let holiday = JapaneseHoliday(title: item.title,
                                              date: date) {
                holidays.append(holiday)
            }
        }
        
        // equinoxHolidays
        for item in JapaneseHoliday.equinoxHolidays {
            guard item.fromYear <= year && year <= item.toYear else {
                continue
            }
            guard month == item.month else {
                continue
            }
            
            let day = Int(item.basePoint + item.movePoint * Double(year - item.moveYear)) - Int((year - item.resetYear) / 4)
            let components = NSDateComponents()
            components.era = 1
            components.year = year
            components.month = month
            components.day = day
            
            guard let date = calendar.dateFromComponents(components) else {
                continue
            }

            if let holiday = JapaneseHoliday(title: item.title,
                                              date: date) {
                holidays.append(holiday)
            }
        }
        
        // imperialHolidays
        for item in JapaneseHoliday.imperialHolidays {
            guard year == item.year && month == item.month else {
                continue
            }
            
            let components = NSDateComponents()
            components.era = 1
            components.year = year
            components.month = month
            components.day = item.day
            
            guard let date = calendar.dateFromComponents(components) else {
                continue
            }
            
            if let holiday = JapaneseHoliday(title: item.title,
                                              date: date) {
                holidays.append(holiday)
            }
        }
        
        return holidays
    }
}

public extension NSDate {
    
    public func isJapaneseHoliday() -> Bool {
        guard let _ = self.japaneseHoliday() else {
            return false
        }
        
        return true
    }
    
    public func japaneseHoliday() -> JapaneseHoliday? {
        guard let calendar = JapaneseHoliday.calendar else {
            return nil
        }
        
        let year = calendar.component(.Year, fromDate: self)
        let holidays = JapaneseHoliday.holidays(year: year)
        
        return holidays.filter { calendar.isDate($0.date, inSameDayAsDate:self) }.first
    }
}
