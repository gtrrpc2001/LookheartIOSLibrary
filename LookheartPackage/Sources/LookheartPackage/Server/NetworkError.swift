import Foundation


public enum NetworkError: Error {
    case invalidResponse
    case noData
}

public class NetworkErrorManager {
    
    public static let shared = NetworkErrorManager()
    
    public func getErrorMessage(_ error: NetworkError) -> String {
        switch (error) {
            
        case .invalidResponse:
            return "serverErr".localized()
        case .noData:
            return "noData".localized()
        }
    }
    
}
