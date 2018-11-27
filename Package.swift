// swift-tools-version:4.2
import PackageDescription

let package = Package(
    name: "FeatureFlags",
    products: [
        .library(
            name: "FeatureFlags",
            targets: ["FeatureFlagsPackage"])
    ],
    targets: [
        .target(
            name: "FeatureFlagsPackage",
            path: "FeatureFlags",
            exclude: ["Classes/UI", "Classes/Extensions"])
    ]
)

