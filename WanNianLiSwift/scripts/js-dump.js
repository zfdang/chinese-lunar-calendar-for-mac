// 运行原 calendar.js 中的 Calendar 计算函数，输出格式与 lunar-dump 相同
// 用法: node js-dump.js <vendors目录> [起始年] [结束年]
const fs = require("fs");
const path = require("path");
const dir = process.argv[2];
const from = parseInt(process.argv[3] || "1901");
const to = parseInt(process.argv[4] || "2049");
const read = (f) => fs.readFileSync(path.join(dir, f), "utf8");
const src = read("calendar.js");
// 截取数据表和 Calendar 函数，去掉依赖 DOM 的部分
const body = src.slice(src.indexOf("(function() {") + "(function() {".length, src.indexOf("// MonthData, data model"));
const code = [read("holidays.js"), read("festivals.js"), read("events.js"), body, "this.Calendar = Calendar;"].join("\n");
const ctx = {};
new Function(code).call(ctx);
const out = [];
for (let d = new Date(from, 0, 1); d.getFullYear() <= to; d.setDate(d.getDate() + 1)) {
  const c = new ctx.Calendar(new Date(d.valueOf()));
  const key = c.solarYear + ("0" + c.solarMonth).slice(-2) + ("0" + c.solarDate).slice(-2);
  out.push([key, c.lunarMonth, c.lunarDate, c.lunarIsLeapMonth ? 1 : 0, c.ganzhiYear, c.ganzhiMonth,
    c.ganzhiDate, c.shengxiao, c.jieqi, c.lunarFestival.trim(), c.solarFestival, c.specialEvent,
    c.adjusted, c.showInLunar].join("\t"));
}
process.stdout.write(out.join("\n") + "\n");
