# 节日来源与收录范围

“显示节日”决定月历、日期详情和“即将到来”中出现哪些节日。国外公共假日默认关闭，可以同时启用多个日历。
这些日历只添加节日名称，不改变中国的放假、调休和日期颜色规则。

## 分类

| 设置 | 内容与来源 |
| --- | --- |
| 传统节日 | 保留原来的 8 项及其农历规则，不变 |
| 公历节日 | 保留原来的 9 项中国常见公历节日，不变；不是法定休假清单 |
| 常见西方节日（美式日期） | 保留情人节、愚人节、母亲节、父亲节、万圣节、感恩节、平安夜、圣诞节；除愚人节外，日期改由 python-holidays 的美国日历生成；母亲节、父亲节、感恩节按美国日期，不代表英国、法国或德国的习俗日期 |
| 国内纪念日 | 6 项精选纪念日，见下表 |
| 国际纪念日 | 8 项精选纪念日，见下表；不是完整的联合国国际日名录 |
| 国外公共假日 | 英国分英格兰、威尔士、苏格兰、北爱尔兰；美国为联邦假日，法国、德国为全国公共假日；不包含美国各州、德国各州、法国海外地区及其他地区的额外假日，也不包含各国全部民俗节日 |

多个日历在同一天有同名节日时合并显示，详情和“即将到来”注明国家；同名的个人事件仍保留。
补假与节日本日分别显示，例如“美国独立日”和“美国独立日（补假）”。
旧版“西方节日”的显示选择保留。旧版“纪念日”若已隐藏，升级后国内、国际两类都会隐藏，之后可以分别调整。
新增的国家日历默认不选中。

## 第三方国家日历

使用 [python-holidays 0.107](https://github.com/vacanza/holidays/tree/v0.107)，MIT 许可证。
上游的[使用说明](https://holidays.readthedocs.io/)介绍了国家、地区和分类范围。
生成时固定使用 `en_US` 名称，再由本项目维护中文译名；保留上游的历史起始年份、一次性假日与补假。
英国采用指定地区，其他三国采用 `PUBLIC` 全国范围。常见西方节日从美国的 `PUBLIC` 与 `UNOFFICIAL` 类别中仅选择上述 7 项。
愚人节另参考[美国国会图书馆](https://blogs.loc.gov/folklife/2016/03/april-fools/)的 4 月 1 日资料。

快照覆盖应用的 1901–2099 年范围，但不是各国完整的历史日历：上游未提供的历史时期不会自行补造，例如德国全国日历从 1991 年起提供。
未来年份按所固定版本的规则推算，政府之后公布的变化需要重新生成并随应用更新。
国家日历不会通过“更新假日信息”下载，该入口仍只更新中国国务院放假调休安排。

生成结果随应用编译，日常使用不访问第三方服务，也不需要安装 Python。源代码同时保留生成脚本和锁定版本的依赖：

```sh
python3 -m venv /tmp/festival-tools
/tmp/festival-tools/bin/pip install -r scripts/festival-requirements.txt
/tmp/festival-tools/bin/python scripts/generate-festivals.py
/tmp/festival-tools/bin/python scripts/generate-festivals.py --check
```

在 `WanNianLiSwift` 目录下运行。升级依赖时应同时更新生成器版本、来源链接、此说明和快照，审阅日期与译名变化后再提交。
新出现且未翻译的名称会使生成失败，避免把不完整的翻译静默发布。
完整上游版权声明保存在 [holidays-LICENSE.txt](holidays-LICENSE.txt)，构建时一并放入应用的 `Contents/Resources/ThirdPartyNotices/`。

## 国内纪念日

| 日期 | 名称 | 开始显示年份 | 日期资料 |
| --- | --- | --- | --- |
| 3 月 5 日 | 学雷锋纪念日 | 1963 | [司法部：学习雷锋活动](https://www.moj.gov.cn/pub/sfbgw/zwgkztzl/2021nzt/dsxxjy20210506/dszl/dsbk/202105/t20210511_391720.html) |
| 7 月 1 日 | 建党纪念日 | 1941 | [共产党员网：七一纪念活动的由来](https://www.12371.cn/2024/06/28/ARTI1719530432220788.shtml) |
| 7 月 1 日 | 香港回归纪念日 | 1997 | [香港政府：公众假期](https://www.gov.hk/tc/about/abouthk/holiday/) |
| 7 月 7 日 | 七七事变纪念日 | 1937 | [财政部：抗战胜利纪念日的日期沿革](https://dl.mof.gov.cn/lianzhengjianshe/202209/t20220916_3841023.htm) |
| 9 月 3 日 | 抗日战争胜利纪念日 | 1951 | [国防部：抗战胜利纪念日](https://www.mod.gov.cn/gfbw/gfjy_index/js_214151/4856045.html)、[财政部：日期沿革](https://dl.mof.gov.cn/lianzhengjianshe/202209/t20220916_3841023.htm) |
| 10 月 10 日 | 辛亥革命纪念日 | 1911 | [辛亥革命博物院：历史陈列](https://1911museum.cn/view_59.html) |

原来将 8 月 15 日标为“抗日战争胜利”的条目改为 9 月 3 日的胜利纪念日。
“北京奥运会开幕日（2008）”“抗战胜利日假期（2015）”不再混入内置纪念日；历史放假记录仍由调休数据决定。
用户自己的同名事件不改动。导入旧版默认清单时，这些旧内置项仍会跳过，避免再次成为个人事件。

## 国际纪念日

日期采用相关组织发布的事实资料，使用本项目的短中文名称，不复制其整份网页或宣传文案。
开始显示年份用于避免把现代纪念日反向显示到设立之前；不重建更早采用过的其他日期。

| 日期 | 名称 | 开始显示年份 | 日期资料 |
| --- | --- | --- | --- |
| 3 月 15 日 | 消费者权益日 | 1983 | [国际消费者联盟](https://www.consumersinternational.org/what-we-do/world-consumer-rights-day) |
| 5 月 8 日 | 世界红十字日 | 1948 | [红十字会与红新月会国际联合会](https://www.ifrc.org/world-red-cross-and-red-crescent-day) |
| 6 月 5 日 | 世界环境日 | 1973 | [联合国环境日背景](https://www.un.org/en/observances/environment-day/background) |
| 6 月 26 日 | 国际禁毒日 | 1988 | [联合国](https://www.un.org/zh/observances/end-drug-abuse-day) |
| 9 月 21 日 | 国际和平日 | 2002 | [联合国](https://www.un.org/zh/observances/international-day-peace)；2002 年起改用固定日期 |
| 10 月 24 日 | 联合国日 | 1948 | [联合国](https://www.un.org/zh/observances/un-day) |
| 12 月 1 日 | 世界艾滋病日 | 1988 | [联合国](https://www.un.org/zh/observances/world-aids-day) |
| 12 月 10 日 | 世界人权日 | 1950 | [联合国](https://www.un.org/zh/observances/human-rights-day) |
