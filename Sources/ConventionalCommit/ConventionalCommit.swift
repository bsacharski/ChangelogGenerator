import Foundation
import ConcreteGit

enum CommitType {
    case fix,
         feat,
         unknown
}

enum ConventionalCommitError: Error {
    case generic,
         parsingError(commitSubject: String)
}

public struct ConventionalCommit: Equatable {
    let originalCommit: Commit
    let commitType: CommitType
    let scope: [String]
    let subject: String

    init (commitType: CommitType, scope: [String], subject: String, originalCommit: Commit) {
        self.commitType = commitType
        self.scope = scope
        self.subject = subject
        self.originalCommit = originalCommit
    }

    public static func fromCommit(_ commit: Commit) throws -> ConventionalCommit {
        let components = try parseSubject(commitSubject: commit.subject)
        return ConventionalCommit(
            commitType: getCommitType(type: components.type),
            scope: components.scope,
            subject: components.subject,
            originalCommit: commit
        )
    }

    private static func parseSubject(commitSubject: String) throws -> (type: String, scope: [String], subject: String) {
        // We operate on strings like:
        // "fix: add foo bar"
        // "feat(conventional-commit): add foo bar"
        let commitComponents = ["type", "scope", "subject"]
        let extractPattern = #"""
        (?xi)
        ^
        (?<type>.+?)
        (:?\((?<scope>.+)\))?
        :
        \s?
        (?<subject>.+)
        $
        """#

        // swiftlint:disable:next force_try
        let regex = try! NSRegularExpression(pattern: extractPattern, options: [])

        var extractedMatches: [String: String] = [:]
        let nsRange = NSRange(commitSubject.startIndex..<commitSubject.endIndex, in: commitSubject)
        if let match = regex.firstMatch(in: commitSubject, options: [], range: nsRange) {
            for component in commitComponents {
                let nsRange = match.range(withName: component)
                if nsRange.location != NSNotFound, let range = Range(nsRange, in: commitSubject) {
                    extractedMatches[component] = String(commitSubject[range])
                }
            }
        }

        guard Set(extractedMatches.keys).isSuperset(of: ["type", "subject"]) else {
            throw ConventionalCommitError.parsingError(commitSubject: commitSubject)
        }

        let scope = (extractedMatches["scope"] ?? "").split(separator: ",")

        return (
            type: extractedMatches["type"]!,
            scope: scope.map { String($0).trimmingCharacters(in: CharacterSet.whitespaces) },
            subject: extractedMatches["subject"]!
        )
    }

    private static func getCommitType(type: String) -> CommitType {
        switch type.lowercased() {
        case "fix" : return CommitType.fix
        case "feat": return CommitType.feat
        default: return CommitType.unknown
        }
    }
}
