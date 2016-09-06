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
    var calendar: Calendar! =  {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "ja_jp")
        return calendar
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // print current year
        let date = Date()
        let year = self.calendar.component(.year, from: date)
        let holidays = JapaneseHoliday.holidays(year: year)
        for item in holidays {
            print(item.description)
        }
        
        // update label
        self.datePicker.sendActions(for: .valueChanged)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func dateChanged(sender: AnyObject) {
        let date = self.datePicker.date
        let formatter = DateFormatter()
        formatter.locale = self.calendar.locale
        formatter.dateFormat = "yyyy-MM-dd(EEE)"
        let text = formatter.string(from: date)
        
        if let holiday = date.japaneseHoliday() {
            self.holidayLabel.text = text + " is " + holiday.title
        }
        else {
            self.holidayLabel.text = text + " is not holiday"
        }
    }
}

