#!/bin/bash
# 在有图形界面的 macOS 上验证自定义日期窗口能够显示且位于屏幕内。
set -euo pipefail
cd "$(dirname "$0")/.."
WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT
swiftc -parse-as-library -emit-object -emit-module -whole-module-optimization \
    -module-name LunarCore -emit-module-path "$WORK/LunarCore.swiftmodule" \
    Sources/LunarCore/*.swift -o "$WORK/LunarCore.o"
sources=()
for source in Sources/WanNianLi/*.swift; do
    case "$source" in */main.swift|*/Snapshot.swift) ;; *) sources+=("$source");; esac
done
swiftc -parse-as-library -D DEBUG -I "$WORK" "${sources[@]}" Tests/WindowRegressionTests.swift \
    "$WORK/LunarCore.o" -o "$WORK/window-regressions"
"$WORK/window-regressions"
