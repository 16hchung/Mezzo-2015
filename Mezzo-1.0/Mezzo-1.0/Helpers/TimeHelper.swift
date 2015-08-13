//
//  TimeHelper.swift
//  Mezzo-1.0
//
//  Created by Heejung Chung on 8/4/15.
//  Copyright (c) 2015 MezzoAwesomeness. All rights reserved.
//

import Foundation
//import NSDateHelper

typealias WeeklyHoursDictionary = [String: (start: NSDate?, end: NSDate?)]

class TimeHelper {
    
    /// default date formatter for String <-> NSdate conversion
    static var timeFormatter: NSDateFormatter {
        get {
            let returnable = NSDateFormatter()
            returnable.dateFormat = "hh:mm a"
            return returnable
        }
    }
    
    static let weekDaySymbols = ["S", "M", "T", "W", "Th", "F", "Sa"]
    static let weekdayFullNames = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    
    /**
        converts array of comma-separated times in string form to dictionary
    
        :param: datesArray should have 7 elements "\(start), \(end)"
    */
    static func datesDictionaryFromStrings(datesArray: [String]) -> WeeklyHoursDictionary {
        var returnable: WeeklyHoursDictionary = [:]
        for index in 0..<datesArray.count {
            // get separate date strings
            let dateStrings = datesArray[index].componentsSeparatedByString(" - ")
            
            // load into weely hours dictionary
            let startDate = timeFormatter.dateFromString(dateStrings[0])
            let endDate = timeFormatter.dateFromString(dateStrings[1])
            returnable[weekDaySymbols[index]] = (startDate, endDate)
        }
        
        return returnable
    }
    
    /// converts hours dictionary to array of comma-separated strings
    static func stringsFromDatesDictionary(dictionary: WeeklyHoursDictionary) -> [String] {
        var returnable = [String](count: 7, repeatedValue: " - ")
        for index in 0..<dictionary.count {
            let dateTuple = dictionary[weekDaySymbols[index]]!
            if let startDate = dateTuple.start, endDate = dateTuple.end {
                let startString = timeFormatter.stringFromDate(startDate)
                let endString = timeFormatter.stringFromDate(endDate)
                returnable[index] = "\(startString) - \(endString)"
            }
        }
        
        return returnable
    }
    
//    static func compatibilityOfDonorSpecifiedTimes(donorTimes: (start: NSDate, end: NSDate), withOrgSchedule: WeeklyHoursDictionary) -> Bool {
//        
//        
//        
//    }
    
    static func relevantHoursInTimeRange(donorTimeRange: (start: NSDate, end: NSDate), forOrgSchedule: [String]) -> [String] {
        
        var returnable = [String]()
        
        let calendar = NSCalendar.autoupdatingCurrentCalendar()
        
        // get weekday of donorTR.start
        let startWeekday = calendar.component(.CalendarUnitWeekday, fromDate: donorTimeRange.start) - 1
        let endWeekday = calendar.component(.CalendarUnitWeekday, fromDate: donorTimeRange.end) - 1
        
        
        
        for weekdayNum in startWeekday...endWeekday {
            let weekdayKey = weekdayFullNames[weekdayNum]
            let hours = (forOrgSchedule[weekdayNum] == " - ") ? " --" : forOrgSchedule[weekdayNum]
            returnable.append("\(weekdayKey.uppercaseString): \(hours)")
        }
        
        return returnable
    }
}





































