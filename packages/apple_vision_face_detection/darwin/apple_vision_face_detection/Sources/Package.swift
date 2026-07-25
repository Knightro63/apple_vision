// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "apple_vision_face_detection",
    platforms: [
        .macOS(.v10_13),
        .iOS(.v12)
    ],
    products: [
        .library(name: "apple-vision-face-detection", targets: ["apple_vision_face_detection"]),
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ],
    targets: [
        .target(
            name: "apple_vision_face_detection",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ]
        )
    ]
)
