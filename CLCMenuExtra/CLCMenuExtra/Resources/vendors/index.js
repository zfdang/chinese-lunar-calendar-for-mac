var selYear = 0;
var selMonth = 0;
var selDay = 0;
var _handle = 0;
var _handleW = 0;
var _handleL = 0;
var _handleH = 0;
var __handle = 0;
var __offset = 0;
var _weeks = "日一二三四五六";
var _init = false;
var lmanac = new Array();
var astro = new Array();
var his = new Array();
var _now = new Date();
var _year = _now.getFullYear();
var _max = 3;

var cache = {
    "syear": 0,
    "smonth": 0,
    "sday": 0,
    "eyear": 0,
    "emonth": 0,
    "eday": 0,
    "type": "",
    "cond": ""
};
var lang_default = ["选择日期：", "当日黄历：", "年", "月", "日", "星期", "当前日期：", "今日黄历：", "结束日期小于开始日期!", "查询数据应在三个月范围内!", "查询中", "查  询", "全部", "农历：", "宜：", "忌：", "冲：", "煞：", "正冲：", "胎神：", "宜", "忌", "综合运势：", "爱情运势：", "无对应年份黄历数据!", "&nbsp;的日子一共有", "天", "您的浏览器屏蔽了弹窗，无法显示查询结果！\n\n是否在当前窗口显示查询结果?"];

function $(a) {
    return document.getElementById(a)
}

function $c(a) {
    return document.createElement(a)
}

function init() {
    loadJs("calendar");
}

function isLeapYear(a) {
    return (((a % 4 === 0) && (a % 100 !== 0)) || (a % 400 === 0))
}

function monthDay(a, b) {
    return [31, (isLeapYear(a) ? 29 : 28), 31, 30, 31, 30, 31, 31, 30, 31, 30, 31][b]
}

function $d(a) {
    return typeof(a) != "undefined"
}

function setClock() {
    if (_handle == 0) {
        setTimes("init");
    } else {
        clearInterval(_handle);
    }
    _handle = setInterval(setTimes, 1000);
}

function changeDate(a, b, c) {
    var d = _year + lang_default[2] + a + lang_default[3] + b + lang_default[4];
    // 初始化之后，更新阳历
    $("date").innerHTML = d
}

function setTimes() {
    _now = new Date();
    var d = _now.getHours();
    var e = _now.getMinutes() < 10 ? "0" + _now.getMinutes() : _now.getMinutes();
    var f = _now.getSeconds() < 10 ? "0" + _now.getSeconds() : _now.getSeconds();
    var h = d + ":" + e + ":" + f;
    $("nowTime").innerHTML = h;
}

function loadJs(a) {
    _timeout = arguments[1] || 0;
    _id = a.replace(/\//gi, "_");
    if (typeof($) != "undefined" && !$(_id)) {
        var b = document.createElement("script");
        b.setAttribute("type", "text/javascript");
        b.setAttribute("id", _id);
        b.setAttribute("src", a + ".js" + (_timeout ? "?" + _timeout : ""));
        document.body.insertBefore(b, null);
        return true
    }
    return false
}
