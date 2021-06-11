import Foundation

public enum GitError: Error {
    case notAGitRepository(path: String),
         gitExecutableNotFound(path: String)
}

public struct Log {
    private static let gitPath = "/usr/bin/git"

    private static func checkGitExecutable() throws {
        guard FileManager.default.isExecutableFile(atPath: gitPath) else {
            throw GitError.gitExecutableNotFound(path: gitPath)
        }
    }

    private static func checkGitRepository(repoPath: String) throws {
        let directoryListing = try? FileManager.default.contentsOfDirectory(atPath: repoPath)
        guard directoryListing != nil else {
            throw GitError.notAGitRepository(path: repoPath)
        }

        guard directoryListing!.contains(".git") else {
            throw GitError.notAGitRepository(path: repoPath)
        }
    }

    private static func getGitLog(repoPath: String) throws -> String {
        let gitLog = Process()
        gitLog.currentDirectoryPath = repoPath
        gitLog.executableURL = URL(fileURLWithPath: gitPath)
        gitLog.arguments = [
            "log",
            #"--pretty=%at %h %D | %s"#,
            "--no-show-signature"
        ]

        let stdOutPipe = Pipe()
        gitLog.standardOutput = stdOutPipe

        try gitLog.run()
        let rawStdOutput = stdOutPipe.fileHandleForReading.readDataToEndOfFile()
        gitLog.waitUntilExit()

        return String(decoding: rawStdOutput, as: UTF8.self)
    }

    private static func parseGitLog(gitLog: String) throws -> [Commit] {
        return try gitLog.split(separator: "\n").map { try LogParser.parseGitLogLine(line: String($0)) }
    }

    public static func getCommitList(repoPath: String) throws -> [Commit] {
        try checkGitExecutable()
        try checkGitRepository(repoPath: repoPath)
        let gitLog = try getGitLog(repoPath: repoPath)
        let commits = try parseGitLog(gitLog: gitLog)
        return commits
    }
}
