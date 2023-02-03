// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "FeatureFlags",
    platforms: [
        .iOS(.v11),
        .macOS(.v10_13)
    ],
    products: [
        .library(
            name: "FeatureFlags",
            targets: ["FeatureFlags"])
    ],
    targets: [
        .target(
            name: "FeatureFlags",
            path: "FeatureFlags"
        )
    ]
)
