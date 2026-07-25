// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "apple_vision_face_mesh",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v14)
    ],
    products: [
        .library(name: "apple-vision-face-mesh", targets: ["apple_vision_face_mesh"]),
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ],
    targets: [
        .target(
            name: "apple_vision_face_mesh",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ],
            path: "Sources"
        )
    ]
)
