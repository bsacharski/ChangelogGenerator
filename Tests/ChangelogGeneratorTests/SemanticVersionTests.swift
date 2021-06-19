import XCTest

@testable import ChangelogGenerator

final class SemanticVersionTests: XCTestCase {
    func testSortVersions() {
        // given
        let versions = [
            try! SemanticVersion(major: 2, minor: 1, patch: 0, preRelease: try! PreRelease(preReleaseTypeChain: [.alpha, .beta], version: 1), buildMetadata: nil),
            SemanticVersion(major: 1, minor: 2, patch: 3),
            SemanticVersion(major: 2, minor: 1, patch: 0),
            try! SemanticVersion(major: 2, minor: 1, patch: 0, preRelease: try! PreRelease(preReleaseTypeChain: [.alpha], version: 1), buildMetadata: nil),
            SemanticVersion(major: 2, minor: 0, patch: 1),
            SemanticVersion(major: 2, minor: 0, patch: 0),
            SemanticVersion(major: 1, minor: 1, patch: 1),
            try! SemanticVersion(major: 2, minor: 0, patch: 0, preRelease: try! PreRelease(preReleaseTypeChain: [.rc], version: 0), buildMetadata: nil),
            try! SemanticVersion(major: 2, minor: 0, patch: 0, preRelease: try! PreRelease(preReleaseTypeChain: [.beta], version: 5), buildMetadata: nil),
            SemanticVersion(major: 1, minor: 1, patch: 0),
            try! SemanticVersion(major: 2, minor: 0, patch: 0, preRelease: try! PreRelease(preReleaseTypeChain: [.beta], version: 4), buildMetadata: nil),
        ]

        // when
        let sortedVersions = versions.sorted()

        // then
        let expected = [
            SemanticVersion(major: 1, minor: 1, patch: 0),
            SemanticVersion(major: 1, minor: 1, patch: 1),
            SemanticVersion(major: 1, minor: 2, patch: 3),
            try! SemanticVersion(major: 2, minor: 0, patch: 0, preRelease: try! PreRelease(preReleaseTypeChain: [.beta], version: 4), buildMetadata: nil),
            try! SemanticVersion(major: 2, minor: 0, patch: 0, preRelease: try! PreRelease(preReleaseTypeChain: [.beta], version: 5), buildMetadata: nil),
            try! SemanticVersion(major: 2, minor: 0, patch: 0, preRelease: try! PreRelease(preReleaseTypeChain: [.rc], version: 0), buildMetadata: nil),
            SemanticVersion(major: 2, minor: 0, patch: 0),
            SemanticVersion(major: 2, minor: 0, patch: 1),
            try! SemanticVersion(major: 2, minor: 1, patch: 0, preRelease: try! PreRelease(preReleaseTypeChain: [.alpha], version: 1), buildMetadata: nil),
            try! SemanticVersion(major: 2, minor: 1, patch: 0, preRelease: try! PreRelease(preReleaseTypeChain: [.alpha, .beta], version: 1), buildMetadata: nil),
            SemanticVersion(major: 2, minor: 1, patch: 0),
        ]

        XCTAssertEqual(expected, sortedVersions)
    }
    
    func testRenderVersionStringWithOnlyRequiredComponents() {
        // given
        let version = SemanticVersion(major: 2, minor: 3, patch: 1)

        // when
        let versionString = "\(version)"

        // then
        XCTAssertEqual("2.3.1", versionString)
    }
    
    func testRenderVersionStringWithVersionlessPrerelease() {
        // given
        let version = try! SemanticVersion(major: 2, minor: 3, patch: 1, preRelease: try! PreRelease(preReleaseTypeChain: [.beta], version: nil), buildMetadata: nil)

        // when
        let versionString = "\(version)"

        // then
        XCTAssertEqual("2.3.1-beta", versionString)
    }
    
    func testRenderVersionStringWithPrerelease() {
        // given
        let version = try! SemanticVersion(major: 2, minor: 3, patch: 1, preRelease: try! PreRelease(preReleaseTypeChain: [.beta], version: 2), buildMetadata: nil)

        // when
        let versionString = "\(version)"

        // then
        XCTAssertEqual("2.3.1-beta.2", versionString)
    }
    
    func testRenderVersionStringWithBuildInfo() {
        // given
        let version = try! SemanticVersion(major: 2, minor: 3, patch: 1, preRelease: nil, buildMetadata: "20210101123456")

        // when
        let versionString = "\(version)"

        // then
        XCTAssertEqual("2.3.1+20210101123456", versionString)
    }
    
    func testRenderVersionStringWithPrerelaseAndBuildInfo() {
        // given
        let version = try! SemanticVersion(major: 2, minor: 3, patch: 1, preRelease: try! PreRelease(preReleaseTypeChain: [.beta], version: 2), buildMetadata: "20210101123456")

        // when
        let versionString = "\(version)"

        // then
        XCTAssertEqual("2.3.1-beta.2+20210101123456", versionString)
    }
    
    func testRenderVersionStringWithChainedPrerelaseAndBuildInfo() {
        // given
        let version = try! SemanticVersion(major: 2, minor: 3, patch: 1, preRelease: try! PreRelease(preReleaseTypeChain: [.alpha, .beta], version: 2), buildMetadata: "20210101123456")

        // when
        let versionString = "\(version)"

        // then
        XCTAssertEqual("2.3.1-alpha.beta.2+20210101123456", versionString)
    }
    
    func testSortPreReleaseVersions() {
        // given
        let versions = [
            try! PreRelease(preReleaseTypeChain: [.beta], version: nil),
            try! PreRelease(preReleaseTypeChain: [.alpha], version: nil),
            try! PreRelease(preReleaseTypeChain: [.rc], version: nil),
            try! PreRelease(preReleaseTypeChain: [.alpha], version: 1),
            try! PreRelease(preReleaseTypeChain: [.beta], version: 2),
        ]

        // when
        let sortedVersions = versions.sorted()

        // then
        let expected = [
            try! PreRelease(preReleaseTypeChain: [.alpha], version: nil),
            try! PreRelease(preReleaseTypeChain: [.alpha], version: 1),
            try! PreRelease(preReleaseTypeChain: [.beta], version: nil),
            try! PreRelease(preReleaseTypeChain: [.beta], version: 2),
            try! PreRelease(preReleaseTypeChain: [.rc], version: nil),
        ]

        XCTAssertEqual(expected, sortedVersions)
    }
    
    func testParseSemanticVersionWithOnlyRequiredComponents() {
        // given
        let versionString = "4.2.33"

        // when
        let version = try? SemanticVersionParser.parse(version: versionString)

        // then
        XCTAssertEqual(SemanticVersion(major: 4, minor: 2, patch: 33), version)
    }

    func testParseSemanticVersionWithPreReleaseData() {
        // given
        let versionString = "4.2.33-alpha.beta.1"

        // when
        let version = try? SemanticVersionParser.parse(version: versionString)

        // then
        XCTAssertEqual(
            try! SemanticVersion(major: 4, minor: 2, patch: 33, preRelease: try! PreRelease(preReleaseTypeChain: [.alpha, .beta], version: 1), buildMetadata: nil),
            version
        )
    }

    func testParseSemanticVersionWithBuildMetadata() {
        // given
        let versionString = "32.12.4+202105272159";

        // when
        let version = try? SemanticVersionParser.parse(version: versionString)

        // then
        XCTAssertEqual(
            try! SemanticVersion(major: 32, minor: 12, patch: 4, preRelease: nil, buildMetadata: "202105272159"),
            version
        )
    }

    func testParseSemanticVersionWithPreReleaseDataAndBuildMetadata() {
        // given
        let versionString = "32.12.4-alpha+202105272159";

        // when
        let version = try? SemanticVersionParser.parse(version: versionString)

        // then
        XCTAssertEqual(
            try! SemanticVersion(
                major: 32,
                minor: 12,
                patch: 4,
                preRelease: PreRelease(preReleaseTypeChain: [.alpha], version: nil),
                buildMetadata: "202105272159"
            ),
            version
        )
    }

    func testParseSemanticVersionWithVAsPrefix() {
        // given
        let versionString = "v32.12.4-alpha+202105272159";

        // when
        let version = try? SemanticVersionParser.parse(version: versionString)

        // then
        XCTAssertEqual(
            try! SemanticVersion(
                major: 32,
                minor: 12,
                patch: 4,
                preRelease: PreRelease(preReleaseTypeChain: [.alpha], version: nil),
                buildMetadata: "202105272159"
            ),
            version
        )
    }
}
