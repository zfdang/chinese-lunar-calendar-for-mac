#!/bin/bash
# 检查农历计算结果是否与基准数据（Tests/lunar-golden-1901-2099.txt）一致。
# 基准数据已与香港天文台 1921–2099 年的公历农历对照表逐日核对（见 scripts/verify-lunar.sh）。
# 农历日期来自系统的 ICU，如果 macOS 更新改变了 ICU 的计算结果，这个检查会失败。
#
# 用法: scripts/check-golden.sh            检查
#       scripts/check-golden.sh --update   重新生成基准数据（请先用 verify-lunar.sh 与香港天文台核对）
set -euo pipefail
cd "$(dirname "$0")/.."

GOLDEN=Tests/lunar-golden-1901-2099.txt
swift build --product lunar-dump >/dev/null
if [ "${1:-}" = "--update" ]; then
    mkdir -p Tests
    .build/debug/lunar-dump --golden 1901 2099 > "$GOLDEN"
    echo "Updated $GOLDEN ($(wc -l < "$GOLDEN") lines)"
    exit 0
fi

.build/debug/lunar-dump --selftest

ACTUAL=$(mktemp)
trap 'rm -f "$ACTUAL"' EXIT
.build/debug/lunar-dump --golden 1901 2099 > "$ACTUAL"
if diff -u "$GOLDEN" "$ACTUAL" > "$ACTUAL.diff"; then
    echo "Lunar calendar matches golden data ($(wc -l < "$GOLDEN") lines)"
else
    echo "Lunar calendar differs from golden data:" >&2
    head -50 "$ACTUAL.diff" >&2
    rm -f "$ACTUAL.diff"
    exit 1
fi
rm -f "$ACTUAL.diff"
