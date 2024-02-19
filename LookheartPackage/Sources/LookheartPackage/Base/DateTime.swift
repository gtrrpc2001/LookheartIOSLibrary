//
//  File.swift
//  
//
//  Created by 정연호 on 2024/01/09.
//

import Foundation

public class MyDateTime {
    
    public enum DateType {
        case DATE
        case TIME
        case DATETIME
    }
    
    public static let shared = MyDateTime()
    
    public let dateFormatter = DateFormatter()
    private let dateTimeFormatter = DateFormatter()
    
    private var calendar = Calendar.current
    
    init() {
        dateFormatter.dateFormat = "yyyy-MM-dd"
    }
    
    public func getCurrentDateTime(_ dateType : DateType ) -> String {
        
        let now = Date()
        
        dateFormatter.dateFormat = getFormatter(dateType)
        
        return dateFormatter.string(from: now)
    }
    
    
    
    public func getSplitDateTime(_ dateType : DateType ) -> [String] {
        let now = Date()
        
        dateFormatter.dateFormat = getFormatter(dateType)
        
        let dateTime = dateFormatter.string(from: now)
        
        switch (dateType) {
        case .DATE:
            return dateTime.split(separator: "-").map { String($0) }
        case .TIME:
            return dateTime.split(separator: ":").map { String($0) }
        case .DATETIME:
            return dateTime.split(separator: " ").map { String($0) }
        }
        
    }
    
    public func getFormatter(_ dateType : DateType) -> String {
        switch (dateType) {
        case .DATE:
            return "yyyy-MM-dd"
        case .TIME:
            return "HH:mm:ss"
        case .DATETIME:
            return "yyyy-MM-dd HH:mm:ss"
        }
    }
    
    public func dateCalculate(_ date: String, _ day: Int, _ shouldAdd: Bool) -> String {
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        guard let inputDate = dateFormatter.date(from: date) else { return date }

        let dayValue = shouldAdd ? day : -day
        if let arrTargetDate = calendar.date(byAdding: .day, value: dayValue, to: inputDate) {
            let components = calendar.dateComponents([.year, .month, .day], from: arrTargetDate)
            
            if let year = components.year, let month = components.month, let day = components.day {
                let year = "\(year)"
                let month = String(format: "%02d", month)
                let day = String(format: "%02d", day)
                
                return "\(year)-\(month)-\(day)"
            }
        }
        return date
    }
    
    public func dateCalculate(_ date: String, _ day: Int, _ shouldAdd: Bool, _ type: Calendar.Component) -> String {
        guard let inputDate = dateFormatter.date(from: date) else { return date }
        
        let dayValue = shouldAdd ? day : -day
        if let stepTargetDate = calendar.date(byAdding: type, value: dayValue, to: inputDate) {
            
            let components = calendar.dateComponents([.year, .month, .day], from: stepTargetDate)
            
            if let year = components.year, let month = components.month, let day = components.day {
                let year = "\(year)"
                let month = String(format: "%02d", month)
                let day = String(format: "%02d", day)
                
                return "\(year)-\(month)-\(day)"
            }
        }
        return date
    }
    
    public func findNumDay(_ date: String) -> Int? {
        guard let inputDate = dateFormatter.date(from: date) else { return nil}
        if let range = calendar.range(of: .day, in: .month, for: inputDate) {
            return range.count
        } else {
            return nil
        }
    }
    
    public func changeDateFormat(_ dateString: String, _ yearFlag: Bool) -> String {
        var dateComponents = dateString.components(separatedBy: "-")
        
        if yearFlag {
            dateComponents[0] = String(format: "%02d", Int(dateComponents[0])!)
            dateComponents[1] = String(format: "%02d", Int(dateComponents[1])!)
            return "\(dateComponents[0])-\(dateComponents[1])"
        } else {
            dateComponents[1] = String(format: "%02d", Int(dateComponents[1])!)
            dateComponents[2] = String(format: "%02d", Int(dateComponents[2])!)
            return "\(dateComponents[1])-\(dateComponents[2])"
        }
    }
    
    public func getDateFormat() -> DateFormatter {
        return dateFormatter
    }
    
    public func getTimeZone() -> String {
        let currentTimeZone = TimeZone.current
        let identifier = currentTimeZone.identifier
        let utcOffsetInSeconds = currentTimeZone.secondsFromGMT()
        
        let hours = abs(utcOffsetInSeconds) / 3600
        let minutes = (abs(utcOffsetInSeconds) % 3600) / 60

        let offsetString = String(format: "%@%02d:%02d", utcOffsetInSeconds >= 0 ? "+" : "-", hours, minutes)

        let currentCountryCode = Locale.current.regionCode ?? "Unknown"  // "US", "KR" 등
        
        // utcOffSet /. 현재 국가,도시 / 사용자 지정 국가
        return "\(offsetString)/\(identifier)/\(currentCountryCode)"
        
    }
    
}
