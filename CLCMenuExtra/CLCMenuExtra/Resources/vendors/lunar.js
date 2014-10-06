var P = [19416, 19168, 42352, 21717, 53856, 55632, 91476, 22176, 39632, 21970, 19168, 42422, 42192, 53840, 119381, 46400, 54944, 44450, 38320, 84343, 18800, 42160, 46261, 27216, 27968, 109396, 11104, 38256, 21234, 18800, 25958, 54432, 59984, 28309, 23248, 11104, 100067, 37600, 116951, 51536, 54432, 120998, 46416, 22176, 107956, 9680, 37584, 53938, 43344, 46423, 27808, 46416, 86869, 19872, 42448, 83315, 21200, 43432, 59728, 27296, 44710, 43856, 19296, 43748, 42352, 21088, 62051, 55632, 23383, 22176, 38608, 19925, 19152, 42192, 54484, 53840, 54616, 46400, 46496, 103846, 38320, 18864, 43380, 42160, 45690, 27216, 27968, 44870, 43872, 38256, 19189, 18800, 25776, 29859, 59984, 27480, 21952, 43872, 38613, 37600, 51552, 55636, 54432, 55888, 30034, 22176, 43959, 9680, 37584, 51893, 43344, 46240, 47780, 44368, 21977, 19360, 42416, 86390, 21168, 43312, 31060, 27296, 44368, 23378, 19296, 42726, 42208, 53856, 60005, 54576, 23200, 30371, 38608, 19415, 19152, 42192, 118966, 53840, 54560, 56645, 46496, 22224, 21938, 18864, 42359, 42160, 43600, 111189, 27936, 44448];
var B = "日一二三四五六七八九十";
var O = "鼠牛虎兔龙蛇马羊猴鸡狗猪";
var K = "甲乙丙丁戊己庚辛壬癸";
var J = "子丑寅卯辰巳午未申酉戌亥";
var D = [0, 21208, 43467, 63836, 85337, 107014, 128867, 150921, 173149, 195551, 218072, 240693, 263343, 285989, 308563, 331033, 353350, 375494, 397447, 419210, 440795, 462224, 483532, 504758];

function U(Y) {
    function d(k) {
        var h, j = 348;
        for (h = 0x8000; h > 8; h >>= 1) {
            j += (P[k - 1900] & h) ? 1 : 0;
        }
        return (j + b(k));
    }

    function a(h) {
        return (K.charAt(h % 10) + J.charAt(h % 12));
    }

    function b(h) {
        if (g(h)) {
            return ((P[h - 1900] & 65536) ? 30 : 29);
        } else {
            return (0);
        }
    }

    function g(h) {
        return (P[h - 1900] & 15);
    }

    function e(i, h) {
        return ((P[i - 1900] & (65536 >> h)) ? 30 : 29);
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
            this.monCyl += 12;
        }
        if (n < 0) {
            n += h;
            k--;
            this.monCyl -= 12;
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
                h = e(this.year, k);
            } if (this.isLeap == true && k == (j + 1)) {
                this.isLeap = false;
            }
            n -= h;
            if (this.isLeap == false) {
                this.monCyl++;
            }
        }
        if (n == 0 && j > 0 && k == j + 1) {
            if (this.isLeap) {
                this.isLeap = false;
            } else {
                this.isLeap = true;
                --k;
                --this.monCyl;
            }
        }
        if (n < 0) {
            n += h;
            --k;
            --this.monCyl;
        }
        this.month = k;
        this.day = n + 1;
    }

    function G(h) {
        return h < 10 ? "0" + h : h;
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
                    return h.getMonth() + 1;
            }
        })
    }
    this.date = Y;
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
    this.lunarDate = X.day;
    this.ganzhiYear = a(X.yearCyl);
    this.ganzhiMonth = a(X.monCyl);
    this.ganzhiDate = a(X.dayCyl++);
}