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
    dependencies: [
        .package(url: "https://github.com/typelift/SwiftCheck", from: "0.12.0")
    ],
    targets: [
        .target(
            name: "FadeAnimation",
            path: "Sources/FadeAnimation"
        ),
        .testTarget(
            name: "FadeAnimationTests",
            dependencies: [
                "FadeAnimation",
                "SwiftCheck"
            ],
            path: "Tests/FadeAnimationTests"
        )
    ]
)
