// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "TenunUI",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "TenunUI", targets: ["TenunUI"]),
    ],
    targets: [
        // Swift 5 language mode: no runtime isolation traps. iOS 27's SwiftUI renderer can run
        // view closures off the main thread, where Swift 6's runtime checks stop the app.
        // Concurrency checks become warnings here, not errors.
        .target(name: "TenunUI", swiftSettings: [.swiftLanguageMode(.v5)]),
        .testTarget(name: "TenunUITests", dependencies: ["TenunUI"]),
    ]
)
