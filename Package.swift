// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CoreTools",
    platforms: [
        .iOS(.v26),
        .macOS(.v26),
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
    traits: [
        .trait(name: "OpenFoundationModels"),
        .default(enabledTraits: []),
    ],
    dependencies: [
        .package(url: "https://github.com/1amageek/OpenFoundationModels.git", from: "1.3.0"),
    ],
    targets: [
        .target(
            name: "CoreTools",
            dependencies: [
                .product(name: "OpenFoundationModels", package: "OpenFoundationModels", condition: .when(traits: ["OpenFoundationModels"])),
            ],
            swiftSettings: [
                .define("OpenFoundationModels", .when(traits: ["OpenFoundationModels"])),
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
                .product(name: "OpenFoundationModels", package: "OpenFoundationModels", condition: .when(traits: ["OpenFoundationModels"])),
            ],
            swiftSettings: [
                .define("OpenFoundationModels", .when(traits: ["OpenFoundationModels"])),
            ]
        ),
        .testTarget(
            name: "CoreUITests",
            dependencies: ["CoreUI"]
        ),
    ]
)
