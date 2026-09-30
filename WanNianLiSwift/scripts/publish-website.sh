#!/bin/bash
# 把某个 GitHub Release 的安装包发布到网站（仓库中的 docs/ 目录，即 calendar.zfdang.com）。
#
# 用法: scripts/publish-website.sh v4.2
#   - 从 GitHub Release 下载 Apple 芯片和 Intel 芯片两个安装包
#   - 检查每个安装包的架构、版本号和签名
#   - 复制为 docs/WanNianLiSwift-AppleSilicon.zip、docs/WanNianLiSwift-Intel.zip（文件名固定，网页链接不变）
#   - 更新 docs/version.json（网页上显示的版本号）
# 之后提交 docs/ 的改动并合并到 master 即可。只能在 macOS 上运行（用到 ditto、lipo、codesign、BSD sed），需要 gh（GitHub CLI）。
set -euo pipefail
cd "$(dirname "$0")/../.."

TAG=${1:?usage: publish-website.sh <tag>, e.g. v4.2}
VERSION=${TAG#v}
REPO=zfdang/chinese-lunar-calendar-for-mac
WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT

gh release download "$TAG" -R "$REPO" -D "$WORK" -p "WanNianLiSwift-*.zip"

check() {  # check <zip> <arch>
    local zip=$1 arch=$2 dir
    [ -f "$zip" ] || { echo "missing $(basename "$zip") in release $TAG" >&2; exit 1; }
    dir=$(mktemp -d "$WORK/check.XXXX")
    ditto -x -k "$zip" "$dir"
    local app="$dir/WanNianLiSwift.app"
    local archs version
    archs=$(lipo -archs "$app/Contents/MacOS/WanNianLiSwift")
    version=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$app/Contents/Info.plist")
    [ "$archs" = "$arch" ] || { echo "$(basename "$zip"): expected $arch, got $archs" >&2; exit 1; }
    [ "$version" = "$VERSION" ] || { echo "$(basename "$zip"): expected version $VERSION, got $version" >&2; exit 1; }
    codesign --verify "$app"
    echo "ok  $(basename "$zip"): $archs, version $version"
}

check "$WORK/WanNianLiSwift-$VERSION-AppleSilicon.zip" arm64
check "$WORK/WanNianLiSwift-$VERSION-Intel.zip" x86_64

cp "$WORK/WanNianLiSwift-$VERSION-AppleSilicon.zip" docs/WanNianLiSwift-AppleSilicon.zip
cp "$WORK/WanNianLiSwift-$VERSION-Intel.zip" docs/WanNianLiSwift-Intel.zip
cat > docs/version.json <<JSON
{
  "version": "$VERSION",
  "tag": "$TAG",
  "files": {
    "AppleSilicon": "WanNianLiSwift-AppleSilicon.zip",
    "Intel": "WanNianLiSwift-Intel.zip"
  }
}
JSON
# 网页中的后备版本号（version.json 读取失败时显示）
sed -i '' -E "s#(<span class=\"app-version\">)[^<]*(</span>)#\1$VERSION\2#g" docs/index.html
grep -q "<span class=\"app-version\">$VERSION</span>" docs/index.html ||
    { echo "docs/index.html: <span class=\"app-version\"> not found, update the fallback version by hand" >&2; exit 1; }

echo "Website updated to $VERSION. Review and commit:"
git status --short docs/
