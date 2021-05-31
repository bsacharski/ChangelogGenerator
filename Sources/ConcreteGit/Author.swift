import Foundation

struct Author: CustomStringConvertible, Equatable {
    let name: String
    let email: String

    var description: String {
        return "\(name) <\(email)>"
    }
}
