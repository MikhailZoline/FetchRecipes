// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "StateManagement",
    platforms: [
        .iOS(.v16),
    ],
    products: [
        .library(
            name: "StateManagement",
            targets: ["StateManagement"]
        ),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "StateManagement",
            dependencies: [
            ]
        )
    ]
)
