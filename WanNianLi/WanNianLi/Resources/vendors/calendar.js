(function() {
    function $(a) {
        return document.getElementById(a)
    }

    function $c(a) {
        return document.createElement(a)
    }

    // 公历年对应的农历数据,每年5字节, 下面对bits的解释不一定正确
    // 格式第一字节BIT7-4 位表示闰月月份,值为0 为无闰月,BIT3-0 对应农历第1-4 月的大小
    // 第二字节BIT7-0 对应农历第5-12 月大小,
    // 第三字节BIT7 表示农历第13 个月大小 月份对应的位为1 表示本农历月大(30 天),为0 表示小(29 天)
    // 第三字节BIT6-5 表示春节的公历月份,BIT4-0 表示春节的公历日期
    var P = new Array(
    0x04bd8,0x04ae0,0x0a570,0x054d5,0x0d260,0x0d950,0x16554,0x056a0,0x09ad0,0x055d2,
    0x04ae0,0x0a5b6,0x0a4d0,0x0d250,0x1d255,0x0b540,0x0d6a0,0x0ada2,0x095b0,0x14977,
    0x04970,0x0a4b0,0x0b4b5,0x06a50,0x06d40,0x1ab54,0x02b60,0x09570,0x052f2,0x04970,
    0x06566,0x0d4a0,0x0ea50,0x06e95,0x05ad0,0x02b60,0x186e3,0x092e0,0x1c8d7,0x0c950,
    0x0d4a0,0x1d8a6,0x0b550,0x056a0,0x1a5b4,0x025d0,0x092d0,0x0d2b2,0x0a950,0x0b557,
    0x06ca0,0x0b550,0x15355,0x04da0,0x0a5d0,0x14573,0x052d0,0x0a9a8,0x0e950,0x06aa0,
    0x0aea6,0x0ab50,0x04b60,0x0aae4,0x0a570,0x05260,0x0f263,0x0d950,0x05b57,0x056a0,
    0x096d0,0x04dd5,0x04ad0,0x0a4d0,0x0d4d4,0x0d250,0x0d558,0x0b540,0x0b5a0,0x195a6,
    0x095b0,0x049b0,0x0a974,0x0a4b0,0x0b27a,0x06a50,0x06d40,0x0af46,0x0ab60,0x09570,
    0x04af5,0x04970,0x064b0,0x074a3,0x0ea50,0x06b58,0x055c0,0x0ab60,0x096d5,0x092e0,
    0x0c960,0x0d954,0x0d4a0,0x0da50,0x07552,0x056a0,0x0abb7,0x025d0,0x092d0,0x0cab5,
    0x0a950,0x0b4a0,0x0baa4,0x0ad50,0x055d9,0x04ba0,0x0a5b0,0x15176,0x052b0,0x0a930,
    0x07954,0x06aa0,0x0ad50,0x05b52,0x04b60,0x0a6e6,0x0a4e0,0x0d260,0x0ea65,0x0d530,
    0x05aa0,0x076a3,0x096d0,0x04bd7,0x04ad0,0x0a4d0,0x1d0b6,0x0d250,0x0d520,0x0dd45,
    0x0b5a0,0x056d0,0x055b2,0x049b0,0x0a577,0x0a4b0,0x0aa50,0x1b255,0x06d20,0x0ada0);

    var TIANGAN = "甲乙丙丁戊己庚辛壬癸";
    var DIZHI = "子丑寅卯辰巳午未申酉戌亥";
    var SHENGXIAO = "鼠牛虎兔龙蛇马羊猴鸡狗猪";
    var WEEKDAY = "日一二三四五六七八九十";
    var LUNARMONTH = ["正", "二", "三", "四", "五", "六", "七", "八", "九", "十", "十一", "腊"];
    var LUNARDAY = "初十廿卅";

    /**
      * 1900-2100各年的24节气日期速查表
      * @Array Of Property 
      * @return 0x string For splice
      */
      // http://www.jjonline.cn/Public/Js/calendar.js
    var JIEQI = ["小寒", "大寒", "立春", "雨水", "惊蛰", "春分", "清明", "谷雨", "立夏", "小满", "芒种", "夏至", "小暑", "大暑", "立秋", "处暑", "白露", "秋分", "寒露", "霜降", "立冬", "小雪", "大雪", "冬至"];
    var sTermInfo = ['9778397bd097c36b0b6fc9274c91aa','97b6b97bd19801ec9210c965cc920e','97bcf97c3598082c95f8c965cc920f',
              '97bd0b06bdb0722c965ce1cfcc920f','b027097bd097c36b0b6fc9274c91aa','97b6b97bd19801ec9210c965cc920e',
              '97bcf97c359801ec95f8c965cc920f','97bd0b06bdb0722c965ce1cfcc920f','b027097bd097c36b0b6fc9274c91aa',
              '97b6b97bd19801ec9210c965cc920e','97bcf97c359801ec95f8c965cc920f','97bd0b06bdb0722c965ce1cfcc920f',
              'b027097bd097c36b0b6fc9274c91aa','9778397bd19801ec9210c965cc920e','97b6b97bd19801ec95f8c965cc920f',
              '97bd09801d98082c95f8e1cfcc920f','97bd097bd097c36b0b6fc9210c8dc2','9778397bd197c36c9210c9274c91aa',
              '97b6b97bd19801ec95f8c965cc920e','97bd09801d98082c95f8e1cfcc920f','97bd097bd097c36b0b6fc9210c8dc2',
              '9778397bd097c36c9210c9274c91aa','97b6b97bd19801ec95f8c965cc920e','97bcf97c3598082c95f8e1cfcc920f',
              '97bd097bd097c36b0b6fc9210c8dc2','9778397bd097c36c9210c9274c91aa','97b6b97bd19801ec9210c965cc920e',
              '97bcf97c3598082c95f8c965cc920f','97bd097bd097c35b0b6fc920fb0722','9778397bd097c36b0b6fc9274c91aa',
              '97b6b97bd19801ec9210c965cc920e','97bcf97c3598082c95f8c965cc920f','97bd097bd097c35b0b6fc920fb0722',
              '9778397bd097c36b0b6fc9274c91aa','97b6b97bd19801ec9210c965cc920e','97bcf97c359801ec95f8c965cc920f',
              '97bd097bd097c35b0b6fc920fb0722','9778397bd097c36b0b6fc9274c91aa','97b6b97bd19801ec9210c965cc920e',
              '97bcf97c359801ec95f8c965cc920f','97bd097bd097c35b0b6fc920fb0722','9778397bd097c36b0b6fc9274c91aa',
              '97b6b97bd19801ec9210c965cc920e','97bcf97c359801ec95f8c965cc920f','97bd097bd07f595b0b6fc920fb0722',
              '9778397bd097c36b0b6fc9210c8dc2','9778397bd19801ec9210c9274c920e','97b6b97bd19801ec95f8c965cc920f',
              '97bd07f5307f595b0b0bc920fb0722','7f0e397bd097c36b0b6fc9210c8dc2','9778397bd097c36c9210c9274c920e',
              '97b6b97bd19801ec95f8c965cc920f','97bd07f5307f595b0b0bc920fb0722','7f0e397bd097c36b0b6fc9210c8dc2',
              '9778397bd097c36c9210c9274c91aa','97b6b97bd19801ec9210c965cc920e','97bd07f1487f595b0b0bc920fb0722',
              '7f0e397bd097c36b0b6fc9210c8dc2','9778397bd097c36b0b6fc9274c91aa','97b6b97bd19801ec9210c965cc920e',
              '97bcf7f1487f595b0b0bb0b6fb0722','7f0e397bd097c35b0b6fc920fb0722','9778397bd097c36b0b6fc9274c91aa',
              '97b6b97bd19801ec9210c965cc920e','97bcf7f1487f595b0b0bb0b6fb0722','7f0e397bd097c35b0b6fc920fb0722',
              '9778397bd097c36b0b6fc9274c91aa','97b6b97bd19801ec9210c965cc920e','97bcf7f1487f531b0b0bb0b6fb0722',
              '7f0e397bd097c35b0b6fc920fb0722','9778397bd097c36b0b6fc9274c91aa','97b6b97bd19801ec9210c965cc920e',
              '97bcf7f1487f531b0b0bb0b6fb0722','7f0e397bd07f595b0b6fc920fb0722','9778397bd097c36b0b6fc9274c91aa',
              '97b6b97bd19801ec9210c9274c920e','97bcf7f0e47f531b0b0bb0b6fb0722','7f0e397bd07f595b0b0bc920fb0722',
              '9778397bd097c36b0b6fc9210c91aa','97b6b97bd197c36c9210c9274c920e','97bcf7f0e47f531b0b0bb0b6fb0722',
              '7f0e397bd07f595b0b0bc920fb0722','9778397bd097c36b0b6fc9210c8dc2','9778397bd097c36c9210c9274c920e',
              '97b6b7f0e47f531b0723b0b6fb0722','7f0e37f5307f595b0b0bc920fb0722','7f0e397bd097c36b0b6fc9210c8dc2',
              '9778397bd097c36b0b70c9274c91aa','97b6b7f0e47f531b0723b0b6fb0721','7f0e37f1487f595b0b0bb0b6fb0722',
              '7f0e397bd097c35b0b6fc9210c8dc2','9778397bd097c36b0b6fc9274c91aa','97b6b7f0e47f531b0723b0b6fb0721',
              '7f0e27f1487f595b0b0bb0b6fb0722','7f0e397bd097c35b0b6fc920fb0722','9778397bd097c36b0b6fc9274c91aa',
              '97b6b7f0e47f531b0723b0b6fb0721','7f0e27f1487f531b0b0bb0b6fb0722','7f0e397bd097c35b0b6fc920fb0722',
              '9778397bd097c36b0b6fc9274c91aa','97b6b7f0e47f531b0723b0b6fb0721','7f0e27f1487f531b0b0bb0b6fb0722',
              '7f0e397bd097c35b0b6fc920fb0722','9778397bd097c36b0b6fc9274c91aa','97b6b7f0e47f531b0723b0b6fb0721',
              '7f0e27f1487f531b0b0bb0b6fb0722','7f0e397bd07f595b0b0bc920fb0722','9778397bd097c36b0b6fc9274c91aa',
              '97b6b7f0e47f531b0723b0787b0721','7f0e27f0e47f531b0b0bb0b6fb0722','7f0e397bd07f595b0b0bc920fb0722',
              '9778397bd097c36b0b6fc9210c91aa','97b6b7f0e47f149b0723b0787b0721','7f0e27f0e47f531b0723b0b6fb0722',
              '7f0e397bd07f595b0b0bc920fb0722','9778397bd097c36b0b6fc9210c8dc2','977837f0e37f149b0723b0787b0721',
              '7f07e7f0e47f531b0723b0b6fb0722','7f0e37f5307f595b0b0bc920fb0722','7f0e397bd097c35b0b6fc9210c8dc2',
              '977837f0e37f14998082b0787b0721','7f07e7f0e47f531b0723b0b6fb0721','7f0e37f1487f595b0b0bb0b6fb0722',
              '7f0e397bd097c35b0b6fc9210c8dc2','977837f0e37f14998082b0787b06bd','7f07e7f0e47f531b0723b0b6fb0721',
              '7f0e27f1487f531b0b0bb0b6fb0722','7f0e397bd097c35b0b6fc920fb0722','977837f0e37f14998082b0787b06bd',
              '7f07e7f0e47f531b0723b0b6fb0721','7f0e27f1487f531b0b0bb0b6fb0722','7f0e397bd097c35b0b6fc920fb0722',
              '977837f0e37f14998082b0787b06bd','7f07e7f0e47f531b0723b0b6fb0721','7f0e27f1487f531b0b0bb0b6fb0722',
              '7f0e397bd07f595b0b0bc920fb0722','977837f0e37f14998082b0787b06bd','7f07e7f0e47f531b0723b0b6fb0721',
              '7f0e27f1487f531b0b0bb0b6fb0722','7f0e397bd07f595b0b0bc920fb0722','977837f0e37f14998082b0787b06bd',
              '7f07e7f0e47f149b0723b0787b0721','7f0e27f0e47f531b0b0bb0b6fb0722','7f0e397bd07f595b0b0bc920fb0722',
              '977837f0e37f14998082b0723b06bd','7f07e7f0e37f149b0723b0787b0721','7f0e27f0e47f531b0723b0b6fb0722',
              '7f0e397bd07f595b0b0bc920fb0722','977837f0e37f14898082b0723b02d5','7ec967f0e37f14998082b0787b0721',
              '7f07e7f0e47f531b0723b0b6fb0722','7f0e37f1487f595b0b0bb0b6fb0722','7f0e37f0e37f14898082b0723b02d5',
              '7ec967f0e37f14998082b0787b0721','7f07e7f0e47f531b0723b0b6fb0722','7f0e37f1487f531b0b0bb0b6fb0722',
              '7f0e37f0e37f14898082b0723b02d5','7ec967f0e37f14998082b0787b06bd','7f07e7f0e47f531b0723b0b6fb0721',
              '7f0e37f1487f531b0b0bb0b6fb0722','7f0e37f0e37f14898082b072297c35','7ec967f0e37f14998082b0787b06bd',
              '7f07e7f0e47f531b0723b0b6fb0721','7f0e27f1487f531b0b0bb0b6fb0722','7f0e37f0e37f14898082b072297c35',
              '7ec967f0e37f14998082b0787b06bd','7f07e7f0e47f531b0723b0b6fb0721','7f0e27f1487f531b0b0bb0b6fb0722',
              '7f0e37f0e366aa89801eb072297c35','7ec967f0e37f14998082b0787b06bd','7f07e7f0e47f149b0723b0787b0721',
              '7f0e27f1487f531b0b0bb0b6fb0722','7f0e37f0e366aa89801eb072297c35','7ec967f0e37f14998082b0723b06bd',
              '7f07e7f0e47f149b0723b0787b0721','7f0e27f0e47f531b0723b0b6fb0722','7f0e37f0e366aa89801eb072297c35',
              '7ec967f0e37f14998082b0723b06bd','7f07e7f0e37f14998083b0787b0721','7f0e27f0e47f531b0723b0b6fb0722',
              '7f0e37f0e366aa89801eb072297c35','7ec967f0e37f14898082b0723b02d5','7f07e7f0e37f14998082b0787b0721',
              '7f07e7f0e47f531b0723b0b6fb0722','7f0e36665b66aa89801e9808297c35','665f67f0e37f14898082b0723b02d5',
              '7ec967f0e37f14998082b0787b0721','7f07e7f0e47f531b0723b0b6fb0722','7f0e36665b66a449801e9808297c35',
              '665f67f0e37f14898082b0723b02d5','7ec967f0e37f14998082b0787b06bd','7f07e7f0e47f531b0723b0b6fb0721',
              '7f0e36665b66a449801e9808297c35','665f67f0e37f14898082b072297c35','7ec967f0e37f14998082b0787b06bd',
              '7f07e7f0e47f531b0723b0b6fb0721','7f0e26665b66a449801e9808297c35','665f67f0e37f1489801eb072297c35',
              '7ec967f0e37f14998082b0787b06bd','7f07e7f0e47f531b0723b0b6fb0721','7f0e27f1487f531b0b0bb0b6fb0722'];
 
    // SOLARFESTIVAL, LUNARFESTIVAL, OTHERFESTIVAL 在festivals.js中定义
    // HOLIDAYADJUSTMENT在holidays.js中定义

    // Y 为当前的日期
    function Calendar(Y) {

        /**
         * 传入公历y年获得该年第n个节气的公历日期
         * @param y 公历年(1900-2100)；n二十四节气中的第几个节气(1~24)；从n=1(小寒)算起 
         * @return day Number
         * @eg:var _24 = calendar.getTerm(1987,3) ;//_24=4;意即1987年2月4日立春
         */
        function getSolarTerm(y, n) {
            if (y < 1900 || y > 2100) {
                return -1;
            }
            if (n < 1 || n > 24) {
                return -1;
            }
            var _table = sTermInfo[y - 1900];
            var _info = [
                parseInt('0x' + _table.substr(0, 5)).toString(),
                parseInt('0x' + _table.substr(5, 5)).toString(),
                parseInt('0x' + _table.substr(10, 5)).toString(),
                parseInt('0x' + _table.substr(15, 5)).toString(),
                parseInt('0x' + _table.substr(20, 5)).toString(),
                parseInt('0x' + _table.substr(25, 5)).toString()
            ];
            var _calday = [
                _info[0].substr(0, 1),
                _info[0].substr(1, 2),
                _info[0].substr(3, 1),
                _info[0].substr(4, 2),

                _info[1].substr(0, 1),
                _info[1].substr(1, 2),
                _info[1].substr(3, 1),
                _info[1].substr(4, 2),

                _info[2].substr(0, 1),
                _info[2].substr(1, 2),
                _info[2].substr(3, 1),
                _info[2].substr(4, 2),

                _info[3].substr(0, 1),
                _info[3].substr(1, 2),
                _info[3].substr(3, 1),
                _info[3].substr(4, 2),

                _info[4].substr(0, 1),
                _info[4].substr(1, 2),
                _info[4].substr(3, 1),
                _info[4].substr(4, 2),

                _info[5].substr(0, 1),
                _info[5].substr(1, 2),
                _info[5].substr(3, 1),
                _info[5].substr(4, 2),
            ];
            return parseInt(_calday[n - 1]);
        }

        // 传回农历y年的总天数
        function d(y) {
            var h, j = 348;
            for (h = 0x8000; h > 0x8; h >>= 1) {
                j += (P[y - 1900] & h) ? 1 : 0
            }
            return (j + b(y))
        }

        // 传回农历y年闰月的天数
        function b(y) {
            if (g(y)) {
                return ((P[y - 1900] & 0x10000) ? 30 : 29)
            } else {
                return (0)
            }
        }

        // 传回农历y年闰哪个月 1-12, 没闰传回 0
        function g(y) {
            return (P[y - 1900] & 0xf)
        }

        // 传回农历y年m月的总天数
        function e(y, m) {
            return ((P[y - 1900] & (0x10000 >> m)) ? 30 : 29)
        }

        function a(h) {
            return (TIANGAN.charAt(h % 10) + DIZHI.charAt(h % 12))
        }

        // 算出农历
        function C(m) {
            var k, j = 0,
                h = 0;
            // var l = new Date(1900, 0, 31);
            var startDate = new Date(Date.UTC(1900, 0, 31));
            var newDate = new Date(Date.UTC(m.getFullYear(), m.getMonth(), m.getDate()));
            var n = (newDate - startDate) / 86400000;
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
            j = g(k); //闰哪个月
            this.isLeap = false;
            for (k = 1; k < 13 && n > 0; k++) {
                if (j > 0 && k == (j + 1) && this.isLeap == false) {
                    --k;
                    this.isLeap = true;
                    h = b(this.year)
                } else {
                    h = e(this.year, k)
                }
                if (this.isLeap == true && k == (j + 1)) {
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
            return h < 10 ? "0" + h : "" + h
        }

        // get date digit by specific format
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
                    j = LUNARDAY.charAt(Math.floor(h / 10));
                    j += WEEKDAY.charAt(h % 10)
            }
            return (j)
        }

        function R(a) {
            return (((a % 4 === 0) && (a % 100 !== 0)) || (a % 400 === 0))
        }

        function getDays(iYear, iMonth) {
            return [31, (R(iYear) ? 29 : 28), 31, 30, 31, 30, 31, 31, 30, 31, 30, 31][iMonth]
        }

        function getShortString(input) {
            // limit to 6 pure english char, or 4 pure chinese char
            // mixed chinese & english are considered as all chinese
            // "123456" => "123456"
            // "123456789" => "123456.."
            // "中文显示" => "中文显示"
            // "中文显示测试" => "中文显示.."
            var maxLength = 4;
            if(escape(input).indexOf("%u") < 0) {
                // no chinese char, set max to 6
                maxLength = 6;
            }

            if(input.length <= maxLength) {
                return input;
            } else {
                return input.substr(0, maxLength) + "..";
            }
        }

        this.date = Y;
        this.isToday = false;
        this.isSel = false;
        this.isCurrentMonth = false;
        this.isSolar = false;
        this.solarYear = f(Y, "yyyy");
        this.solarMonth = f(Y, "M");
        this.solarDate = f(Y, "d");
        this.solarWeekDay = Y.getDay();
        this.solarWeekDayInChinese = "星期" + WEEKDAY.charAt(this.solarWeekDay);
        var X = new C(Y);
        this.lunarYear = X.year;
        this.shengxiao = SHENGXIAO.charAt((this.lunarYear - 4) % 12);
        this.lunarMonth = X.month;
        this.lunarIsLeapMonth = X.isLeap;
        this.lunarMonthInChinese = this.lunarIsLeapMonth ? "闰" + LUNARMONTH[X.month - 1] : LUNARMONTH[X.month - 1];
        this.lunarDate = X.day;
        this.lunarDateInChinese = Z(this.lunarMonth, this.lunarDate);
        this.ganzhiYear = a(X.yearCyl);
        this.ganzhiMonth = a(X.monCyl);
        this.ganzhiDate = a(X.dayCyl++);
        this.jieqi = "";
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

        // 计算节气，每个月有2个节气
        if (getSolarTerm(this.solarYear, (this.solarMonth - 1) * 2 + 1) == f(Y, "d")) {
            this.jieqi = JIEQI[(this.solarMonth - 1) * 2]
        }
        if (getSolarTerm(this.solarYear, (this.solarMonth - 1) * 2  +  2) == f(Y, "d")) {
            this.jieqi = JIEQI[(this.solarMonth - 1) * 2 + 1]
        }

        // 当天有没有特殊事件, 在events.js中定义
        this.specialEvent = SPECIFIC_EVENTS[f(Y, "yyyy") + f(Y, "MM") + f(Y, "dd")];
        if (typeof this.specialEvent == "undefined") {
            this.specialEvent = ""
        }

        // 计算阳历的节日
        this.solarFestival = SOLARFESTIVAL[f(Y, "MM") + f(Y, "dd")];
        if (typeof this.solarFestival == "undefined") {
            this.solarFestival = ""
        }

        // 农历的节日
        this.lunarFestival = LUNARFESTIVAL[this.lunarIsLeapMonth ? "00" : G(this.lunarMonth) + G(this.lunarDate)];
        if (typeof this.lunarFestival == "undefined") {
            this.lunarFestival = ""
        }
        // 除夕，最后一天
        if (this.lunarMonth == 12 && this.lunarDate == e(this.lunarYear, 12)) {
            this.lunarFestival = LUNARFESTIVAL["0100"];
        }

        // 按照第几个周几类约定的节日, 没有单独的变量，放到了农历日期的后面
        if (typeof(OTHERFESTIVAL[s]) != "undefined") {
            // “第几个周几”形式的假期
            this.lunarFestival += this.lunarFestival == "" ? "" : " ";
            this.lunarFestival += OTHERFESTIVAL[s];
        }
        if (this.seq == this.weeks && typeof(OTHERFESTIVAL[s.substr(0, 3) + "9"]) != "undefined") {
            // “最后一个周几”形式的假期
            this.lunarFestival += this.lunarFestival == "" ? "" : " ";
            this.lunarFestival += OTHERFESTIVAL[s.substr(0, 3) + "9"] + " ";
        }

        // 中国的调休
        // 如果是假日，则为"+"; 如果是工作日，则显示为"-"; 如果没有调整，则为""
        this.adjusted = HOLIDAYADJUSTMENT[f(Y, "yyyy") + f(Y, "MM") + f(Y, "dd")];
        if (typeof this.adjusted == "undefined") {
            this.adjusted = ""
        }

        // 计算农历显示区 显示的内容
        this.showInLunar = "";
        if (this.specialEvent != "") {
            this.showInLunar = this.specialEvent;
        }
        if (this.lunarFestival != "") {
            this.showInLunar += this.showInLunar == "" ? "" : " ";
            this.showInLunar += this.lunarFestival;
        }
        if (this.solarFestival != "") {
            this.showInLunar += this.showInLunar == "" ? "" : " ";
            this.showInLunar += this.solarFestival;
        }
        if (this.jieqi != "") {
            this.showInLunar += this.showInLunar == "" ? "" : " ";
            this.showInLunar += this.jieqi;
        }
        if (this.showInLunar == "") {
            // 没有任何一个节日或者节气, 显示农历日期
            // 农历日期的显示，如果是月初第一天，则显示月份
            if (this.lunarDate == 1) {
                this.showInLunar = this.lunarMonthInChinese + "月"
            } else {
                this.showInLunar = this.lunarDateInChinese;
            }
        }

        // 限制字符长度
        this.showInLunar = getShortString(this.showInLunar);
    }

    // MonthData, data model for one month
    var MonthData = (function() {
        var X = {};
        X.lines = 0;
        X.dateArray = new Array(42);

        function isLeapYear(a) {
            return (((a % 4 === 0) && (a % 100 !== 0)) || (a % 400 === 0))
        }

        function daysOfYearMonth(a, b) {
            return [31, (isLeapYear(a) ? 29 : 28), 31, 30, 31, 30, 31, 31, 30, 31, 30, 31][b]
        }

        function increaseDate(a, b) {
            a.setDate(a.getDate() + b);
            return a
        }

        function init(a) {
            var f = 0;
            var c = new Calendar(new Date(a.solarYear, a.solarMonth - 1, 1));
            var d = c.solarWeekDay;  // 当月第一天是星期几
            X.lines = Math.ceil((d + daysOfYearMonth(a.solarYear, a.solarMonth - 1)) / 7);
            // 当前月历的第一格，本月的第一天可能不是月历的第一格
            c = new Calendar(increaseDate(c.date, -d));
            // 计算当前月历中的每一格日期
            for (var e = 0; e < X.dateArray.length; e++) {
                if (c.solarMonth != a.solarMonth) {
                    // 月历中的某一天，但是不是当前月的，上个月月末的几天和下个月月初的几天
                    // 在1号之前，或者月末之后的那些格
                    c.isCurrentMonth = false;
                    X.dateArray[e] = c;
                } else {
                    c.isCurrentMonth = true;
                }
                var b = new Calendar(new Date());
                if (c.solarYear == b.solarYear && c.solarMonth == b.solarMonth && c.solarDate == b.solarDate) {
                    c.isToday = true
                }
                if (c.solarYear == selYear.toString() && c.solarMonth == selMonth.toString() && c.solarDate == selDay.toString()) {
                    c.isSel = true
                }
                X.dateArray[e] = c;
                c = new Calendar(increaseDate(c.date, 1));
                f--
            }
        }

        return {
            init: function(a) {
                init(a)
            },
            getJson: function() {
                return X
            }
        }
    })();

    var Navigator = (function() {
        // var G = $("ganzhi");
        var C = $("c_buttom").getElementsByTagName("SELECT")[0];
        var X = $("c_buttom").getElementsByTagName("SELECT")[1];
        var c = $("c_buttom").getElementsByTagName("BUTTON")[0];
        var l = $("c_buttom").getElementsByTagName("BUTTON")[3];
        var m = $("c_buttom").getElementsByTagName("BUTTON")[1];
        var n = $("c_buttom").getElementsByTagName("BUTTON")[2];
        var Y = $("c_buttom").getElementsByTagName("BUTTON")[4];

        // function a(g) {
        //     _ganzhi = "农历" + g.ganzhiYear + "年" + "【" + g.shengxiao + "】";
        //     G.innerHTML = _ganzhi
        // }

        function b(g) {
            // update year/month select
            C[g.solarYear - 1901].selected = true;
            X[g.solarMonth - 1].selected = true
        }

        function f() { // change year / month to selected year / month
            var j = C.value;
            var g = X.value;
            _year = j;
            var i = new Calendar(new Date(j, g - 1, 1));
            // zfdang:更改年月时改变标题
            var date_info = $("date");
            _date_info = i.solarYear + "年" + i.solarMonth + "月";
            date_info.innerHTML = _date_info;

            var lunar_info = $("lunar_info");
            _lunar_info = i.ganzhiYear + "年" + "[" + i.shengxiao + "] " + i.ganzhiMonth + "月";
            lunar_info.innerHTML = _lunar_info;

            MonthData.init(i);
            MonthTable.draw();
            // i = new Calendar(new Date(j, 3, 1));
            // var h = new Calendar(new Date())
        }

        function Z() { // 点击今日
            selYear = selMonth = selDay = 0;
            var g = new Calendar(new Date());
            _year = g.solarYear;
            // if (typeof(lmanac_2345) != "undefined") {
            //     lmanac_2345(g.solarMonth < 10 ? "0" + g.solarMonth : g.solarMonth, g.solarDate < 10 ? "0" + g.solarDate : g.solarDate)
            // }
            // a(g);
            b(g);
            // if (typeof(his_2345) != "undefined") {
            //     his_2345()
            // }
            MonthData.init(g);
            MonthTable.draw()
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
            // init values & actions for year/month select
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
            // init function for selects and buttons
            d(g.solarYear, g.solarMonth);
            f();
            Y.onclick = Z; // back to today
            c.onclick = function() {
                setYears(parseInt(C.value) - 1)
            }; // -1 year
            l.onclick = function() {
                setYears(parseInt(C.value) + 1)
            }; // +1 year
            m.onclick = function() {
                setMonths(parseInt(X.value) - 1)
            }; // -1 month
            n.onclick = function() {
                setMonths(parseInt(X.value) + 1)
            } // +1 month
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

    var MonthTable = (function() {
        function C() {
            // draw month table
            var Z = MonthData.getJson();
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

                    // 确定日期格的颜色，有两个颜色：数字日期的颜色，节日信息的颜色
                    var h = '', _classIsRest = '';

                    // 首先确定农历字体的颜色
                    if (c[j].lunarFestival != "" || c[j].adjusted == "+") {
                        // 如果有农历节日或者是调休的假期，则显示红色
                        _classIsRest = 'class="fred"';
                    } else if (c[j].jieqi != "") {
                        // 如果有节气，则显示蓝色
                        _classIsRest = 'class="fblue"';
                    }

                    // 再确定数字日期的颜色
                    if (c[j].adjusted == "+" ||
                        ((j % 7 > 5 || j % 7 < 1) && c[j].adjusted != "-")) {
                        // 调休，或者周末但是不调休，为红色
                        h = 'class="fred"';
                    }

                    if (c[j].isToday && c[j].isCurrentMonth) {
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
                    if(c[j].isCurrentMonth){
                        // only dates belong to current month are clickable
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
                    }
                    _a.href = "javascript:void(0)";
                    _a.innerHTML = "<span><font " + h + ">" + c[j].solarDate + "</font></span><font " + _classIsRest + ">" + c[j].showInLunar + "</font>";
                    _a.className = c[j].isSel ? "active" : ((c[j].isToday && selDay == 0) ? "active" : "");
                    if(!c[j].isCurrentMonth){
                        // for dates not in current month, gray them
                        _a.className = "grayed";
                    }

                    b.appendChild(_a);
                    if(c[j].isCurrentMonth){
                        // only dates belong to current month are clickable
                        b.onmousedown = (function(d, b) {
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
            }
            var G = $c("DIV");
            var H = $("lunar_info");
            G.id = "fd";
            $("bm").appendChild(G);
            F.init(G, H)
        }

        function selectDay(a, b) {
            var Z = MonthData.getJson();
            var c = Z.dateArray;
            var C = $("c_buttom").getElementsByTagName("SELECT")[0];
            var X = $("c_buttom").getElementsByTagName("SELECT")[1];
            var Y = $("c_buttom").getElementsByTagName("INPUT")[4];
            selYear = C.value;
            selMonth = X.value;
            selDay = a;
            if (b == true || b == "true") {
                selYear = selMonth = selDay = 0;
                var g = new Calendar(new Date());
                F.hide();
                MonthData.init(g);
                MonthTable.draw();
                return true
            }
            F.hide();
            var i = new Calendar(new Date(selYear, selMonth - 1, selDay));
            if (typeof(changeDate) != "undefined") {
                changeDate(selMonth, selDay, i.solarWeekDayInChinese)
            }
            // if (typeof(lmanac_2345) != "undefined") {
            //     lmanac_2345(selMonth < 10 ? "0" + selMonth : selMonth, selDay < 10 ? "0" + selDay : selDay)
            // }
            MonthData.init(i);
            MonthTable.draw();
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

        function selectedDayInfo(b, e, d) {
            var a = MonthData.getJson().dateArray[b.dateIndex];
            var Z = b.cell;
            var c = "#{solarYear}年#{solarMonth}月#{solarDate}日<br />#{solarWeekDayInChinese}";
            c += "<br><b>#{lunarMonthInChinese}月#{lunarDateInChinese}</b>";
            c += "<br>#{ganzhiYear}年 #{ganzhiMonth}月 #{ganzhiDate}日";
            var lunar_day_info = "#{ganzhiYear}年[#{shengxiao}] #{lunarMonthInChinese}月#{lunarDateInChinese}"
            var day_info = "#{solarYear}年#{solarMonth}月#{solarDate}日"
            var s = "#{lunarMonthInChinese}月#{lunarDateInChinese}日";
            s += " #{ganzhiYear}年 #{ganzhiMonth}月 #{ganzhiDate}日";
            if (a.specialEvent != "" || a.solarFestival != "" || a.lunarFestival != "" || a.jieqi != "") {
                c += "<br><b>#{specialEvent} #{lunarFestival} #{solarFestival} #{jieqi}</b>"
            }
            if (d) {
                // 日历标题栏的当日信息
                // if (typeof(his_2345) != "undefined") {
                //     his_2345()
                // }
                // 标题行的第二部分信息
                H.innerHTML = Y(lunar_day_info, a);
                // 标题行的第一部分信息
                var date_info = $("date");
                date_info.innerHTML = Y(day_info, a);
            } else {
                // 按下日历格时弹出的信息
                C.innerHTML = Y(c, a);
                _event = e || event;
                // change div position, so it can be shown within the calendar's rect
                // calendar's rect: 430 * 360
                if (_event.clientY > 200) {
                    C.style.top = (_event.clientY - 150) + "px";
                } else {
                    C.style.top = (_event.clientY + 35) + "px";
                };
                if (_event.clientX > 300) {
                    C.style.left = (_event.clientX - 120) + "px";
                } else {
                    C.style.left = (_event.clientX) + "px";
                };
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
                selectedDayInfo(Z, a, b)
            },
            hide: function() {
                X()
            },
            init: function(Z, K) {
                C = Z, H = K
            }
        }
    })();

    // initnavigator, MonthData, and then draw MonthTable
    var myCal = new Calendar(new Date());
    Navigator.init(myCal);
    MonthData.init(myCal);
    MonthTable.draw()

})();
