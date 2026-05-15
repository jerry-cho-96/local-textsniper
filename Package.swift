// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "TextSniperLocal",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "TextSniperLocal", targets: ["TextSniperLocal"])
    ],
    targets: [
        .target(
            name: "TextSniperCore"
        ),
        .executableTarget(
            name: "TextSniperLocal",
            dependencies: [
                "TextSniperCore"
            ],
            linkerSettings: [
                .linkedFramework("AppKit"),
                .linkedFramework("Carbon"),
                .linkedFramework("CoreImage"),
                .linkedFramework("CoreGraphics"),
                .linkedFramework("ServiceManagement"),
                .linkedFramework("Vision")
            ]
        ),
        .testTarget(
            name: "TextSniperCoreTests",
            dependencies: [
                "TextSniperCore"
            ]
        )
    ]
)
