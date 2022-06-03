// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "LacnotredameSite",
    platforms: [.macOS(.v12)], // Temporary until Xcode 13.2 has been released
    products: [
        .executable(
            name: "LacnotredameSite",
            targets: ["LacnotredameSite"]
        )
    ],
    dependencies: [
      .package(name: "Publish", url: "https://github.com/johnsundell/publish.git", from: "0.9.0"),
        .package(name: "CompressPublishPlugin", url: "https://github.com/vation-ca/compresspublishplugin", .branch("main")), // from: "0.6.0"),
        .package(name: "CustomPagesPublishPlugin", url: "https://github.com/vation-ca/custompagespublishplugin", .branch("main")), //  from: "0.1.0"),
        .package(name: "SiteCheckPublishPlugin", url: "https://github.com/vation-ca/sitecheckpublishplugin", .branch("main")), //  from: "0.1.0")
    ],
    targets: [
        .executableTarget(
            name: "LacnotredameSite",
            dependencies: ["Publish",
                           "CompressPublishPlugin",
                           "CustomPagesPublishPlugin",
                           "SiteCheckPublishPlugin"
                          ]
        )
    ]
)
