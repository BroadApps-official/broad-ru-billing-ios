// swift-tools-version: 6.0
import PackageDescription
let package = Package(
    name: "BroadRUBilling",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "BroadRUBilling", targets: ["BroadRUBilling"]),
        .library(name: "BroadRUBillingUI", targets: ["BroadRUBillingUI"])
    ],
    dependencies: [
        .package(url: "https://github.com/BroadApps-official/broad-core-ios.git", from: "3.0.0"),
        .package(url: "https://github.com/BroadApps-official/broad-monetization-ios.git", from: "5.0.0"),
        .package(url: "https://github.com/BroadApps-official/broad-ui-flows-ios.git", from: "5.0.0"),
        .package(url: "https://github.com/Swinject/Swinject.git", exact: "2.10.0")
    ],
    targets: [
        .target(name: "BroadRUBilling", dependencies: [
            .product(name: "BroadCore", package: "broad-core-ios"),
            .product(name: "BroadMonetization", package: "broad-monetization-ios"),
            .product(name: "Swinject", package: "Swinject")
        ]),
        .target(name: "BroadRUBillingUI", dependencies: [
            "BroadRUBilling",
            .product(name: "BroadUIFlows", package: "broad-ui-flows-ios")
        ])
    ],
    swiftLanguageModes: [.v5]
)
