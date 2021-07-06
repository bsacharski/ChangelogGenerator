// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ChangelogGenerator",
    platforms: [
        .macOS(.v10_13)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "ChangelogGenerator",
            targets: ["ChangelogGenerator"]),
        .executable(name: "changelog-generator-cli", targets: ["ChangelogGeneratorCLI"])
    ],
    dependencies: [
        .package(url: "https://github.com/realm/SwiftLint.git", from: "0.43.1"),
        .package(url: "https://github.com/apple/swift-argument-parser", .upToNextMinor(from: "0.3.1"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "ConcreteGit",
            dependencies: []),
        .target(name: "ConventionalCommit", dependencies: [ "ConcreteGit" ]),
        .target(
            name: "ChangelogGenerator",
            dependencies: []),
        .target(
            name: "ChangelogGeneratorCLI",
            dependencies: [
                "ConcreteGit",
                "ChangelogGenerator",
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]),
        .testTarget(
            name: "ConcreteGitTests",
            dependencies: ["ConcreteGit"]),
        .testTarget(
            name: "ConventionalCommitTests", dependencies: [ "ConventionalCommit" ]
        ),
        .testTarget(
            name: "ChangelogGeneratorTests",
            dependencies: ["ChangelogGenerator"])
    ]
)
