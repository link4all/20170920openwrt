/** * 对Date的扩展，将 Date 转化为指定格式的String * 月(M)、日(d)、12小时(h)、24小时(H)、分(m)、秒(s)、周(E)、季度(q)
可以用 1-2 个占位符 * 年(y)可以用 1-4 个占位符，毫秒(S)只能用 1 个占位符(是 1-3 位的数字) * eg: * (new
Date()).pattern("yyyy-MM-dd hh:mm:ss.S")==> 2006-07-02 08:09:04.423      
* (new Date()).pattern("yyyy-MM-dd E HH:mm:ss") ==> 2009-03-10 二 20:09:04      
* (new Date()).pattern("yyyy-MM-dd EE hh:mm:ss") ==> 2009-03-10 周二 08:09:04      
* (new Date()).pattern("yyyy-MM-dd EEE hh:mm:ss") ==> 2009-03-10 星期二 08:09:04      
* (new Date()).pattern("yyyy-M-d h:m:s.S") ==> 2006-7-2 8:9:4.18      
*/
Date.prototype.pattern = function (fmt) {
    var o = {
        "M+": this.getMonth() + 1, //月份         
        "d+": this.getDate(), //日         
        "h+": this.getHours() % 12 == 0 ? 12 : this.getHours() % 12, //小时         
        "H+": this.getHours(), //小时         
        "m+": this.getMinutes(), //分         
        "s+": this.getSeconds(), //秒         
        "q+": Math.floor((this.getMonth() + 3) / 3), //季度         
        "S": this.getMilliseconds()
        //毫秒         
    };
    var week = {
        "0": "/u65e5",
        "1": "/u4e00",
        "2": "/u4e8c",
        "3": "/u4e09",
        "4": "/u56db",
        "5": "/u4e94",
        "6": "/u516d"
    };
    if (/(y+)/.test(fmt)) {
        fmt = fmt.replace(RegExp.$1, (this.getFullYear() + "")
				.substr(4 - RegExp.$1.length));
    }
    if (/(E+)/.test(fmt)) {
        fmt = fmt
				.replace(
						RegExp.$1,
						((RegExp.$1.length > 1) ? (RegExp.$1.length > 2 ? "/u661f/u671f"
								: "/u5468")
								: "")
								+ week[this.getDay() + ""]);
    }
    for (var k in o) {
        if (new RegExp("(" + k + ")").test(fmt)) {
            fmt = fmt.replace(RegExp.$1, (RegExp.$1.length == 1) ? (o[k])
					: (("00" + o[k]).substr(("" + o[k]).length)));
        }
    }
    return fmt;
};

Date.prototype.DateAdd = function (strInterval, Number) {
    var dtTmp = this;
    switch (strInterval) {
        case 's': return new Date(Date.parse(dtTmp) + (1000 * Number));
        case 'n': return new Date(Date.parse(dtTmp) + (60000 * Number));
        case 'h': return new Date(Date.parse(dtTmp) + (3600000 * Number));
        case 'd': return new Date(Date.parse(dtTmp) + (86400000 * Number));
        case 'w': return new Date(Date.parse(dtTmp) + ((86400000 * 7) * Number));
        case 'q': return new Date(dtTmp.getFullYear(), (dtTmp.getMonth()) + Number * 3, dtTmp.getDate(), dtTmp.getHours(), dtTmp.getMinutes(), dtTmp.getSeconds());
        case 'm': return new Date(dtTmp.getFullYear(), (dtTmp.getMonth()) + Number, dtTmp.getDate(), dtTmp.getHours(), dtTmp.getMinutes(), dtTmp.getSeconds());
        case 'y': return new Date((dtTmp.getFullYear() + Number), dtTmp.getMonth(), dtTmp.getDate(), dtTmp.getHours(), dtTmp.getMinutes(), dtTmp.getSeconds());
    }
};

/**
 * 判断参数日期是否从左到右升序
 * @param date1
 * @param date2
 */
function isDateAscending(date1, date2) {
    var d1 = new Date(date1.replace('-', '/'));
    var d2 = new Date(date2.replace('-', '/'));
    return d1.getTime() < d2.getTime();
}

function isDateAscending2(date1, date2) {
    var d1 = new Date(date1.replace('-', '/'));
    var d2 = new Date(date2.replace('-', '/'));
    return d1.getTime() <= d2.getTime();
}

/**
 * 清理date中的time部分
 */
function clearTimeForDate(d) {
    var h = 0 - d.getHours();
    var n = 0 - d.getMinutes();
    var s = 0 - d.getMilliseconds();
    d = d.DateAdd('h', h);
    d = d.DateAdd('n', n);
    d = d.DateAdd('s', s);
    return d;
}

/**
 * 把.Net输出的 /Date(1445421250444)/ 转化为js 的Date格式
 */
function getDateByDotNet(txt) {
    return eval('new ' + (txt.replace(/\//g, '')))
}
function getDateByDotNetNumber(txt) {
    return eval('new Date(' + txt + ')');
}

/**
 * 日期格式化
 */
function dateFormatter(value) {
    if (value == undefined || value == null || value == '')
        return value;
    return new Date(value).pattern("yyyy-MM-dd");
}

/**
 * 日期时间格式化
 */
function dateTimeFormatter(value) {
    if (value == undefined || value == null || value == '')
        return value;
    return new Date(value).pattern("yyyy-MM-dd HH:mm:ss");
}

/**
 * 日期时间格式化,根据.Net输出的时间
 */
function dateTimeFormatterByDotNet(txt) {
    return dateTimeFormatter(getDateByDotNet(txt));
}

/**
 * 秒数时间差转换为 x天x时x分x秒这样的写法
 */
function getTimeZone(seconds) {
    var s = seconds % 60;
    var minute = parseInt(seconds / 60);
    var m = minute % 60;
    var hour = parseInt(minute / 60);
    var h = hour % 24;
    var day = parseInt(hour / 24);
    var d = day;

    var rel = '';
    if (d > 0) {
        rel += d + '天';
    }
    if (h > 0 || rel.length > 0) {
        rel += h + '时';
    }
    if (m > 0 || rel.length > 0) {
        rel += m + '分';
    }
    if (s > 0 || rel.length > 0) {
        rel += s + '秒';
    }
    return rel;
}