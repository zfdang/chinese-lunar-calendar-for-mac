#!/usr/bin/env python3
"""由 holidays.json 生成旧版应用使用的 holidays.js。

用法: export-holidays-js.py <holidays.json> <holidays.js>
"""
import json
import sys

data = json.load(open(sys.argv[1], encoding="utf-8"))
out = [f"// Version: {data['version']}",
       "// 国务院公布的假期调整方案（由 docs/data/holidays.json 生成）",
       '// 假日为"+"，工作日为"-"',
       "var HOLIDAYADJUSTMENT = {"]
for d in sorted(data["days"], key=lambda d: d["date"], reverse=True):
    key = d["date"].replace("-", "")
    out.append(f'    "{key}": "{"+" if d["isOffDay"] else "-"}",  // {d["name"]}')
out.append("};")
open(sys.argv[2], "w", encoding="utf-8").write("\n".join(out) + "\n")
print(f"{len(data['days'])} days written")
