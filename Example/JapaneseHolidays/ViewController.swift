//
//  ViewController.swift
//  JapaneseHolidays
//
//  Created by Masayoshi Ukida on 07/15/2016.
//  Copyright (c) 2016 Masayoshi Ukida. All rights reserved.
//

import UIKit
import JapaneseHolidays

class ViewController: UIViewController {
    
    @IBOutlet var datePicker: UIDatePicker!
    @IBOutlet var holidayLabel: UILabel!
    var calendar: NSCalendar! =  {
        let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        calendar?.locale = NSLocale(localeIdentifier: "ja_jp")
        return calendar
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // print current year
        let date = NSDate()
        let year = self.calendar.component(.Year, fromDate: date)
        let holidays = JapaneseHoliday.holidays(year: year)
        for item in holidays {
            print(item.description)
        }
        
        // update label
        self.datePicker.sendActionsForControlEvents(.ValueChanged)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func dateChanged(sender: AnyObject) {
        let date = self.datePicker.date
        let formatter = NSDateFormatter()
        formatter.locale = self.calendar.locale
        formatter.dateFormat = "yyyy-MM-dd(EEE)"
        let text = formatter.stringFromDate(date)
        
        if let holiday = date.japaneseHoliday() {
            self.holidayLabel.text = text + " is " + holiday.title
        }
        else {
            self.holidayLabel.text = text + " is not holiday"
        }
    }
}

