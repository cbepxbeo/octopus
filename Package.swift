// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "ParallelSequence",
    platforms: [.iOS(.v14), .macOS(.v12)],
    products: [
        .library(
            name: "ParallelSequence",
            targets: ["ParallelSequence"]),
    ],
    targets: [
        .target(
            name: "ParallelSequence",
            dependencies: [],
            path: "Sources"
        ),
        .testTarget(
            name: "ParallelSequenceTests",
            dependencies: ["ParallelSequence"]),
    ],
    swiftLanguageVersions: [ .version("5.1") ]
)
