import XCTest

@testable import ConcreteGit

final class LogParserTests: XCTestCase {
    func testParseLogLineWithSHAAndSubject() {
        // given
        let line = "7bc76cd  | fix: check if valid remote url"

        // when
        let commit = try! LogParser.parseGitLogLine(line: line)

        // then
        let expectedCommit = Commit(
            abbreviatedHash: "7bc76cd",
            author: Author(name: "John Doe", email: "jdoe@email.test"),
            subject: "fix: check if valid remote url",
            tag: nil
        )
        XCTAssertEqual(expectedCommit, commit)
    }

    func testParseLogWIthSHATagWithOtherRefsAndSubject() {
        // given
        let line = "ec3a4b6 HEAD -> main, tag: v1.10.7, origin/main, origin/HEAD | chore(release): 1.10.7"

        // when
        let commit = try! LogParser.parseGitLogLine(line: line)

        // then
        let expectedCommit = Commit(
            abbreviatedHash: "ec3a4b6",
            author: Author(name: "John Doe", email: "jdoe@email.test"),
            subject: "chore(release): 1.10.7",
            tag: Tag(name: "v1.10.7")
        )
        XCTAssertEqual(expectedCommit, commit)
    }

    func testParseLogWIthSHATagWithNoOtherRefsAndSubject() {
        // given
        let line = "54d6657 tag: v1.10.5 | chore(release): 1.10.5"

        // when
        let commit = try! LogParser.parseGitLogLine(line: line)

        // then
        let expectedCommit = Commit(
            abbreviatedHash: "54d6657",
            author: Author(name: "John Doe", email: "jdoe@email.test"),
            subject: "chore(release): 1.10.5",
            tag: Tag(name: "v1.10.5")
        )
        XCTAssertEqual(expectedCommit, commit)
    }
}
