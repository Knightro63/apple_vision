// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "apple_vision_scanner",
    platforms: [
        .macOS(.v10_13),
        .iOS(.v11)
    ],
    products: [
        .library(name: "apple-vision-scanner", targets: ["apple_vision_scanner"]),
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ],
    targets: [
        .target(
            name: "apple_vision_scanner",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ]
        )
    ]
)
