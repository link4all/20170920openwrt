
function isTimeout(d) {
    if (d.timeout == 1) {
        window.top.location.href = '/login.html';
    }
    if (d.state == 3) {
        $showdialog_autoclose({body: d.txt ? d.txt : '操作失败，您不具备相应权限'});
    }
}
if (!window.console) {	
	window.console = {log: function(){}};
}

// IE8兼容的字符串和Date类型转换
function convertDate(yyyy_mm_dd_HH_mm_ss) {
    var s = yyyy_mm_dd_HH_mm_ss;
    var ps = s.split(" ");
    var pd = ps[0].split("-");
    var pt = ps.length>1 ? ps[1].split(":"): [0,0,0];
    var d = new Date(pd[0],pd[1]-1,pd[2],pt[0],pt[1],pt[2]);
    return d;
}