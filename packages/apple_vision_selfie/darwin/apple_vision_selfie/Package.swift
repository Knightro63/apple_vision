// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "apple_vision_selfie",
    platforms: [
        .macOS(.v12),
        .iOS(.v13)
    ],
    products: [
        .library(name: "apple-vision-selfie", targets: ["apple_vision_selfie"]),
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ],
    targets: [
        .target(
            name: "apple_vision_selfie",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ],
            path: "Sources"
        )
    ]
)
