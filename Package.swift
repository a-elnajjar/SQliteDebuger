// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.


import PackageDescription

let package = Package(
    name: "SQLiteDebuger",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(
            name: "SQLiteDebuger",
            targets: ["SQLiteDebuger"]),
    ],
    targets: [
        .target(
            name: "SQLiteDebuger",
            dependencies: []),
        .testTarget(
            name: "SQLiteDebugerTests",
            dependencies: ["SQLiteDebuger"]),
    ]
)
