import Foundation

public struct HourlyData {
    var eq: String
    var timezone: String
    var date: String
    var year: String
    var month: String
    var day: String
    var hour: String
    var step: String
    var distance: String
    var cal: String
    var activityCal: String
    var arrCnt: String
    
    func toDouble(_ value: String) -> Double {
        return Double(value) ?? 0
    }
}
