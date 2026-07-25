// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "apple_vision_object",
    platforms: [
        .macOS(.v10_14),
        .iOS(.v14)
    ],
    products: [
        .library(name: "apple-vision-object", targets: ["apple_vision_object"]),
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ],
    targets: [
        .target(
            name: "apple_vision_object",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ],
            path: "Sources"
        )
    ]
)
