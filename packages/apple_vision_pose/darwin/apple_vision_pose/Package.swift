// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "apple_vision_pose",
    platforms: [
        .macOS(.v11),
        .iOS(.v14)
    ],
    products: [
        .library(name: "apple-vision-pose", targets: ["apple_vision_pose"]),
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ],
    targets: [
        .target(
            name: "apple_vision_pose",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ],
            path: "Sources"
        )
    ]
)
