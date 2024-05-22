// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SPMSelectiveTesting",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "spm-selective-testing", targets: ["SPMSelectiveTesting"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.2.0"),
        .package(url: "https://github.com/JohnSundell/ShellOut.git", from: "2.0.0"),
        .package(url: "https://github.com/JohnSundell/Files", from: "4.2.0"),
        .package(url: "https://github.com/jpsim/Yams.git", from: "5.0.6"),
        .package(url: "https://github.com/apple/swift-tools-support-core", from: "0.6.0"),
        .package(url: "https://github.com/marmelroy/Zip", from: "2.1.0")
    ],
    targets: [
        .executableTarget(
            name: "SPMSelectiveTesting",
            dependencies: [
                "SPMSelectiveTestingCore",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        ),
        .target(
            name: "SPMSelectiveTestingCore",
            dependencies: [
                "ShellOut",
                "Files",
                "Yams",
                "Zip",
                .product(name: "SwiftToolsSupport-auto", package: "swift-tools-support-core")
            ]
        )
    ]
)
