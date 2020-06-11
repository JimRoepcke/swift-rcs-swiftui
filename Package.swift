// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "RCSSwiftUI",
  platforms: [
    .iOS(.v13)
  ],
  products: [
    // Products define the executables and libraries produced by a package, and make them visible to other packages.
    .library(
      name: "RCSSwiftUI",
      targets: ["RCSSwiftUI"]),
  ],
  dependencies: [
    // Dependencies declare other packages that this package depends on.
    // .package(url: /* package url */, from: "1.0.0"),
    .package(name: "RCSFoundation", url: "https://github.com/JimRoepcke/swift-rcs-foundation.git", .branch("master")),
    .package(name: "swift-composable-architecture", url: "https://github.com/pointfreeco/swift-composable-architecture.git", .exact("0.3.0"))
  ],
  targets: [
    // Targets are the basic building blocks of a package. A target can define a module or a test suite.
    // Targets can depend on other targets in this package, and on products in packages which this package depends on.
    .target(
      name: "RCSSwiftUI",
      dependencies: [
        "RCSFoundation",
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
      ]
    ),
    .testTarget(
      name: "RCSSwiftUITests",
      dependencies: ["RCSSwiftUI"]),
  ]
)
