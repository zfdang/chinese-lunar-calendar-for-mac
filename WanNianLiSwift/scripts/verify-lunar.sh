#!/bin/bash
# 验证农历计算：
# 1. 与香港天文台公布的 1901-2099 年公历农历对照表逐日比较（农历日期、节气）
# 2. 列出与原 calendar.js 计算结果不同的字段
set -euo pipefail
cd "$(dirname "$0")/.."
WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT

swift build --product lunar-dump >/dev/null
.build/debug/lunar-dump Resources/calendar-data 1901 2099 > "$WORK/swift.tsv"
node scripts/js-dump.js ../WanNianLi/WanNianLi/Resources/vendors 1901 2049 > "$WORK/js.tsv"

mkdir -p "$WORK/hko"
seq 1901 2099 | xargs -P 16 -I{} curl -sf -o "$WORK/hko/T{}.txt" \
    "https://www.hko.gov.hk/tc/gts/time/calendar/text/files/T{}c.txt"
python3 scripts/hko_compare.py "$WORK"
