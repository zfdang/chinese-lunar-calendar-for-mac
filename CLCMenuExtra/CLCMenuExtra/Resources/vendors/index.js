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
// var _hisUrl = "/tools/his.htm";
// var _astroUrl = "http://astro.sina.com.cn/pc/west/frame0_";
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
// var dir = ["/his_short/", "/lmanac/", "http://tianqi.2345.com/astro/"];
// var _width = ["12%", "7%", "12%"];
// var lmanac_len = [18, 10, 10, 10];

function $(a) {
    return document.getElementById(a)
}

function $c(a) {
    return document.createElement(a)
}

function init() {
    // var a = _now.getMonth() + 1;
    // var b = _now.getDate() + 1;
    // loadJs(dir[0] + (a < 10 ? "0" + a : a) + (b < 10 ? "0" + b - 1 : b - 1));
    // loadJs(dir[1] + _year);
    loadJs("calendar");
    // var c = "s_";
    // var d = "e_";
    // _year = _now.getFullYear();
    // a = _now.getMonth() + 1;
    // b = _now.getDate();
    // var e = a != 12 || _year == 2011 ? _year : _year + 1;
    // var f = _year == 2011 ? (a < 12 ? (a + 1) % 12 : a) : (a + 1) % 12;
    // $(c + "year").value = _year;
    // $(d + "year").value = e;
    // $(c + "month").value = a;
    // $(d + "month").value = f;
    // changeMonthDay(0);
    // changeMonthDay(1);
    // var g = b;
    // var h = monthDay(_year, a - 1);
    // var i = monthDay(e, f - 1);
    // $(c + "day").value = parseInt(g, 10) > h ? h : g;
    // $(d + "day").value = parseInt(g, 10) > i ? i : g
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
    // if (arguments[0] == "init") {
    //     // 点击“今日”时，一次性设置阳历
    //     var a = _now.getFullYear();
    //     var b = _now.getMonth() + 1;
    //     var c = _now.getDate();
    //     var g = a + lang_default[2] + b + lang_default[3] + c + lang_default[4];
    //     // var i = g + "&nbsp;" + lang_default[5] + _weeks.charAt(_now.getDay());
    //     // var j = lang_default[6] + '<font class="fred"><b>';
    //     // j += i;
    //     // j += '</b></font><br />';
    //     // $("lm_txt").innerHTML = lang_default[7];
    //     $("date").innerHTML = g;
    // }
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

// function changeAstro() {
//     _v = $("astro").value;
//     _cache = _now.getMonth() + 1 + "_" + _now.getDate() + "_" + (_now.getHours() > 3 ? 1 : 0);
//     if (!loadJs(dir[2] + _v, _cache)) {
//         astro_2345(_v)
//     }
//     $("astroUrl").href = _astroUrl + _v + ".html"
// }

// function his_2345() {
//     var a = 1;
//     var b = "";
//     var c = selYear > 0 ? selMonth : (_now.getMonth() + 1);
//     var d = selYear > 0 ? selDay : _now.getDate();
//     c = c < 10 ? "0" + c : c.toString();
//     d = d < 10 ? "0" + d : d.toString();
//     if (loadJs(dir[0] + c + d)) {
//         return false
//     }
//     for (j in his[c + d]) {
//         if (a > _max) {
//             break
//         }
//         b += '<a target="_blank" href="' + _hisUrl + "?" + c + d + '">' + a + ") ";
//         b += j + lang_default[2] + c + lang_default[3] + d + lang_default[4] + ":";
//         b += his[c + d][j].title + "</a><br />\n";
//         a++
//     }
//     $("hisToday").innerHTML = b;
//     return true
// }

// function astro_2345(a) {
//     if (!astro[a]) {
//         return false
//     }
//     _z = lang_default[22];
//     _a = lang_default[23];
//     for (_i = 0; _i < 5; _i++) {
//         _z += astro[a].z > _i ? '<img src="img/star.gif"/>' : '<img src="img/star0.gif"/>';
//         _a += astro[a].a > _i ? '<img src="img/star.gif"/>' : '<img src="img/star0.gif"/>'
//     }
//     $("astro_z").innerHTML = _z;
//     $("astro_a").innerHTML = _a
// }

// function getLmanac() {
//     _type = $('lmanacLuck').checked ? "y" : "j";
//     _cond = $("lmanacCond").value;
//     _sPre = "s_";
//     _ePre = "e_";
//     _sYear = parseInt($(_sPre + "year").value);
//     _eYear = parseInt($(_ePre + "year").value);
//     _sMonth = parseInt($(_sPre + "month").value);
//     _eMonth = parseInt($(_ePre + "month").value);
//     _sDay = parseInt($(_sPre + "day").value);
//     _eDay = parseInt($(_ePre + "day").value);
//     if ((_eYear < _sYear) || (_sYear == _eYear && _eMonth < _sMonth) || (_sYear == _eYear && _eMonth == _sMonth && _eDay < _sDay)) {
//         alert(lang_default[8]);
//         return false
//     }
//     _sDate = new Date(_sYear, _sMonth - 1, _sDay);
//     _eDate = new Date(_eYear, _eMonth - 1, _eDay);
//     if (_eDate - _sDate > 1000 * 60 * 60 * 24 * 91) {
//         alert(lang_default[9]);
//         return false
//     }
//     $("query").value = lang_default[10];
//     $("query").blur();
//     $("query").disabled = true;
//     __handle = setTimeout(callback, 50);

//     function callback() {
//         _url = "lmanac.htm?t=" + _type + "&c=" + escape(_cond) + "&sy=" + _sYear + "&ey=" + _eYear + "&sm=" + _sMonth + "&em=" + _eMonth + "&sd=" + _sDay + "&ed=" + _eDay;
//         var a = window.open(_url, "_blank");
//         if (!a) {
//             if (confirm(lang_default[27])) {
//                 location.href = _url
//             }
//         }
//         setTimeout(function() {
//             $("query").disabled = false;
//             $("query").value = lang_default[11]
//         }, 300)
//     }
//     return true
// }

// function lmanac_2345() {
//     if (_init && !arguments[0]) return;
//     var a = (_now.getMonth() + 1) < 10 ? "0" + (_now.getMonth() + 1) : _now.getMonth() + 1;
//     var b = _now.getDate() < 10 ? "0" + _now.getDate() : _now.getDate();
//     var c = "";
//     a = arguments[0] || a;
//     b = arguments[1] || b;
//     var d = "d" + a + b;
//     if (!lmanac[_year] && $("_lmanac_" + _year)) {
//         $("luck").innerHTML = lang_default[24];
//         $("bad").innerHTML = lang_default[24];
//         $("ch").innerHTML = lang_default[24];
//         $("s").innerHTML = lang_default[24];
//         return false
//     } else if (!lmanac[_year]) {
//         loadJs(dir[1] + _year);
//         _handleL = setTimeout(function() {
//             lmanac_2345(a, b)
//         }, 500);
//         return false
//     }
//     $("luck").innerHTML = "";
//     $("bad").innerHTML = "";
//     $("ch").innerHTML = "";
//     $("s").innerHTML = "";
//     for (_d in lmanac[_year][d]) {
//         switch (_d.toLowerCase()) {
//             case "y":
//                 var e = lmanac[_year][d].y.split(".");
//                 var f = "";
//                 for (_k = 0; _k < e.length - 1 && _k < lmanac_len[0]; _k++) {
//                     f += e[_k] + ","
//                 }
//                 f = f.substr(0, f.length - 1);
//                 $("luck").innerHTML = f;
//                 break;
//             case "j":
//                 var g = lmanac[_year][d].j.split(".");
//                 var f = "";
//                 for (_k = 0; _k < g.length - 1 && _k < lmanac_len[1]; _k++) {
//                     f += g[_k] + ","
//                 }
//                 f = f.substr(0, f.length - 1);
//                 $("bad").innerHTML = f;
//                 break;
//             case "c":
//                 var h = lmanac[_year][d].c.split(".");
//                 var f = "";
//                 for (_l = 0; _l < h.length && _l < lmanac_len[2]; _l++) {
//                     f += h[_l] + ","
//                 }
//                 f = f.substr(0, f.length - 1);
//                 $("ch").innerHTML = f;
//                 break;
//             case "s":
//                 var i = lmanac[_year][d].s.split(".");
//                 var f = "";
//                 for (_m = 0; _m < i.length && _m < lmanac_len[3]; _m++) {
//                     f += i[_m] + ","
//                 }
//                 f = f.substr(0, f.length - 1);
//                 $("s").innerHTML = f;
//                 break;
//             default:
//                 _init = true;
//                 break
//         }
//     }
// }

// function insertHead(a, b, c) {
//     a.style.display = "block";
//     a.innerHTML = '<font class="fred" id="cond">' + b + '</font>' + lang_default[25] + '<b id="count">' + c + '</b>' + lang_default[26];
//     return true
// }

// function clearTable(a) {
//     for (_i = a.childNodes.length - 1; _i > -1; _i--) {
//         a.removeChild(a.childNodes[_i])
//     }
//     return true
// }