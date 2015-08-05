//
//  TimeHelper.swift
//  Mezzo-1.0
//
//  Created by Heejung Chung on 8/4/15.
//  Copyright (c) 2015 MezzoAwesomeness. All rights reserved.
//

import Foundation

typealias WeeklyHoursDictionary = [String: (start: NSDate?, end: NSDate?)]

class TimeHelper {
    
    /// default date formatter for String <-> NSdate conversion
    static var formatter: NSDateFormatter {
        get {
            let returnable = NSDateFormatter()
            returnable.dateFormat = "hh:mm a"
            return returnable
        }
    }
    
    static let weekDaySymbols = ["S", "M", "T", "W", "Th", "F", "Sa"]
    
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
            let startDate = formatter.dateFromString(dateStrings[0])
            let endDate = formatter.dateFromString(dateStrings[1])
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
                let startString = formatter.stringFromDate(startDate)
                let endString = formatter.stringFromDate(endDate)
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
    
    // TODO: documentation
    static func relevantHoursInTimeRange(donorTimeRange: (start: NSDate, end: NSDate), forOrgSchedule: WeeklyHoursDictionary) -> String {
        
        return ""
    }
}





































