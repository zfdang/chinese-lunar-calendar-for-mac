# WanNianLiSwift 开发说明

产品功能、下载与日常使用见[项目首页](../README.md)。本文介绍历法实现、数据文件、构建、测试与维护。

## 历法与旧版迁移

- **农历算法**：改用系统自带的 `Calendar(identifier: .chinese)`（ICU），不再使用 calendar.js 中的查表数据。
  与[香港天文台](https://www.hko.gov.hk/tc/gts/time/conversion.htm)公布的对照表逐日比较，1921–2099 年完全一致
  （ICU 在 2057 年九月、2097 年七月把初一算成第 0 天，代码中已修正）；
  旧表在 1933、1954、1956、1978、1996、2033–2034 年有错误（例如 2033 年应闰十一月，旧表为闰七月）。
  1914、1916、1920 年与天文台有少量差异（1929 年以前的历法时间标准不同）。
- **节气**：沿用原来 1900–2100 年的节气表，与香港天文台数据完全一致。
- **月干支**：按"节"（立春、惊蛰……）换月，旧版按农历月计算。
- **年份范围**：1901–2099（旧版 1901–2049）。
- **数据格式**：不再使用 js 文件。调休安排为 holidays.json，传统节日保留原规则，国外日历由固定版本的第三方数据生成并编译到程序中，自定义日期保存为 custom-events.json；第一次运行时自动从旧版的 festivals.js / events.js 导入用户自己添加的条目。
- **七夕**：内置节日中农历七月初七显示为"七夕"（旧版为"情人节"）。
- **自动启动**：使用 macOS 13 的 `SMAppService`。

## 数据文件

| 数据 | 位置 | 说明 |
| --- | --- | --- |
| 调休安排 | 仓库中的 `docs/data/holidays.json`（构建时打包进应用，同时通过 GitHub Pages 发布），在线更新后保存到 `~/Library/Application Support/com.zfdang.calendar/holidays.json` | 使用内置和已下载中版本较新的一份 |
| 内置节日 | `Sources/LunarCore/Festivals.swift`、`MemorialDays.swift`、`GeneratedFestivalData.swift` | 按分类和国家／地区选择；[来源、许可证与更新方法](Data/FESTIVALS.md) |
| 自定义日期 | `~/Library/Application Support/com.zfdang.calendar/custom-events.json` | 在"自定义日期"窗口中编辑，可导入 / 导出 |

新旧两个版本共用 `~/Library/Application Support/com.zfdang.calendar/` 目录，但自定义日期的格式不同：新版只在第一次运行时从旧版的
festivals.js / events.js 导入一次，之后两边各自独立。如果之后又修改了旧版的文件，可以在"自定义日期"窗口中再导入一次（已存在的条目会自动跳过）。
如果 custom-events.json 无法读取，程序会把它备份为 `custom-events.broken-<时间>.json` 并提示，不会覆盖原来的内容。

`holidays.json` 格式：

```json
{
  "version": "20251104",
  "sources": ["https://www.gov.cn/zhengce/content/202511/content_7047090.htm"],
  "days": [
    { "date": "2026-01-01", "name": "元旦", "isOffDay": true },
    { "date": "2026-01-04", "name": "元旦", "isOffDay": false }
  ]
}
```

`isOffDay` 为 `true` 表示放假，`false` 表示调休上班。

## 构建

只需要 Command Line Tools（不需要 Xcode），要求 macOS 13+：

```bash
cd WanNianLiSwift
./scripts/build-app.sh             # universal，生成 build/WanNianLiSwift.app 和 build/WanNianLiSwift-Universal.zip
./scripts/build-app.sh arm64       # 只构建 Apple Silicon 版本
./scripts/build-app.sh x86_64      # 只构建 Intel 版本
VERSION=4.1 ./scripts/build-app.sh # 指定版本号
swift run WanNianLi                # 开发时直接运行
```

## 发布

完整流程见仓库根目录的 [RELEASE.md](../RELEASE.md)。推送 tag 即可发布，GitHub Actions（`.github/workflows/release.yml`）会构建 Apple Silicon 和 Intel 两个版本，并创建 GitHub Release：

```bash
git tag v4.1 && git push origin v4.1
```

版本号取自 tag（去掉开头的 `v`；本地构建时取最近的 tag）。发布后自动创建网站下载更新 PR，合并后网站生效；也可用 `scripts/publish-website.sh <tag>` 手动补发。Pull request 中修改了 `WanNianLiSwift/` 时也会自动构建（只上传为 Actions artifact，不发布）。
应用只做了 ad-hoc 签名、没有公证。首次打开被阻止时，可按 [Apple 的说明](https://support.apple.com/zh-cn/102445)，在“系统设置 → 隐私与安全性”中允许打开已确认来源的应用。

## 测试

```bash
./scripts/check-app-regressions.sh # 节日来源／地区／迁移及应用数据层回归测试（仅需 Command Line Tools）
./scripts/check-window-regressions.sh # 验证自定义日期窗口可见（需要图形界面）
./scripts/check-golden.sh      # 自检 + 与基准数据对比（CI 中每次构建都会运行）
./scripts/verify-lunar.sh      # 与香港天文台对照表逐日比较（需要网络；不再依赖旧版目录）
```

- `Tests/lunar-golden-1900-2100.txt`：1900–2100 年每个农历月的初一和月长、每个节气、每年一天的日干支。1921–2099 年已与香港天文台的数据核对一致。CI 在多个 macOS 版本上运行这项检查。
  农历日期来自系统的 ICU，如果 macOS 更新改变了计算结果，`check-golden.sh` 会失败；确认新结果正确后用 `check-golden.sh --update` 更新基准数据。
- `lunar-dump --selftest`：自定义事件文件的读写、旧版 js 的导入、节日规则等自检。

## 验证农历计算

```bash
./scripts/verify-lunar.sh
```

逐日与香港天文台 1901–2099 年对照表比较农历日期和节气，并与原 calendar.js 的结果（1901–2049）比较（需要 node、python3 和网络）。

## 发布假日信息

调休安排只有一份：`docs/data/holidays.json`。它既会在构建时打包进应用，也会通过 GitHub Pages 发布在
<https://calendar.zfdang.com/data/holidays.json>。应用在线更新时先访问 Pages 地址（经过 Cloudflare，国内更容易访问），
失败时再尝试 GitHub raw 地址。

每年国务院公布新的放假安排后：

1. 在 `docs/data/holidays.json` 中添加新一年的数据，并把 `version` 改为当天日期（如 `20261105`）
2. 推送到 master，GitHub Pages 更新后，用户的应用会在一周内自动更新，也可以手动"更新假日信息"
3. 如果仍需支持旧版应用，用 `scripts/export-holidays-js.py ../docs/data/holidays.json ../WanNianLi/WanNianLi/Resources/vendors/holidays.js` 生成旧版使用的 holidays.js

## 代码结构

```
Sources/
  LunarCore/          纯计算逻辑（不依赖 AppKit）
    LunarCalendar     公历转农历、干支、生肖、节气
    CalendarDay       每天的显示信息（节日、调休、格子中的文字），MonthGrid 月历
    CalendarData      按日期查找节日、事件、调休
    DateRule          日期规则（农历 / 公历 / 第几个星期几 / 某一天）、自定义事件
    Festivals         节日分类与传统节日，旧版迁移默认清单
    FestivalCatalog   国家与地区日历的选择和加载
    GeneratedFestivalData  固定版本第三方节日快照
    MemorialDays      有来源记录的国内／国际纪念日
    Holidays          holidays.json
    LegacyImporter    从旧版 festivals.js / events.js 导入
    LunarData         节气速查表
  WanNianLi/          菜单栏应用
    StatusItemController  菜单栏图标、弹出窗口、键盘控制
    CalendarView          SwiftUI 月历界面
    CalendarViewModel     当前年月、选中日期
    AppMenu               设置菜单、自动启动
    UpdateHolidaysWindow  更新假日信息
    CustomEventsWindow    自定义日期（添加、编辑、导入、导出）
    DataStore             数据文件管理
    MoveToApplications    移动到"应用程序"文件夹
  lunar-dump/         导出每日计算结果、基准数据，运行自检
Tests/
  lunar-golden-1900-2100.txt  农历基准数据
```
