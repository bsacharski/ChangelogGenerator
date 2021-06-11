import Foundation

public struct Commit: Equatable {
    public let abbreviatedHash: String
    public let commitDate: Date
    public let author: Author
    public let subject: String
    public let tag: Tag?

    public static func == (lhs: Commit, rhs: Commit) -> Bool {
        if lhs.abbreviatedHash != rhs.abbreviatedHash {
            return false
        }

        if lhs.commitDate != rhs.commitDate {
            return false
        }

        if lhs.author != rhs.author {
            return false
        }

        if lhs.subject != rhs.subject {
            return false
        }

        if lhs.tag != rhs.tag {
            return false
        }

        return true
    }
}
