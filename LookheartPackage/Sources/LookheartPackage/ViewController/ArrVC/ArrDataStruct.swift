import Foundation

public struct ArrData: Equatable {
    var idx: String
    var writeTime: String
    var time: String
    var timezone: String
    var bodyStatus: String
    var type: String
    var data: [Double]
}

public struct EcgData: Codable {
    let ecg: String?
    let arr: String
}

public struct ArrDateEntry: Decodable {
    public let writetime: String
    public let address: String?
}

public struct ArrEcgData: Decodable {
    let ecgpacket: String
}
