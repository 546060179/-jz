// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "FadeAnimation",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "FadeAnimation",
            targets: ["FadeAnimation"]
        )
    ],
    targets: [
        .target(
            name: "FadeAnimation",
            path: "Sources/FadeAnimation"
        ),
        .testTarget(
            name: "FadeAnimationTests",
            dependencies: [
                "FadeAnimation"
            ],
            path: "Tests/FadeAnimationTests"
        )
    ]
)
