/// 精选纪念日的日期事实，逐项保留来源。不是完整的联合国国际日清单。
enum MemorialDays {
    private static let un = "https://www.un.org/zh/observances/list-days-weeks"
    static let builtin: [Festival] = [
        Festival("学雷锋纪念日", .solar(month: 3, day: 5), .memorial,
                 sourceURL: "https://www.moj.gov.cn/pub/sfbgw/zwgkztzl/2021nzt/dsxxjy20210506/dszl/dsbk/202105/t20210511_391720.html", firstYear: 1963),
        Festival("建党纪念日", .solar(month: 7, day: 1), .memorial,
                 sourceURL: "https://www.12371.cn/2024/06/28/ARTI1719530432220788.shtml", firstYear: 1941),
        Festival("香港回归纪念日", .solar(month: 7, day: 1), .memorial,
                 sourceURL: "https://www.gov.hk/tc/about/abouthk/holiday/", firstYear: 1997),
        Festival("七七事变纪念日", .solar(month: 7, day: 7), .memorial,
                 sourceURL: "https://dl.mof.gov.cn/lianzhengjianshe/202209/t20220916_3841023.htm", firstYear: 1937),
        Festival("抗日战争胜利纪念日", .solar(month: 9, day: 3), .memorial,
                 sourceURL: "https://www.mod.gov.cn/gfbw/gfjy_index/js_214151/4856045.html", firstYear: 1951),
        Festival("辛亥革命纪念日", .solar(month: 10, day: 10), .memorial,
                 sourceURL: "https://1911museum.cn/view_59.html", firstYear: 1911),
        Festival("消费者权益日", .solar(month: 3, day: 15), .international,
                 sourceURL: "https://www.consumersinternational.org/what-we-do/world-consumer-rights-day", firstYear: 1983),
        Festival("世界红十字日", .solar(month: 5, day: 8), .international,
                 sourceURL: "https://www.ifrc.org/world-red-cross-and-red-crescent-day", firstYear: 1948),
        Festival("世界环境日", .solar(month: 6, day: 5), .international,
                 sourceURL: "https://www.un.org/zh/observances/environment-day", firstYear: 1973),
        Festival("国际禁毒日", .solar(month: 6, day: 26), .international,
                 sourceURL: "https://www.un.org/zh/observances/end-drug-abuse-day", firstYear: 1988),
        Festival("国际和平日", .solar(month: 9, day: 21), .international,
                 sourceURL: "https://www.un.org/zh/observances/international-day-peace", firstYear: 2002),
        Festival("联合国日", .solar(month: 10, day: 24), .international,
                 sourceURL: un, firstYear: 1948),
        Festival("世界艾滋病日", .solar(month: 12, day: 1), .international,
                 sourceURL: "https://www.un.org/zh/observances/world-aids-day", firstYear: 1988),
        Festival("世界人权日", .solar(month: 12, day: 10), .international,
                 sourceURL: "https://www.un.org/zh/observances/human-rights-day", firstYear: 1950),
    ]
}
