// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "CROSSxSDK",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "CROSSxSDK",
            targets: ["CROSSxCoreSDK", "CROSSxCoreSDKResources", "CrossWebAuthKit"]
        ),
        .library(
            name: "CrossWebAuthKit",
            targets: ["CrossWebAuthKit"]
        )
    ],
    targets: [
        .binaryTarget(
            name: "CROSSxCoreSDK",
            path: "CROSSxSDK.xcframework"
        ),
        .target(
            name: "CROSSxCoreSDKResources",
            path: "Resources/CROSSxCoreSDKResources",
            resources: [
                .process("Resources")
            ]
        ),
        .binaryTarget(
            name: "CrossWebAuthKit",
            path: "CrossWebAuthKit.xcframework"
        )
    ]
)
