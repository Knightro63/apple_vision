// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "apple_vision_lift_subjects",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(name: "apple-vision-lift-subjects", targets: ["apple_vision_lift_subjects"]),
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ],
    targets: [
        .target(
            name: "apple_vision_lift_subjects",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ],
            path: "Sources"
        )
    ]
)
