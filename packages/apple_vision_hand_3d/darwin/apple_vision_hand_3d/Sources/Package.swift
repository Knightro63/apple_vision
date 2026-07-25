// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "apple_vision_hand_3d",
    platforms: [
        .macOS(.v11),
        .iOS(.v14)
    ],
    products: [
        .library(name: "apple-vision-hand-3d", targets: ["apple_vision_hand_3d"]),
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ],
    targets: [
        .target(
            name: "apple_vision_hand_3d",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ]
        )
    ]
)
