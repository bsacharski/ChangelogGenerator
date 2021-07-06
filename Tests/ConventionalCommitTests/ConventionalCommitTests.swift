import XCTest

@testable import ConventionalCommit
@testable import ConcreteGit

final class ConventionalCommitTests: XCTestCase {
    func testConvertFeatCommitWithNoScopeIntoConventionalCommit() {
        // given
        let commit = Commit(
            abbreviatedHash: "123456ae",
            commitDate: Date(timeIntervalSince1970: 1623009728),
            author: Author(name: "John Doe", email: "jdoe@company.com"),
            subject: "feat: initial commit",
            tag: nil
        )

        // when
        let conventionalCommit = try? ConventionalCommit.fromCommit(commit)

        // then
        let expected = ConventionalCommit(
            commitType: CommitType.feat,
            scope: [],
            subject: "initial commit",
            originalCommit: commit
        )

        XCTAssertEqual(expected, conventionalCommit)
    }

    func testConvertFixCommitWithSingleScopeIntoConventionalCommit() {
        // given
        let commit = Commit(
            abbreviatedHash: "123456ae",
            commitDate: Date(timeIntervalSince1970: 1623009728),
            author: Author(name: "John Doe", email: "jdoe@company.com"),
            subject: "fix(foo): initial commit",
            tag: nil
        )

        // when
        let conventionalCommit = try? ConventionalCommit.fromCommit(commit)

        // then
        let expected = ConventionalCommit(
            commitType: CommitType.fix,
            scope: ["foo"],
            subject: "initial commit",
            originalCommit: commit
        )

        XCTAssertEqual(expected, conventionalCommit)
    }

    func testConvertFixCommitWithMultipleScopesIntoConventionalCommit() {
        // given
        let commit = Commit(
            abbreviatedHash: "123456ae",
            commitDate: Date(timeIntervalSince1970: 1623009728),
            author: Author(name: "John Doe", email: "jdoe@company.com"),
            subject: "fix(foo, bar,baz): initial commit",
            tag: nil
        )

        // when
        let conventionalCommit = try? ConventionalCommit.fromCommit(commit)

        // then
        let expected = ConventionalCommit(
            commitType: CommitType.fix,
            scope: ["foo", "bar", "baz"],
            subject: "initial commit",
            originalCommit: commit
        )

        XCTAssertEqual(expected, conventionalCommit)
    }
}
