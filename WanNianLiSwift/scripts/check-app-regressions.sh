#!/bin/bash
# 应用数据层的回归测试；只需要 Command Line Tools，不依赖 XCTest。
set -euo pipefail
cd "$(dirname "$0")/.."
swift build --product lunar-dump >/dev/null
BIN_DIR=$(swift build --show-bin-path)
WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT
swiftc -parse-as-library -D DEBUG -I "$BIN_DIR/Modules" \
    Sources/WanNianLi/DataStore.swift Tests/AppRegressionTests.swift \
    "$BIN_DIR"/LunarCore.build/*.o -o "$WORK/app-regressions"
"$WORK/app-regressions"
