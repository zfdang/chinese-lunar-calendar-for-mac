// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "WanNianLi",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "WanNianLi", targets: ["WanNianLi"]),
    ],
    targets: [
        // 纯计算逻辑：农历、干支、节气、节日、调休，不依赖 AppKit
        .target(name: "LunarCore"),
        // 菜单栏应用
        .executableTarget(name: "WanNianLi", dependencies: ["LunarCore"]),
        // 命令行工具：导出每日计算结果，用于与原 calendar.js 对比验证
        .executableTarget(name: "lunar-dump", dependencies: ["LunarCore"]),
    ]
)
