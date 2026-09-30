#!/bin/bash
# 构建 WanNianLiSwift.app，只需要 Command Line Tools，不需要 Xcode。
# 应用名和 Bundle ID 与旧版 WanNianLi.app 不同，两者可以同时安装。
#
# 用法: scripts/build-app.sh [universal|arm64|x86_64]    （默认 universal）
#   生成 build/WanNianLiSwift.app 和 build/WanNianLiSwift[-版本]-<Universal|AppleSilicon|Intel>.zip
#   环境变量 VERSION（可选）：设置应用的版本号，例如 VERSION=4.1；不设置时使用最近的 git tag
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
# 调休安排与 GitHub Pages 共用一份：docs/data/holidays.json
mkdir -p "$APP/Contents/Resources/calendar-data"
cp ../docs/data/holidays.json "$APP/Contents/Resources/calendar-data/"

# 没有指定 VERSION 时使用最近的 git tag（如 v4.1.2 → 4.1.2）
if [ -z "${VERSION:-}" ]; then
    VERSION_FROM_TAG=$(git describe --tags --abbrev=0 --match 'v[0-9]*' 2>/dev/null || true)
    PLIST_VERSION=${VERSION_FROM_TAG#v}
else
    PLIST_VERSION=$VERSION
fi
if [ -n "${PLIST_VERSION:-}" ]; then
    /usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $PLIST_VERSION" "$APP/Contents/Info.plist"
    /usr/libexec/PlistBuddy -c "Set :CFBundleVersion $(date +%Y%m%d)" "$APP/Contents/Info.plist"
fi

# ad-hoc 签名；发布时可替换为 Developer ID 签名
codesign --force --sign - "$APP"

ZIP="WanNianLiSwift${PLIST_VERSION:+-$PLIST_VERSION}-$SUFFIX.zip"
rm -f "build/$ZIP"
(cd build && ditto -c -k --keepParent WanNianLiSwift.app "$ZIP")
lipo -info "$APP/Contents/MacOS/WanNianLiSwift"
echo "Built $APP and build/$ZIP"
