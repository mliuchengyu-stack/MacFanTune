// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "FanTune",
    platforms: [.macOS(.v14)],
    products: [.executable(name: "FanTune", targets: ["FanTune"])],
    targets: [.executableTarget(name: "FanTune")]
)
