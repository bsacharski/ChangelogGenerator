import Foundation
import ConcreteGit
import ArgumentParser

struct ChangelogGeneratorCli: ParsableCommand {
    @Argument(help: "Path to repository")
    var repositoryPath: String = FileManager.default.currentDirectoryPath

    func run() throws {
        do {
            let commitList = try Log.getCommitList(repoPath: repositoryPath)
            commitList.forEach {
                print("\($0.abbreviatedHash) \($0.subject)")
            }
        } catch GitError.notAGitRepository(let path) {
            print("Did not find git repository at '\(path)'")
        } catch {
            print("Unexpected error: \(error)")
        }
    }
}

ChangelogGeneratorCli.main()
