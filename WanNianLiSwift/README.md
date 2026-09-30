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
- 设置菜单：自动启动、使用帮助、更新假日信息、版本、联系作者、退出
- 在线更新假日信息（holidays.js）
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
- **个人数据**：festivals.js、events.js 已存在时不会被覆盖。
- **自动启动**：使用 macOS 13 的 `SMAppService`。

## 数据文件

数据文件在 `~/Library/Application Support/com.zfdang.calendar/` 中（与旧版共用），格式与旧版相同：

| 文件 | 内容 | 说明 |
| --- | --- | --- |
| `holidays.js` | 调休安排 `HOLIDAYADJUSTMENT` | 首行 `// Version: yyyyMMdd`；内置版本更新或在线更新时替换 |
| `festivals.js` | 阳历、农历、"第几个星期几"节日 | 可自行修改，不会被覆盖 |
| `events.js` | 一次性事件 `SPECIFIC_EVENTS` | 可自行修改，不会被覆盖 |

修改后重新打开日历即可生效。内置的默认数据在 `Resources/calendar-data/`。

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

1. 修改 `../WanNianLi/WanNianLi/Resources/vendors/holidays.js`，并更新首行的 `Version`。
   推送到 master 后，新旧两个版本的用户都可以通过"更新假日信息"获取（地址见 `DataStore.holidaysRemoteURL`）。
2. 发布新版本应用前，把它复制到 `Resources/calendar-data/holidays.js`，作为内置的默认数据。

## 代码结构

```
Sources/
  LunarCore/          纯计算逻辑（不依赖 AppKit）
    LunarCalendar     公历转农历、干支、生肖、节气
    CalendarDay       每天的显示信息（节日、调休、格子中的文字），MonthGrid 月历
    CalendarData      读取 js 数据文件
    LunarData         节气速查表
  WanNianLi/          菜单栏应用
    StatusItemController  菜单栏图标、弹出窗口、键盘控制
    CalendarView          SwiftUI 月历界面
    CalendarViewModel     当前年月、选中日期
    AppMenu               设置菜单、自动启动
    UpdateHolidaysWindow  更新假日信息
    DataStore             数据文件管理
    MoveToApplications    移动到"应用程序"文件夹
  lunar-dump/         导出每日计算结果，用于验证
```
