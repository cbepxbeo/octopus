// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "Octopus",
    platforms: [.iOS(.v14), .macOS(.v12)],
    products: [
        .library(
            name: "Octopus",
            targets: ["Octopus"]),
    ],
    targets: [
        .target(
            name: "Octopus",
            dependencies: [],
            path: "Sources"
        ),
        .testTarget(
            name: "OctopusTests",
            dependencies: ["Octopus"]
         ),
    ]
    swiftLanguageVersions: [ .version("5.1") ]
)
