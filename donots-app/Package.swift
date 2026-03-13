// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "Donots",
    platforms: [
        .macOS(.v14)
    ],
    targets: [
        .executableTarget(
            name: "Donots",
            path: "Sources/Donots",
            resources: [
                .copy("../../Resources/Donots.entitlements"),
            ]
        ),
        .testTarget(
            name: "DonotsTests",
            dependencies: ["Donots"],
            path: "Tests/DonotsTests"
        ),
    ]
)
