// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "apple_vision_hane",
    platforms: [
        .macOS(.v12),
        .iOS(.v14)
    ],
    products: [
        .library(name: "apple-vision-hand", targets: ["apple_vision_hand"]),
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ],
    targets: [
        .target(
            name: "apple_vision_hand",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ],
            path: "Sources"
        )
    ]
)
