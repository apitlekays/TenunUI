// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "TenunUI",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "TenunUI", targets: ["TenunUI"]),
    ],
    targets: [
        .target(name: "TenunUI"),
        .testTarget(name: "TenunUITests", dependencies: ["TenunUI"]),
    ]
)
