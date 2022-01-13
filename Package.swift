// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "CLLocationManagerPublisher",
    platforms: [
        .macOS(.v11),
        .iOS(.v14)
    ],
    products: [
        .library(name: "CLLocationManagerPublisher", targets: ["CLLocationManagerPublisher"]),
    ],
    targets: [
        .target(name: "CLLocationManagerPublisher", dependencies: []),
    ]
)
