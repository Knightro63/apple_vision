// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "apple_vision_animal_pose",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(name: "apple-vision-animal-pose", targets: ["apple_vision_animal_pose"]),
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ],
    targets: [
        .target(
            name: "apple_vision_animal_pose",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ]
        )
    ]
)
