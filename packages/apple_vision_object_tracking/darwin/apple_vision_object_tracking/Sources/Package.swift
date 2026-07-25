// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "apple_vision_object_tracking",
    platforms: [
        .macOS(.v10_14),
        .iOS(.v12)
    ],
    products: [
        .library(name: "apple-vision-object-tracking", targets: ["apple_vision_object_tracking"]),
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ],
    targets: [
        .target(
            name: "apple_vision_object_tracking",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ]
        )
    ]
)
