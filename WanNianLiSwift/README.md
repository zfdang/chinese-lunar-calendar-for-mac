# WanNianLiSwift — 原生 Swift 版菜单栏万年历

用 Swift（AppKit + SwiftUI）重新实现的菜单栏万年历，功能与原来的 WanNianLi（Objective-C + WebView + calendar.js）保持一致，不再依赖网页。

应用名称和 Bundle ID（`WanNianLiSwift.app` / `com.zfdang.WanNianLiSwift`）与旧版不同，两者可以同时安装。

## 功能

- 菜单栏图标显示当天日期，跨天自动更新；鼠标悬停显示公历、农历
- 左键或右键点击图标弹出月历，点击其他地方自动关闭；每次打开回到今天
- 月历显示公历日期、农历日期、节日、节气、个人事件，以及国务院公布的调休（放假显示红色）
- 点击某天选中并在标题栏显示其农历、干支；按住不放显示详细信息
- 年、月选择框，上年 / 上月 / 下月 / 下年 / 今日按钮
- 键盘：← 上一年，→ 下一年，↑ 上一月，↓ 下一月，↵ 回到今天
- 设置菜单：自动启动、外观（跟随系统 / 日间 / 夜间）、显示节日（按分类开关）、自定义日期、使用帮助、更新假日信息、版本、联系作者、退出
- 自定义日期：生日、纪念日等，支持每年农历、每年公历、每年某月第几个星期几、某一天；可导入 / 导出
- 调休安排每周自动检查更新，也可以手动"更新假日信息"
- 首次运行时，如果不在"应用程序"文件夹，会询问是否移动过去
- 支持浅色 / 深色模式

## 与旧版相比的变化

- **农历算法**：改用系统自带的 `Calendar(identifier: .chinese)`（ICU），不再使用 calendar.js 中的查表数据。
  与[香港天文台](https://www.hko.gov.hk/tc/gts/time/conversion.htm)公布的对照表逐日比较，1921–2099 年完全一致
  （ICU 在 2057 年九月、2097 年七月把初一算成第 0 天，代码中已修正）；
  旧表在 1933、1954、1956、1978、1996、2033–2034 年有错误（例如 2033 年应闰十一月，旧表为闰七月）。
  1914、1916、1920 年与天文台有少量差异（1929 年以前的历法时间标准不同）。
- **节气**：沿用原来 1900–2100 年的节气表，与香港天文台数据完全一致。
- **月干支**：按"节"（立春、惊蛰……）换月，旧版按农历月计算。
- **年份范围**：1901–2099（旧版 1901–2049）。
- **数据格式**：不再使用 js 文件。调休安排为 holidays.json，内置节日写在代码中，自定义日期保存为 custom-events.json；第一次运行时自动从旧版的 festivals.js / events.js 导入用户自己添加的条目。
- **七夕**：内置节日中农历七月初七显示为"七夕"（旧版为"情人节"）。
- **自动启动**：使用 macOS 13 的 `SMAppService`。

## 数据文件

| 数据 | 位置 | 说明 |
| --- | --- | --- |
| 调休安排 | `Resources/calendar-data/holidays.json`（内置），在线更新后保存到 `~/Library/Application Support/com.zfdang.calendar/holidays.json` | 使用两者中版本较新的一份 |
| 内置节日 | `Sources/LunarCore/Festivals.swift` | 分为传统节日、公历节日、西方节日、纪念日，可在"显示节日"中按分类隐藏 |
| 自定义日期 | `~/Library/Application Support/com.zfdang.calendar/custom-events.json` | 在"自定义日期"窗口中编辑，可导入 / 导出 |

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
./scripts/build-app.sh          # 生成 build/WanNianLiSwift.app 和 build/WanNianLiSwift.app.zip（universal）
swift run WanNianLi             # 开发时直接运行
```

## 验证农历计算

```bash
./scripts/verify-lunar.sh
```

逐日与香港天文台 1901–2099 年对照表比较农历日期和节气，并与原 calendar.js 的结果（1901–2049）比较（需要 node、python3 和网络）。

## 发布假日信息

每年国务院公布新的放假安排后：

1. 在 `Resources/calendar-data/holidays.json` 中添加新一年的数据，并把 `version` 改为当天日期（如 `20261105`）
2. 推送到 master 后，用户的应用会在一周内自动更新，也可以手动"更新假日信息"（地址见 `DataStore.holidaysRemoteURL`）
3. 如果仍需支持旧版应用，用 `scripts/export-holidays-js.py Resources/calendar-data/holidays.json ../WanNianLi/WanNianLi/Resources/vendors/holidays.js` 生成旧版使用的 holidays.js

## 代码结构

```
Sources/
  LunarCore/          纯计算逻辑（不依赖 AppKit）
    LunarCalendar     公历转农历、干支、生肖、节气
    CalendarDay       每天的显示信息（节日、调休、格子中的文字），MonthGrid 月历
    CalendarData      按日期查找节日、事件、调休
    DateRule          日期规则（农历 / 公历 / 第几个星期几 / 某一天）、自定义事件
    Festivals         内置节日
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
  lunar-dump/         导出每日计算结果，用于验证
```
