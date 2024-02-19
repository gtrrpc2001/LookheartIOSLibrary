import Foundation

public struct UserProfile: Codable {
    var eq: String
    var eqname: String
    var email: String
    var userphone: String
    var sex: String
    var height: String
    var weight: String
    var age: String
    var birth: String
    var signupdate: String
    var sleeptime: Int
    var uptime: Int
    var bpm: Int
    var step: Int
    var distanceKM: Int
    var calexe: Int
    var cal: Int
    var alarm_sms: Int  // ecg Flag
    var differtime: Int // 사용 제한 Flag ( 0 : 사용, 1 : 사용 중지 )
    var phone: String?
}
