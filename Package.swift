// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "AudioKit",
    platforms: [.macOS(.v10_13), .iOS(.v11), .tvOS(.v11)],
    products: [.library(name: "AudioKit", targets: ["AudioKit"])],
    dependencies: [.package(url: "https://github.com/orchetect/MIDIKit", from: "0.4.0")],
    targets: [
        .target(name: "AudioKit", dependencies: ["MIDIKit"]),
        .testTarget(name: "AudioKitTests", dependencies: ["AudioKit"], resources: [.copy("TestResources/")]),
    ],
    cxxLanguageStandard: .cxx14
)
