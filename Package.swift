// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Adhan",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_13),
        .tvOS(.v12),
        .watchOS(.v6)
    ],
    products: [
        .library(
            name: "Adhan",
            targets: ["Adhan"]
        )
    ],
    targets: [
        .target(
            name: "Adhan",
            path: "Sources"
        ),
        .testTarget(
            name: "Tests",
            dependencies: ["Adhan"],
            path: "Tests",
            resources: [.copy("Resources")]
        ),
    ]
)
