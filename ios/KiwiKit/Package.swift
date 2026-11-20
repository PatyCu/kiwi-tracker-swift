// swift-tools-version: 6.2

import PackageDescription

// Module boundaries: docs/architecture.md#modules.
let strict: [SwiftSetting] = [.treatAllWarnings(as: .error)]
let mainActorByDefault: [SwiftSetting] = strict + [.defaultIsolation(MainActor.self)]

let package = Package(
  name: "KiwiKit",
  platforms: [.iOS(.v26)],
  products: [
    .library(name: "KiwiData", targets: ["KiwiData"]),
    .library(name: "KiwiFeatures", targets: ["KiwiFeatures"]),
  ],
  targets: [
    .target(name: "KiwiDomain", swiftSettings: strict),
    .target(name: "KiwiData", dependencies: ["KiwiDomain"], swiftSettings: strict),
    .target(name: "KiwiDesign", swiftSettings: mainActorByDefault),
    .target(
      name: "KiwiFeatures",
      dependencies: ["KiwiDomain", "KiwiDesign"],
      swiftSettings: mainActorByDefault
    ),
  ]
)
