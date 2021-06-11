import Foundation

enum LogParserError: Error {
    case parsingError(line: String)
}

struct LogParser {
    private static func extractCommitComponents(
        line: String
    ) throws -> (hash: String, timestamp: TimeInterval, tag: String?, subject: String) {
        // We operate on strings like:
        // "ec3a4b6 HEAD -> main, tag: v1.10.7, origin/main, origin/HEAD | chore(release): 1.10.7", or
        // "9b32244 tag: v1.10.6 | chore(release): 1.10.6", or
        // "9bb1e99  | chore(deps): update dependencies"
        let commitComponents = ["timestamp", "sha", "refs", "subject"]
        let extractPattern = #"""
        (?xi)
        ^
        (?<timestamp>\d+)
        \s
        (?<sha>[a-f0-9]+)
        \s+
        (?<refs>.*)?
        \s+
        \|
        \s
        (?<subject>.*)
        $
        """#
        // swiftlint:disable:next force_try
        let regex = try! NSRegularExpression(pattern: extractPattern, options: [])

        var extractedMatches: [String: String] = [:]
        let nsRange = NSRange(line.startIndex..<line.endIndex, in: line)
        if let match = regex.firstMatch(in: line, options: [], range: nsRange) {
            for component in commitComponents {
                let nsRange = match.range(withName: component)
                if nsRange.location != NSNotFound, let range = Range(nsRange, in: line) {
                    extractedMatches[component] = String(line[range])
                }
            }
        }

        guard Set(extractedMatches.keys).isSuperset(of: ["timestamp", "sha", "subject"]) else {
            throw LogParserError.parsingError(line: line)
        }

        let tag = extractTagFromRefs(refs: extractedMatches["refs"] ?? "")
        return (
            hash: extractedMatches["sha"]!,
            timestamp: TimeInterval(extractedMatches["timestamp"]!)!,
            tag: tag,
            subject: extractedMatches["subject"]!
        )
    }

    private static func extractTagFromRefs(refs: String) -> String? {
        for ref in refs.split(separator: ",") {
            let cleanedUpRef = ref.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            if cleanedUpRef.starts(with: "tag: ") {
                return cleanedUpRef.replacingOccurrences(of: "tag:", with: "")
                    .trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            }
        }

        return nil
    }

    static func parseGitLogLine(line: String) throws -> Commit {
        let author = Author(name: "John Doe", email: "jdoe@email.test")
        let components = try extractCommitComponents(line: line)
        let tag = components.tag != nil ? Tag(name: components.tag!) : nil

        return Commit(
            abbreviatedHash: components.hash,
            commitDate: Date(timeIntervalSince1970: components.timestamp),
            author: author,
            subject: components.subject,
            tag: tag
        )
    }
}
