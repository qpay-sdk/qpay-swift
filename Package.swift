// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "QPay",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
    ],
    products: [
        .library(
            name: "QPay",
            targets: ["QPay"]
        ),
    ],
    targets: [
        .target(
            name: "QPay",
            path: "Sources/QPay"
        ),
        .testTarget(
            name: "QPayTests",
            dependencies: ["QPay"],
            path: "Tests/QPayTests"
        ),
    ]
)
