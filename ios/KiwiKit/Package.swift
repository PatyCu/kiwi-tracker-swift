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
  dependencies: [
    .package(url: "https://github.com/supabase/supabase-swift", exact: "2.55.7")
  ],
  targets: [
    .target(name: "KiwiDomain", swiftSettings: strict),
    .target(
      name: "KiwiData",
      dependencies: ["KiwiDomain", .product(name: "Supabase", package: "supabase-swift")],
      swiftSettings: strict
    ),
    .testTarget(name: "KiwiDataTests", dependencies: ["KiwiData"], swiftSettings: strict),
    .target(
      name: "KiwiDesign",
      resources: [.process("Resources")],
      swiftSettings: mainActorByDefault
    ),
    .target(
      name: "KiwiFeatures",
      dependencies: ["KiwiDomain", "KiwiDesign"],
      swiftSettings: mainActorByDefault
    ),
    .testTarget(
      name: "KiwiFeaturesTests",
      dependencies: ["KiwiFeatures"],
      swiftSettings: mainActorByDefault
    ),
  ]
)
