// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "apple_vision_pose_3d",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(name: "apple-vision-pose-3d", targets: ["apple_vision_pose_3d"]),
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ],
    targets: [
        .target(
            name: "apple_vision_pose_3d",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ],
            path: "Sources"
        )
    ]
)
