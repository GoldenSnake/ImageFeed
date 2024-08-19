
import UIKit

struct ErrorHandler {
    static func printError(_ error: Error, origin: String, details: String? = nil) {
        var message = "[lOG] [ERROR] [\(origin)]: \(error) - \(error.localizedDescription)"
        if let details {
            message += ", details: \(details)"
        }
        print(message)
    }
}
