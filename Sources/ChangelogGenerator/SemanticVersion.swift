import Foundation

enum SemanticVersionError: Error {
    case emptyPreReleaseChain,
         emptyBuildMetadata,
         missingVersionComponents,
         unknownPreRelaseType(type: String)
}

struct SemanticVersion: Comparable, CustomStringConvertible {
    let major: Int
    let minor: Int
    let patch: Int
    let preRelease: PreRelease?
    let buildMetadata: String?

    init (major: Int, minor: Int, patch: Int, preRelease: PreRelease?, buildMetadata: String?) throws {
        if let buildMetadata = buildMetadata {
            guard !buildMetadata.isEmpty else {
                throw SemanticVersionError.emptyBuildMetadata
            }
        }

        self.major = major
        self.minor = minor
        self.patch = patch
        self.preRelease = preRelease
        self.buildMetadata = buildMetadata
    }

    static func < (lhs: SemanticVersion, rhs: SemanticVersion) -> Bool {
        if lhs.major != rhs.major {
            return lhs.major < rhs.major
        }

        if lhs.minor != rhs.minor {
            return lhs.minor < rhs.minor
        }

        if lhs.patch != rhs.patch {
            return lhs.patch < rhs.patch
        }

        // 1.0.0-alpha.1 < 1.0.0-alpha.2
        if let lhsPrerelease = lhs.preRelease, let rhsPrerelease = rhs.preRelease {
            return lhsPrerelease < rhsPrerelease
        }

        // 1.0.0-alpha.1 < 1.0.0
        if lhs.preRelease != nil {
            return true
        }

        // 1.0.0 < 1.0.0-alpha.1
        if rhs.preRelease != nil {
            return false
        }

        return true
    }

    var description: String {
        var output = "\(self.major).\(self.minor).\(self.patch)"
        if let preRelease = preRelease {
            output += "-\(preRelease)"
        }

        if let buildMetadata = buildMetadata {
            output += "+\(buildMetadata)"
        }

        return output
    }
}

extension SemanticVersion {
    init (major: Int, minor: Int, patch: Int) {
        self.major = major
        self.minor = minor
        self.patch = patch
        self.preRelease = nil
        self.buildMetadata = nil
    }
}

enum PreReleaseType: Int {
    // swiftlint:disable:next identifier_name
    case alpha, beta, rc
}

struct PreRelease: Comparable, CustomStringConvertible {
    let preReleaseTypeChain: [PreReleaseType]
    let version: Int?

    init (preReleaseTypeChain: [PreReleaseType], version: Int?) throws {
        guard !preReleaseTypeChain.isEmpty else {
            throw SemanticVersionError.emptyPreReleaseChain
        }

        self.preReleaseTypeChain = preReleaseTypeChain
        self.version = version
    }

    var description: String {
        var output = preReleaseTypeChain.map { "\($0)" }.joined(separator: ".")

        if let version = version {
            output += ".\(version)"
        }

        return output
    }

    static func < (lhs: PreRelease, rhs: PreRelease) -> Bool {
        // alpha.1 < alpha.beta.1
        if lhs.preReleaseTypeChain.count != rhs.preReleaseTypeChain.count {
            return lhs.preReleaseTypeChain.count < rhs.preReleaseTypeChain.count
        }

        // swiftlint:disable:next line_length
        for (lhsPreRelaseType, rhsPreReleaseType) in zip(lhs.preReleaseTypeChain, rhs.preReleaseTypeChain) where lhsPreRelaseType != rhsPreReleaseType {
            // alpha.1 < beta.1
            return lhsPreRelaseType.rawValue < rhsPreReleaseType.rawValue
        }

        // alpha.1 < alpha.2
        if let lhsVersion = lhs.version, let rhsVersion = rhs.version {
            return lhsVersion < rhsVersion
        }

        // alpha.1 < alpha
        if lhs.version != nil {
            return false
        }

        // alpha < alpha.2
        if rhs.version != nil {
            return true
        }

        return true
    }
}

struct SemanticVersionParser {
    private static func extractSemVerComponents(
        version: String
    ) -> (requiredComponents: [String: Int], optionalComponents: [String: String]) {
        let requiredComponents = ["major", "minor", "patch"]
        let optionalComponents = ["prerelease", "buildmetadata"]
        let regexPattern  = #"""
        (?xi)
        ^
        (?<major>0|[1-9]\d*)
        \.
        (?<minor>0|[1-9]\d*)
        \.
        (?<patch>0|[1-9]\d*)
        (?:-(?<prerelease>(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\.(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?
        (?:\+(?<buildmetadata>[0-9a-zA-Z-]+(?:\.[0-9a-zA-Z-]+)*))?
        $
        """#
        // swiftlint:disable:next force_try
        let regex = try! NSRegularExpression(pattern: regexPattern, options: [])

        var requiredVersionComponents: [String: Int] = [:]
        var optionalVersionComponents: [String: String] = [:]

        let nsrange = NSRange(version.startIndex..<version.endIndex, in: version)
        if let match = regex.firstMatch(in: version, options: [], range: nsrange) {
            for component in requiredComponents {
                let nsrange = match.range(withName: component)
                if nsrange.location != NSNotFound, let range = Range(nsrange, in: version) {
                    let versionComponentString = version[range]
                    if let versionComponentNumber = Int(versionComponentString) {
                        requiredVersionComponents[component] = versionComponentNumber
                    }
                }
            }

            for component in optionalComponents {
                let nsrange = match.range(withName: component)
                if nsrange.location != NSNotFound, let range = Range(nsrange, in: version) {
                    optionalVersionComponents[component] = String(version[range])
                }
            }
        }

        return (requiredComponents: requiredVersionComponents, optionalComponents: optionalVersionComponents)
    }

    static func parsePreRelease(preRelease: String) throws -> PreRelease {
        var version: Int?

        var preReleaseTypeChain: [PreReleaseType] = []
        try preRelease.split(separator: ".").forEach { type in
            switch type {
            case "alpha":
                preReleaseTypeChain.append(.alpha)
            case "beta":
                preReleaseTypeChain.append(.beta)
            case "rc":
                preReleaseTypeChain.append(.rc)
            default:
                // in case of alpha.1, last element might be a number
                if let versionNumber = Int(type) {
                    version = versionNumber
                } else {
                    throw SemanticVersionError.unknownPreRelaseType(type: String(type))
                }
            }
        }

        return try PreRelease(preReleaseTypeChain: preReleaseTypeChain, version: version)
    }

    static func parse(version: String) throws -> SemanticVersion {
        let (requiredComponents, optionalComponents) = extractSemVerComponents(version: version)

        guard requiredComponents.count == requiredComponents.count else {
            throw SemanticVersionError.missingVersionComponents
        }

        var preRelease: PreRelease?
        if let preReleaseData = optionalComponents["prerelease"] {
            preRelease = try parsePreRelease(preRelease: preReleaseData)
        }

        let buildMetadata = optionalComponents["buildmetadata"] ?? nil

        return try SemanticVersion(
            major: requiredComponents["major"]!,
            minor: requiredComponents["minor"]!,
            patch: requiredComponents["patch"]!,
            preRelease: preRelease,
            buildMetadata: buildMetadata
        )
    }
}
