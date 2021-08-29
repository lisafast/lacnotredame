// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "LacnotredameSite",
    products: [
        .executable(
            name: "LacnotredameSite",
            targets: ["LacnotredameSite"]
        )
    ],
    dependencies: [
        .package(name: "Publish", url: "https://github.com/johnsundell/publish.git", from: "0.7.0"),
        .package(name: "CompressPublishPlugin", url: "https://github.com/vation-ca/compresspublishplugin", from: "0.6.0"),
        .package(name: "CustomPagesPublishPlugin", url: "https://github.com/vation-ca/custompagespublishplugin", from: "0.1.0"),


    ],
    targets: [
        .target(
            name: "LacnotredameSite",
            dependencies: ["Publish",
                           "CompressPublishPlugin",
                           "CustomPagesPublishPlugin"
                          ]
        )
    ]
)
