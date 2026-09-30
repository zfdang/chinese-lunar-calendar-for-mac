#!/bin/bash
# 构建 WanNianLiSwift.app（universal：arm64 + x86_64），只需要 Command Line Tools，不需要 Xcode。
# 用法: scripts/build-app.sh            → build/WanNianLiSwift.app 和 build/WanNianLiSwift.app.zip
# 应用名和 Bundle ID 与旧版 WanNianLi.app 不同，两者可以同时安装。
set -euo pipefail
cd "$(dirname "$0")/.."

APP=build/WanNianLiSwift.app
rm -rf build && mkdir -p build

for arch in arm64 x86_64; do
    swift build -c release --product WanNianLi --arch "$arch"
done

mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
lipo -create -output "$APP/Contents/MacOS/WanNianLiSwift" \
    .build/arm64-apple-macosx/release/WanNianLi \
    .build/x86_64-apple-macosx/release/WanNianLi
cp Resources/Info.plist "$APP/Contents/"
cp Resources/AppIcon.icns "$APP/Contents/Resources/"
cp -R Resources/calendar-data "$APP/Contents/Resources/"

# ad-hoc 签名；发布时可替换为 Developer ID 签名
codesign --force --sign - "$APP"

(cd build && ditto -c -k --keepParent WanNianLiSwift.app WanNianLiSwift.app.zip)
lipo -info "$APP/Contents/MacOS/WanNianLiSwift"
echo "Built $APP"
