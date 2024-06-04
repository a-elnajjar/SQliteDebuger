// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.


// swift-tools-version:5.3
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
            dependencies: [],
            path: "Sources",
            swiftSettings: [
                .unsafeFlags(["-Xlinker", "-lsqlite3"], .when(platforms: [.iOS]))
            ]),
        .testTarget(
            name: "SQLiteDebugerTests",
            dependencies: ["SQLiteDebuger"],
            path: "Tests"),
    ]
)
