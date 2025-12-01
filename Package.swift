// swift-tools-version:6.2

import PackageDescription

let package = Package(
    name: "AdventOfCode2025",
    platforms: [.macOS("15")],
    products: [
        .executable(
            name: "AdventOfCode2025",
            targets: ["AdventOfCode2025"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/apple/swift-collections", .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/apple/swift-algorithms", .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/apple/swift-numerics", .upToNextMajor(from: "1.0.0")),
    ],
    targets: [
        .executableTarget(
            name: "AdventOfCode2025",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Collections", package: "swift-collections"),
                .product(name: "Algorithms", package: "swift-algorithms"),
            ]
        ),
        .testTarget(
            name: "AdventOfCode2025Tests",
            dependencies: [
                "AdventOfCode2025",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Collections", package: "swift-collections"),
                .product(name: "Algorithms", package: "swift-algorithms"),
            ],
            resources: [
                .copy("TestData"),
            ]
        ),
    ]
)
