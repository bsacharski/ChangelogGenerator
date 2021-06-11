import Foundation

public struct Author: CustomStringConvertible, Equatable {
    public let name: String
    public let email: String

    public var description: String {
        return "\(name) <\(email)>"
    }
}
