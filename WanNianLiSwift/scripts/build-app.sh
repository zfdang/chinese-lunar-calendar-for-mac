#!/bin/bash
# 构建 WanNianLiSwift.app，只需要 Command Line Tools，不需要 Xcode。
# 应用名和 Bundle ID 与旧版 WanNianLi.app 不同，两者可以同时安装。
#
# 用法: scripts/build-app.sh [universal|arm64|x86_64]    （默认 universal）
#   生成 build/WanNianLiSwift.app 和 build/WanNianLiSwift[-版本]-<Universal|AppleSilicon|Intel>.zip
#   环境变量 VERSION（可选）：设置应用的版本号，例如 VERSION=4.1
set -euo pipefail
cd "$(dirname "$0")/.."

ARCH=${1:-universal}
case "$ARCH" in
    universal) ARCHS=(arm64 x86_64); SUFFIX=Universal ;;
    arm64)     ARCHS=(arm64);        SUFFIX=AppleSilicon ;;
    x86_64)    ARCHS=(x86_64);       SUFFIX=Intel ;;
    *) echo "unknown arch: $ARCH (use universal, arm64 or x86_64)" >&2; exit 1 ;;
esac

APP=build/WanNianLiSwift.app
rm -rf "$APP"
mkdir -p build

BINARIES=()
for arch in "${ARCHS[@]}"; do
    swift build -c release --product WanNianLi --arch "$arch"
    BINARIES+=(".build/$arch-apple-macosx/release/WanNianLi")
done

mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
lipo -create -output "$APP/Contents/MacOS/WanNianLiSwift" "${BINARIES[@]}"
cp Resources/Info.plist "$APP/Contents/"
cp Resources/AppIcon.icns "$APP/Contents/Resources/"
cp -R Resources/calendar-data "$APP/Contents/Resources/"

if [ -n "${VERSION:-}" ]; then
    /usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $VERSION" "$APP/Contents/Info.plist"
    /usr/libexec/PlistBuddy -c "Set :CFBundleVersion $(date +%Y%m%d)" "$APP/Contents/Info.plist"
fi

# ad-hoc 签名；发布时可替换为 Developer ID 签名
codesign --force --sign - "$APP"

ZIP="WanNianLiSwift${VERSION:+-$VERSION}-$SUFFIX.zip"
rm -f "build/$ZIP"
(cd build && ditto -c -k --keepParent WanNianLiSwift.app "$ZIP")
lipo -info "$APP/Contents/MacOS/WanNianLiSwift"
echo "Built $APP and build/$ZIP"
