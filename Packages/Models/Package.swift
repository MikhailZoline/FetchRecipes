// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let targetDependency: Target.Dependency = .product(name: "StateManagement", package: "StateManagement")

let package = Package(
    name: "Models",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "Models",
            targets: ["Models"]
        )
    ],
    dependencies: [
        .package(name: "StateManagement", path: "../StateManagement")
    ],
    targets: [
        .target(
            name: "Models",
            dependencies: [
                targetDependency
            ]
        )
    ]
)
