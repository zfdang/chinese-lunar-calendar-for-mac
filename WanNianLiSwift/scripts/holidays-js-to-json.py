#!/usr/bin/env python3
"""把旧版 holidays.js 转换为 holidays.json（一次性迁移用）。

节日名称取自每段数据前的注释，例如 "// 二、春节：..." → 春节。
用法: holidays-js-to-json.py <holidays.js> <holidays.json>
"""
import json
import re
import sys

src, dst = sys.argv[1], sys.argv[2]
lines = open(src, encoding="utf-8-sig").read().splitlines()
version = re.sub(r"[/\s]|Version:", "", lines[0]) or "0"

name, days, sources = None, {}, []
for line in lines:
    comment = re.match(r"\s*//\s*(.*)", line)
    if comment:
        text = comment.group(1)
        if text.startswith("http"):
            sources.append(text.strip())
        m = re.match(r"[一二三四五六七八九十]+、(.+?)：", text)
        if m:
            name = m.group(1)
        elif text.startswith("延长") and "春节" in text:
            name = "春节"
        continue
    m = re.match(r'\s*"(\d{4})(\d{2})(\d{2})"\s*:\s*"([+-])"', line)
    if m:
        date = f"{m[1]}-{m[2]}-{m[3]}"
        days[date] = {"date": date, "name": name or "", "isOffDay": m[4] == "+"}

data = {
    "version": version,
    "sources": sources,
    "days": sorted(days.values(), key=lambda d: d["date"]),
}
with open(dst, "w", encoding="utf-8") as f:
    json.dump(data, f, ensure_ascii=False, indent=2)
    f.write("\n")
print(f"{len(data['days'])} days, version {version}")
