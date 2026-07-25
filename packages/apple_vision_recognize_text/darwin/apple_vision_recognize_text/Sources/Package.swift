// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "apple_vision_recognize_text",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v12)
    ],
    products: [
        .library(name: "apple-vision-recognize-text", targets: ["apple_vision_recognize_text"]),
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ],
    targets: [
        .target(
            name: "apple_vision_recognize_text",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ]
        )
    ]
)
