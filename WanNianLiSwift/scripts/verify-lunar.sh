#!/bin/bash
# 验证农历计算：与香港天文台公布的 1901-2099 年公历农历对照表逐日比较（农历日期、节气）。
# 如果旧版目录（../WanNianLi）和 node 都存在，同时列出与原 calendar.js 计算结果的差异（1901-2049）。
# 需要 python3 和网络；个别年份下载失败时会跳过并在最后列出，不会中断整个验证。
set -uo pipefail
cd "$(dirname "$0")/.."
WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT

swift build --product lunar-dump >/dev/null || exit 1
.build/debug/lunar-dump ../docs/data 1901 2099 > "$WORK/swift.tsv" || exit 1

LEGACY=../WanNianLi/WanNianLi/Resources/vendors
if [ -f "$LEGACY/calendar.js" ] && command -v node >/dev/null; then
    node scripts/js-dump.js "$LEGACY" 1901 2049 > "$WORK/js.tsv"
else
    echo "(skipping comparison with the old calendar.js: $LEGACY or node not available)"
fi

mkdir -p "$WORK/hko"
seq 1901 2099 | xargs -P 16 -I{} sh -c \
    'curl -sf --retry 2 -o "$1/hko/T$2.txt" "https://www.hko.gov.hk/tc/gts/time/calendar/text/files/T$2c.txt" || rm -f "$1/hko/T$2.txt"' \
    _ "$WORK" {}
MISSING=$(for y in $(seq 1901 2099); do [ -s "$WORK/hko/T$y.txt" ] || printf '%s ' "$y"; done)

python3 scripts/hko_compare.py "$WORK"
STATUS=$?
if [ -n "$MISSING" ]; then
    echo "WARNING: could not download HKO data for: $MISSING(those years were not verified)"
fi
exit $STATUS
