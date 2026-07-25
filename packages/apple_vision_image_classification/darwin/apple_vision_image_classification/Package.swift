// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "apple_vision_image_classification",
    platforms: [
        .macOS(.v10_14),
        .iOS(.v14)
    ],
    products: [
        .library(name: "apple-vision-image-classification", targets: ["apple_vision_image_classification"]),
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ],
    targets: [
        .target(
            name: "apple_vision_image_classification",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ],
            path: "Sources",
            resources: [
                // Explicitly processes the compiled model directory as a package bundle asset
                .process("MobileNetV2Int8LUT.mlmodel")
            ]
        )
    ]
)
