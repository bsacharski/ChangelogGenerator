import Foundation

public struct Commit: Equatable {
    let abbreviatedHash: String
    let author: Author
    let subject: String
    let tag: Tag?

    public static func == (lhs: Commit, rhs: Commit) -> Bool {
        if (lhs.abbreviatedHash != rhs.abbreviatedHash) {
            return false
        }

        if (lhs.author != rhs.author) {
            return false
        }

        if (lhs.subject != rhs.subject) {
            return false
        }

        if (lhs.tag != rhs.tag) {
            return false
        }

        return true
    }
}


