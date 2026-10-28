#!/bin/bash
# 应用数据层的回归测试；只需要 Command Line Tools，不依赖 XCTest。
set -euo pipefail
cd "$(dirname "$0")/.."
WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT
# 在临时目录显式生成模块和目标文件，不依赖不同 SwiftPM 版本的 .build 目录布局。
swiftc -parse-as-library -emit-object -emit-module -whole-module-optimization \
    -module-name LunarCore -emit-module-path "$WORK/LunarCore.swiftmodule" \
    Sources/LunarCore/*.swift -o "$WORK/LunarCore.o"
swiftc -parse-as-library -D DEBUG -I "$WORK" \
    Sources/WanNianLi/DataStore.swift Sources/WanNianLi/WindowPlacement.swift Tests/AppRegressionTests.swift \
    "$WORK/LunarCore.o" -o "$WORK/app-regressions"
"$WORK/app-regressions"
