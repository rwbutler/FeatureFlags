// swift-tools-version:4.2
import PackageDescription

let package = Package(
    name: "FeatureFlags",
    products: [
        .library(
            name: "FeatureFlags",
            targets: ["FeatureFlags"])
    ],
    targets: [
        .target(
            name: "FeatureFlags",
            path: "FeatureFlags",
            exclude: ["Classes/UI", "Classes/Extensions/UIColorAdditions.swift"])
    ]
)
