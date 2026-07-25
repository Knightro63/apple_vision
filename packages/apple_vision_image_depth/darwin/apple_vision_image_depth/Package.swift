// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "apple_vision_image_depth",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(name: "apple-vision-image-depth", targets: ["apple_vision_image_depth"]),
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ],
    targets: [
        .target(
            name: "apple_vision_image_depth",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ],
            path: "Sources"
        )
    ]
)
