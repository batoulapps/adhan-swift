// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Adhan",
    platforms: [
        .iOS(.v16),
        .macOS(.v14)
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
            path: "Sources",
            exclude: [
                "AdhanObjc.swift",
                "Info.plist"
            ]
        ),
        .testTarget(
            name: "Tests",
            dependencies: ["Adhan"],
            path: "Tests",
            exclude: [
                "ObjcTests.m",
                "Info.plist"
            ],
            resources: [.copy("Resources")]
        )
    ]
)
