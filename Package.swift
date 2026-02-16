// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CoreTools",
    platforms: [
        .iOS(.v18),
        .macOS(.v15),
    ],
    products: [
        .library(
            name: "CoreTools",
            targets: ["CoreTools"]
        ),
        .library(
            name: "CoreUI",
            targets: ["CoreUI"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/1amageek/OpenFoundationModels.git", from: "1.3.0"),
    ],
    targets: [
        .target(
            name: "CoreTools",
            dependencies: [
                .product(name: "OpenFoundationModels", package: "OpenFoundationModels"),
            ]
        ),
        .target(
            name: "CoreUI",
            dependencies: ["CoreTools"]
        ),
        .testTarget(
            name: "CoreToolsTests",
            dependencies: [
                "CoreTools",
                .product(name: "OpenFoundationModels", package: "OpenFoundationModels"),
            ]
        ),
        .testTarget(
            name: "CoreUITests",
            dependencies: ["CoreUI"]
        ),
    ]
)
