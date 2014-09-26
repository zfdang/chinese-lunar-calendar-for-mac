(function() {
    window["MzBrowser"] = {};
    (function() {
        if (MzBrowser.platform) return;
        var a = window.navigator.userAgent;
        MzBrowser.platform = window.navigator.platform;
        MzBrowser.firefox = a.indexOf("Firefox") > 0;
        MzBrowser.opera = typeof(window.opera) == "object";
        MzBrowser.ie = !MzBrowser.opera && a.indexOf("MSIE") > 0;
        MzBrowser.mozilla = window.navigator.product == "Gecko";
        MzBrowser.netscape = window.navigator.vendor == "Netscape";
        MzBrowser.safari = a.indexOf("Safari") > -1;
        if (MzBrowser.firefox) var b = /Firefox(\s|\/)(\d+(\.\d+)?)/;
        else if (MzBrowser.ie) var b = /MSIE( )(\d+(\.\d+)?)/;
        else if (MzBrowser.opera) var b = /Opera(\s|\/)(\d+(\.\d+)?)/;
        else if (MzBrowser.netscape) var b = /Netscape(\s|\/)(\d+(\.\d+)?)/;
        else if (MzBrowser.safari) var b = /Version(\/)(\d+(\.\d+)?)/;
        else if (MzBrowser.mozilla) var b = /rv(\:)(\d+(\.\d+)?)/;
        if ("undefined" != typeof(b) && b.test(a)) MzBrowser.version = parseFloat(RegExp.$2)
    })();

    function $(a) {
        return document.getElementById(a)
    }

    function $c(a) {
        return document.createElement(a)
    }
    var P = [19416, 19168, 42352, 21717, 53856, 55632, 91476, 22176, 39632, 21970, 19168, 42422, 42192, 53840, 119381, 46400, 54944, 44450, 38320, 84343, 18800, 42160, 46261, 27216, 27968, 109396, 11104, 38256, 21234, 18800, 25958, 54432, 59984, 28309, 23248, 11104, 100067, 37600, 116951, 51536, 54432, 120998, 46416, 22176, 107956, 9680, 37584, 53938, 43344, 46423, 27808, 46416, 86869, 19872, 42448, 83315, 21200, 43432, 59728, 27296, 44710, 43856, 19296, 43748, 42352, 21088, 62051, 55632, 23383, 22176, 38608, 19925, 19152, 42192, 54484, 53840, 54616, 46400, 46496, 103846, 38320, 18864, 43380, 42160, 45690, 27216, 27968, 44870, 43872, 38256, 19189, 18800, 25776, 29859, 59984, 27480, 21952, 43872, 38613, 37600, 51552, 55636, 54432, 55888, 30034, 22176, 43959, 9680, 37584, 51893, 43344, 46240, 47780, 44368, 21977, 19360, 42416, 86390, 21168, 43312, 31060, 27296, 44368, 23378, 19296, 42726, 42208, 53856, 60005, 54576, 23200, 30371, 38608, 19415, 19152, 42192, 118966, 53840, 54560, 56645, 46496, 22224, 21938, 18864, 42359, 42160, 43600, 111189, 27936, 44448];
    var K = "甲乙丙丁戊己庚辛壬癸";
    var J = "子丑寅卯辰巳午未申酉戌亥";
    var O = "鼠牛虎兔龙蛇马羊猴鸡狗猪";
    var L = ["小寒", "大寒", "立春", "雨水", "惊蛰", "春分", "清明", "谷雨", "立夏", "小满", "芒种", "夏至", "小暑", "大暑", "立秋", "处暑", "白露", "秋分", "寒露", "霜降", "立冬", "小雪", "大雪", "冬至"];
    var D = [0, 21208, 43467, 63836, 85337, 107014, 128867, 150921, 173149, 195551, 218072, 240693, 263343, 285989, 308563, 331033, 353350, 375494, 397447, 419210, 440795, 462224, 483532, 504758];
    var B = "日一二三四五六七八九十";
    var H = ["正", "二", "三", "四", "五", "六", "七", "八", "九", "十", "十一", "腊"];
    var E = "初十廿卅";
    var V = {
        "0101": "*1元旦节",
        "0202": "世界湿地日",
        "0210": "国际气象节",
        "0214": "情人节",
        "0301": "国际海豹日",
        "0303": "全国爱耳日",
        "0305": "学雷锋纪念日",
        "0308": "妇女节",
        "0312": "植树节 孙中山逝世纪念日",
        "0314": "国际警察日",
        "0315": "消费者权益日",
        "0317": "中国国医节 国际航海日",
        "0321": "世界森林日 消除种族歧视国际日 世界儿歌日",
        "0322": "世界水日",
        "0323": "世界气象日",
        "0324": "世界防治结核病日",
        "0325": "全国中小学生安全教育日",
        "0330": "巴勒斯坦国土日",
        "0401": "愚人节 全国爱国卫生运动月(四月) 税收宣传月(四月)",
        "0407": "世界卫生日",
        "0422": "世界地球日",
        "0423": "世界图书和版权日",
        "0424": "亚非新闻工作者日",
        "0501": "*1劳动节",
        "0504": "青年节",
        "0505": "碘缺乏病防治日",
        "0508": "世界红十字日",
        "0512": "国际护士节",
        "0515": "国际家庭日",
        "0517": "国际电信日",
        "0518": "国际博物馆日",
        "0520": "全国学生营养日",
        "0523": "国际牛奶日",
        "0531": "世界无烟日",
        "0601": "国际儿童节",
        "0605": "世界环境保护日",
        "0606": "全国爱眼日",
        "0617": "防治荒漠化和干旱日",
        "0623": "国际奥林匹克日",
        "0625": "全国土地日",
        "0626": "国际禁毒日",
        "0701": "香港回归纪念日 中共诞辰 世界建筑日",
        "0702": "国际体育记者日",
        "0707": "抗日战争纪念日",
        "0711": "世界人口日",
        "0722": "蓉蓉生日",
        "0730": "非洲妇女日",
        "0801": "建军节",
        "0808": "中国男子节(爸爸节)",
        "0815": "抗日战争胜利纪念",
        "0908": "国际扫盲日 国际新闻工作者日",
        "0909": "毛泽东逝世纪念",
        "0910": "中国教师节",
        "0914": "世界清洁地球日",
        "0916": "国际臭氧层保护日",
        "0918": "九·一八事变纪念日",
        "0920": "国际爱牙日",
        "0927": "世界旅游日",
        "0928": "孔子诞辰",
        "1001": "*1国庆节 世界音乐日 国际老人节",
        "1002": "*1国庆节假日 国际和平与民主自由斗争日",
        "1003": "*1国庆节假日",
        "1004": "世界动物日",
        "1006": "老人节",
        "1008": "全国高血压日 世界视觉日",
        "1009": "世界邮政日 万国邮联日",
        "1010": "辛亥革命纪念日 世界精神卫生日",
        "1013": "世界保健日 国际教师节",
        "1014": "世界标准日",
        "1015": "国际盲人节(白手杖节)",
        "1016": "世界粮食日",
        "1017": "世界消除贫困日",
        "1022": "世界传统医药日",
        "1024": "联合国日",
        "1031": "世界勤俭日 万圣节",
        "1107": "十月社会主义革命纪念日",
        "1108": "中国记者日",
        "1109": "全国消防安全宣传教育日",
        "1110": "世界青年节",
        "1111": "国际科学与和平周(本日所属的一周)",
        "1112": "孙中山诞辰纪念日",
        "1114": "世界糖尿病日",
        "1117": "国际大学生节 世界学生节",
        "1120": "彝族年",
        "1121": "彝族年 世界问候日 世界电视日",
        "1122": "彝族年",
        "1129": "国际声援巴勒斯坦人民国际日",
        "1201": "世界艾滋病日",
        "1203": "世界残疾人日",
        "1205": "国际经济和社会发展志愿人员日",
        "1208": "国际儿童电视日",
        "1209": "世界足球日",
        "1210": "世界人权日",
        "1212": "西安事变纪念日",
        "1213": "南京大屠杀(1937年)纪念日！紧记血泪史！",
        "1220": "澳门回归纪念",
        "1221": "国际篮球日",
        "1224": "平安夜",
        "1225": "圣诞节",
        "1226": "毛泽东诞辰纪念"
    };
    var T = {
        "0101": "*2春节",
        "0115": "元宵节",
        "0505": "*1端午节",
        "0707": "情人节",
        "0815": "*1中秋节",
        "0909": "重阳节",
        "1208": "腊八节",
        "0100": "除夕"
    };
    var t = {
        "0109": "国际麻风日",
        "0404": "世界儿童日",
        "0502": "母亲节",
        "0503": "全国助残日",
        "0603": "父亲节",
        "0703": "被奴役国家周",
        "0923": "国际和平日",
        "0904": "国际聋人节",
        "0909": "世界海事日",
        "1011": "国际住房日",
        "1032": "国际减轻自然灾害日(减灾日)",
        "1144": "感恩节"
    };

    function U(Y) {
        function c(j, i) {
            var h = new Date((31556925974.7 * (j - 1900) + D[i] * 60000) + Date.UTC(1900, 0, 6, 2, 5));
            return (h.getUTCDate())
        }

        function d(k) {
            var h, j = 348;
            for (h = 0x8000; h > 8; h >>= 1) {
                j += (P[k - 1900] & h) ? 1 : 0
            }
            return (j + b(k))
        }

        function a(h) {
            return (K.charAt(h % 10) + J.charAt(h % 12))
        }

        function b(h) {
            if (g(h)) {
                return ((P[h - 1900] & 65536) ? 30 : 29)
            } else {
                return (0)
            }
        }

        function g(h) {
            return (P[h - 1900] & 15)
        }

        function e(i, h) {
            return ((P[i - 1900] & (65536 >> h)) ? 30 : 29)
        }

        function C(m) {
            var k, j = 0,
                h = 0;
            var l = new Date(1900, 0, 31);
            var n = (m - l) / 86400000;
            this.dayCyl = n + 40;
            this.monCyl = 14;
            for (k = 1900; k < 2050 && n > 0; k++) {
                h = d(k);
                n -= h;
                this.monCyl += 12
            }
            if (n < 0) {
                n += h;
                k--;
                this.monCyl -= 12
            }
            this.year = k;
            this.yearCyl = k - 1864;
            j = g(k);
            this.isLeap = false;
            for (k = 1; k < 13 && n > 0; k++) {
                if (j > 0 && k == (j + 1) && this.isLeap == false) {
                    --k;
                    this.isLeap = true;
                    h = b(this.year)
                } else {
                    h = e(this.year, k)
                } if (this.isLeap == true && k == (j + 1)) {
                    this.isLeap = false
                }
                n -= h;
                if (this.isLeap == false) {
                    this.monCyl++
                }
            }
            if (n == 0 && j > 0 && k == j + 1) {
                if (this.isLeap) {
                    this.isLeap = false
                } else {
                    this.isLeap = true;
                    --k;
                    --this.monCyl
                }
            }
            if (n < 0) {
                n += h;
                --k;
                --this.monCyl
            }
            this.month = k;
            this.day = n + 1
        }

        function G(h) {
            return h < 10 ? "0" + h : h
        }

        function f(i, j) {
            var h = i;
            return j.replace(/dd?d?d?|MM?M?M?|yy?y?y?/g, function(k) {
                switch (k) {
                    case "yyyy":
                        var l = "000" + h.getFullYear();
                        return l.substring(l.length - 4);
                    case "dd":
                        return G(h.getDate());
                    case "d":
                        return h.getDate().toString();
                    case "MM":
                        return G((h.getMonth() + 1));
                    case "M":
                        return h.getMonth() + 1
                }
            })
        };
        Date.prototype.getLastDay = function(a) {
            _date = new Date(a.valueOf());
            var a = _date.getDate();
            var b = _date.getMonth();
            b == 11 ? function() {
                _date.setYear(_date.getFullYear() + 1);
                _date.setMonth(0)
            } : _date.setMonth(b + 1);
            _date.setDate(0);
            return _date
        };
        Date.prototype.getDays = function() {
            return this.getLastDay(this).getDate()
        };
        Date.prototype.getEndWeek = function(a, b) {
            _date = new Date(a.valueOf());
            _date.setDate(b);
            return _date.getDay()
        };
        Date.prototype.getStartWeek = function() {
            _date = new Date(this.valueOf());
            _date.setDate(1);
            return _date.getDay()
        };

        function Z(i, h) {
            var j;
            switch (i, h) {
                case 10:
                    j = "初十";
                    break;
                case 20:
                    j = "二十";
                    break;
                case 30:
                    j = "三十";
                    break;
                default:
                    j = E.charAt(Math.floor(h / 10));
                    j += B.charAt(h % 10)
            }
            return (j)
        }

        function R(a) {
            return (((a % 4 === 0) && (a % 100 !== 0)) || (a % 400 === 0))
        }

        function getDays(a, b) {
            return [31, (R(a) ? 29 : 28), 31, 30, 31, 30, 31, 31, 30, 31, 30, 31][b]
        }
        this.date = Y;
        this.isToday = false;
        this.isSel = false;
        this.isRestDay = false;
        this.isSolar = false;
        this.solarYear = f(Y, "yyyy");
        this.solarMonth = f(Y, "M");
        this.solarDate = f(Y, "d");
        this.solarWeekDay = Y.getDay();
        this.solarWeekDayInChinese = "星期" + B.charAt(this.solarWeekDay);
        var X = new C(Y);
        this.lunarYear = X.year;
        this.shengxiao = O.charAt((this.lunarYear - 4) % 12);
        this.lunarMonth = X.month;
        this.lunarIsLeapMonth = X.isLeap;
        this.lunarMonthInChinese = this.lunarIsLeapMonth ? "闰" + H[X.month - 1] : H[X.month - 1];
        this.lunarDate = X.day;
        this.showInLunar = this.lunarDateInChinese = Z(this.lunarMonth, this.lunarDate);
        if (this.lunarDate == 1) {
            this.showInLunar = this.lunarMonthInChinese + "月"
        }
        this.ganzhiYear = a(X.yearCyl);
        this.ganzhiMonth = a(X.monCyl);
        this.ganzhiDate = a(X.dayCyl++);
        this.jieqi = "";
        this.restDays = 0;
        var o = new Date(this.date.valueOf());
        var p = Y.getDate();
        var q = Y.getMonth();
        this.allDays = getDays(o.getFullYear(), q);
        this.startWeek = o.getStartWeek();
        this.endWeek = o.getEndWeek(this.date, this.allDays);
        this.seq = Math.floor((this.startWeek + p - 1) / 7);
        this.week = this.date.getDay();
        this.weeks = Math.floor((this.startWeek + this.allDays - 1) / 7);
        var r = (++q).toString().length > 1 ? q.toString() : "0" + q.toString();
        var s = r + this.week + (this.startWeek <= this.week ? this.seq + 1 : this.seq);
        if (c(this.solarYear, (this.solarMonth - 1) * 2) == f(Y, "d")) {
            this.showInLunar = this.jieqi = L[(this.solarMonth - 1) * 2]
        }
        if (c(this.solarYear, (this.solarMonth - 1) * 2 + 1) == f(Y, "d")) {
            this.showInLunar = this.jieqi = L[(this.solarMonth - 1) * 2 + 1]
        }
        if (this.showInLunar == "清明") {
            this.showInLunar = "清明节";
            this.restDays = 1;
            this.isRestDay = true
        }
        this.solarFestival = V[f(Y, "MM") + f(Y, "dd")];
        if (typeof this.solarFestival == "undefined") {
            this.solarFestival = ""
        } else {
            if (/\*(\d)/.test(this.solarFestival)) {
                this.restDays = parseInt(RegExp.$1);
                this.solarFestival = this.solarFestival.replace(/\*\d/, "")
            }
            this.isRestDay = true
        }
        this.showInLunar = (this.solarFestival != "" && this.jieqi == "") ? this.solarFestival : this.showInLunar;
        this.lunarFestival = T[this.lunarIsLeapMonth ? "00" : G(this.lunarMonth) + G(this.lunarDate)];
        if (typeof this.lunarFestival == "undefined") {
            this.lunarFestival = ""
        } else {
            if (/\*(\d)/.test(this.lunarFestival)) {
                this.restDays = (this.restDays > parseInt(RegExp.$1)) ? this.restDays : parseInt(RegExp.$1);
                this.lunarFestival = this.lunarFestival.replace(/\*\d/, "")
            }
            this.isRestDay = true
        } if (this.lunarMonth == 12 && this.lunarDate == e(this.lunarYear, 12)) {
            this.lunarFestival = T["0100"] + " ";
            this.restDays = 1;
            this.isRestDay = true
        }
        if (typeof(t[s]) != "undefined") {
            this.lunarFestival += this.lunarFestival == "" ? "" : " ";
            this.lunarFestival += t[s] + " ";
            this.isRestDay = true
        }
        if (this.seq == this.weeks && typeof(t[s.substr(0, 3) + "9"]) != "undefined") {
            this.lunarFestival += this.lunarFestival == "" ? "" : " ";
            this.lunarFestival += t[s.substr(0, 3) + "9"] + " ";
            this.isRestDay = true
        }
        this.showInLunar = (this.lunarFestival != "" && this.jieqi == "") ? this.lunarFestival : this.showInLunar;
        this.showInLunar = (this.showInLunar.length > 4) ? this.showInLunar.substr(0, 4) + ".." : this.showInLunar
    }
    var Q = (function() {
        var X = {};
        X.lines = 0;
        X.dateArray = new Array(42);

        function Y(a) {
            return (((a % 4 === 0) && (a % 100 !== 0)) || (a % 400 === 0))
        }

        function G(a, b) {
            return [31, (Y(a) ? 29 : 28), 31, 30, 31, 30, 31, 31, 30, 31, 30, 31][b]
        }

        function C(a, b) {
            a.setDate(a.getDate() + b);
            return a
        }

        function Z(a) {
            var f = 0;
            var c = new U(new Date(a.solarYear, a.solarMonth - 1, 1));
            var d = c.solarWeekDay;
            X.lines = Math.ceil((d + G(a.solarYear, a.solarMonth - 1)) / 7);
            for (var e = 0; e < X.dateArray.length; e++) {
                if (c.restDays != 0) {
                    f = c.restDays
                }
                if (f > 0) {
                    c.isRest = true
                }
                if (d-- > 0 || c.solarMonth != a.solarMonth) {
                    X.dateArray[e] = null;
                    continue
                }
                var b = new U(new Date());
                if (c.solarYear == b.solarYear && c.solarMonth == b.solarMonth && c.solarDate == b.solarDate) {
                    c.isToday = true
                }
                if (c.solarYear == selYear.toString() && c.solarMonth == selMonth.toString() && c.solarDate == selDay.toString()) {
                    c.isSel = true
                }
                X.dateArray[e] = c;
                c = new U(C(c.date, 1));
                f--
            }
        }
        return {
            init: function(a) {
                Z(a)
            },
            getJson: function() {
                return X
            }
        }
    })();
    var W = (function() {
        // var G = $("ganzhi");
        var C = $("c_buttom").getElementsByTagName("SELECT")[0];
        var X = $("c_buttom").getElementsByTagName("SELECT")[1];
        var c = $("c_buttom").getElementsByTagName("INPUT")[0];
        var l = $("c_buttom").getElementsByTagName("INPUT")[3];
        var m = $("c_buttom").getElementsByTagName("INPUT")[1];
        var n = $("c_buttom").getElementsByTagName("INPUT")[2];
        var Y = $("c_buttom").getElementsByTagName("INPUT")[4];

        // function a(g) {
        //     _ganzhi = "农历" + g.ganzhiYear + "年" + "【" + g.shengxiao + "】";
        //     G.innerHTML = _ganzhi
        // }

        function b(g) {
            C[g.solarYear - 1901].selected = true;
            X[g.solarMonth - 1].selected = true
        }

        function f() {
            var j = C.value;
            var g = X.value;
            _year = j;
            var i = new U(new Date(j, g - 1, 1));
            Q.init(i);
            N.draw();
            i = new U(new Date(j, 3, 1));
            // _ganzhi = "农历" + i.ganzhiYear + "年" + "【" + i.shengxiao + "】";
            // G.innerHTML = _ganzhi;
            var h = new U(new Date())
        }

        function Z() {
            selYear = selMonth = selDay = 0;
            if (typeof(setTimes) != "undefined") {
                setTimes("init")
            }
            var g = new U(new Date());
            _year = g.solarYear;
            if (typeof(lmanac_2345) != "undefined") {
                lmanac_2345(g.solarMonth < 10 ? "0" + g.solarMonth : g.solarMonth, g.solarDate < 10 ? "0" + g.solarDate : g.solarDate)
            }
            // a(g);
            b(g);
            if (typeof(his_2345) != "undefined") {
                his_2345()
            }
            Q.init(g);
            N.draw()
        }

        function setYears(a) {
            if (a > 2049 || a < 1901) {
                alert("年份已超出范围!");
                return false
            } else {
                _year = a;
                C.value = a;
                C.onchange();
                return true
            }
        }

        function setMonths(a) {
            if (a < 1) {
                if (setYears(parseInt(C.value) - 1)) {
                    setMonths(12)
                }
            } else if (a > 12) {
                if (setYears(parseInt(C.value) + 1)) {
                    setMonths(1)
                }
            } else {
                X.value = a;
                X.onchange()
            }
        }

        function d(k, g) {
            for (var j = 1901; j < 2050; j++) {
                var h = new Option(j, j);
                if (j == k) {
                    h.selected = "selected"
                }
                C.options.add(h)
            }
            for (var j = 1; j < 13; j++) {
                var h = new Option(j, j);
                if (j == g) {
                    h.selected = "selected"
                }
                X.options.add(h)
            }
            C.onchange = f;
            X.onchange = f
        }

        function e(g) {
            d(g.solarYear, g.solarMonth);
            f();
            Y.onclick = Z;
            c.onclick = function() {
                setYears(parseInt(C.value) - 1)
            };
            l.onclick = function() {
                setYears(parseInt(C.value) + 1)
            };
            m.onclick = function() {
                setMonths(parseInt(X.value) - 1)
            };
            n.onclick = function() {
                setMonths(parseInt(X.value) + 1)
            }
        }
        return {
            init: function(g) {
                e(g)
            },
            reset: function(g) {
                b(g)
            }
        }
    })();
    var N = (function() {
        function C() {
            var Z = Q.getJson();
            var c = Z.dateArray;
            $("cm").style.height = Z.lines * 38 + 2 + "px";
            if ($("loading")) {
                $("loading").style.display = "none"
            };
            for (_i = 0; _i < $("cm").childNodes.length; _i++) {
                $("cm").removeChild($("cm").childNodes[_i])
            }
            var e = $("cm").insertRow(-1);
            var g = "日一二三四五六";
            for (_w = 0; _w < g.length; _w++) {
                TD = e.insertCell(-1);
                TD.innerHTML = g.charAt(_w);
                TD.className = (_w < 1 || _w > 5) ? "fred th" : "th"
            }
            for (var a = 0; a < c.length; a += 7) {
                var X = $("cm").insertRow(-1);
                for (var j = a; j < a + 7; j++) {
                    var b = X.insertCell(-1);
                    if (c[j] == null) {
                        continue
                    }
                    var h = '',
                        _classIsRest = '';
                    if (j % 7 > 5 || j % 7 < 1) {
                        h = 'class="fred"'
                    } else if (c[j] && c[j].restDays > 0) {
                        h = 'class="fred"'
                    }
                    if (c[j].jieqi != "") {
                        _classIsRest = 'class="fblue"'
                    } else if (c[j].isRestDay && c[j].restDays > 0) {
                        _classIsRest = 'class="fred"'
                    } else if (c[j].isRestDay) {
                        _classIsRest = 'class="fgreen"'
                    }
                    if (c[j].isToday) {
                        var H = $("lunar_info");
                        F.init(null, H);
                        F.show({
                            dateIndex: j,
                            cell: null
                        }, null, true)
                    }
                    _a = $c("A");
                    _a.setAttribute("date", c[j].solarDate);
                    _a.setAttribute("seq", j);
                    _a.setAttribute("isToday", c[j].isToday);
                    _a.onclick = function(a) {
                        var b = this.getAttribute("seq");
                        selectDay(this.getAttribute("date"), this.getAttribute("isToday"));
                        F.show({
                            dateIndex: b,
                            cell: this
                        }, a, true);
                        this.blur();
                        return false
                    };
                    _a.href = "javascript:void(0)";
                    _a.innerHTML = "<span><font " + h + ">" + c[j].solarDate + "</font></span><font " + _classIsRest + ">" + c[j].showInLunar + "</font>";
                    _a.className = c[j].isSel ? "active" : ((c[j].isToday && selDay == 0) ? "active" : "");
                    b.appendChild(_a);
                    b.onmousemove = (function(d, b) {
                        return function(a, f) {
                            F.show({
                                dateIndex: d,
                                cell: this
                            }, a)
                        }
                    })(j);
                    b.onmousemove = (function(d, b) {
                        return function(a, f) {
                            F.show({
                                dateIndex: d,
                                cell: this
                            }, a)
                        }
                    })(j);
                    b.onmouseout = function() {
                        F.hide()
                    }
                }
            }
            var G = $c("DIV");
            var H = $("lunar_info");
            G.id = "fd";
            $("bm").appendChild(G);
            F.init(G, H)
        }

        function selectDay(a, b) {
            var Z = Q.getJson();
            var c = Z.dateArray;
            var C = $("c_buttom").getElementsByTagName("SELECT")[0];
            var X = $("c_buttom").getElementsByTagName("SELECT")[1];
            var Y = $("c_buttom").getElementsByTagName("INPUT")[4];
            selYear = C.value;
            selMonth = X.value;
            selDay = a;
            if (b == true || b == "true") {
                selYear = selMonth = selDay = 0;
                var g = new U(new Date());
                if (typeof(lmanac_2345) != "undefined") {
                    lmanac_2345(g.solarMonth < 10 ? "0" + g.solarMonth : g.solarMonth, g.solarDate < 10 ? "0" + g.solarDate : g.solarDate)
                }
                if (typeof(setTimes) != "undefined") {
                    setTimes("init")
                }
                F.hide();
                Q.init(g);
                N.draw();
                return true
            }
            F.hide();
            var i = new U(new Date(selYear, selMonth - 1, selDay));
            if (typeof(changeDate) != "undefined") {
                changeDate(selMonth, selDay, i.solarWeekDayInChinese)
            }
            if (typeof(lmanac_2345) != "undefined") {
                lmanac_2345(selMonth < 10 ? "0" + selMonth : selMonth, selDay < 10 ? "0" + selDay : selDay)
            }
            Q.init(i);
            N.draw()
        }
        return {
            draw: function(G) {
                C(G)
            }
        }
    })();
    var F = (function() {
        var C, H;

        function Y(e, c) {
            if (arguments.length > 1) {
                var b = /([.*+?^=!:${}()|[\]\/\\])/g,
                    Z = "{".replace(b, "\\$1"),
                    d = "}".replace(b, "\\$1");
                var a = new RegExp("#" + Z + "([^" + Z + d + "]+)" + d, "g");
                if (typeof(c) == "object") {
                    return e.replace(a, function(f, h) {
                        var g = c[h];
                        return typeof(g) == "undefined" ? "" : g
                    })
                }
            }
            return e
        }

        function G(b, e, d) {
            var a = Q.getJson().dateArray[b.dateIndex];
            var Z = b.cell;
            var c = "#{solarYear}年#{solarMonth}月#{solarDate}日<br />#{solarWeekDayInChinese}";
            c += "<br><b>#{lunarMonthInChinese}月#{lunarDateInChinese}</b>";
            c += "<br>#{ganzhiYear}年 #{ganzhiMonth}月 #{ganzhiDate}日";
            var c1 = "(#{ganzhiYear}年 #{lunarMonthInChinese}月#{lunarDateInChinese})"
            var s = "#{lunarMonthInChinese}月#{lunarDateInChinese}日";
            s += " #{ganzhiYear}年 #{ganzhiMonth}月 #{ganzhiDate}日";
            if (a.solarFestival != "" || a.lunarFestival != "" || a.jieqi != "") {
                c += "<br><b>#{jieqi} #{lunarFestival} #{solarFestival}</b>"
            }
            if (d) {
                if (typeof(his_2345) != "undefined") {
                    his_2345()
                }
                H.innerHTML = Y(c1, a)
            } else {
                C.innerHTML = Y(c, a);
                _event = e || event;
                C.style.top = (_event.clientY + 35 + document.documentElement.scrollTop - document.documentElement.clientTop) + "px";
                C.style.left = (_event.clientX + document.documentElement.scrollLeft - document.documentElement.clientLeft) + "px";
                C.style.width = "120px";
                C.style.textAlign = "center";
                C.style.height = "auto";
                C.style.padding = "5px";
                C.style.display = "block"
            }
        }

        function X() {
            C.style.display = "none"
        }
        return {
            show: function(Z, a) {
                var b = arguments[2] || false;
                G(Z, a, b)
            },
            hide: function() {
                X()
            },
            init: function(Z, K) {
                C = Z, H = K
            }
        }
    })();
    var A = new U(new Date());
    if (MzBrowser.ie) {
        window.attachEvent("onload", function() {
            W.reset(A)
        })
    }
    W.init(A);
    Q.init(A);
    N.draw()
})();