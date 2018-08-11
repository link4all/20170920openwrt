var iPath = function () { };
iPath.fn = iPath.prototype;

/** 
 * POST方法
 */
iPath.Post = function (url, data, fn, datatype) {
    if (datatype == undefined) {
        datatype = 'json';
    }
    iPath.LodingMask();
    $.post(url, data, function (d) {
        try {
            fn(d);
            iPath.UnLodingMask();
        } catch (e) {
            iPath.UnLodingMask();
        }
    }, datatype);
}

/** 
 * 显示载入中蒙板
 */
iPath.LodingMask = function () {
    if ($('.loadingmask').length < 1) {
        $('body').append('<div class="loadingmask"></div>');
    }
    $('.loadingmask').show();
}

/** 
 * 隐藏载入中蒙板
 */
iPath.UnLodingMask = function () {
    $('.loadingmask').hide();
}

/**
 * 数据绑定
 * template: 数据模版
 * datasource: 数据源(数据结构定义，要求必须是Array类型)
 * varname: 循环变量
 */
iPath.DataBind = function (template, datasource, varname) {
    var rel = '';
    for (var i in datasource) {
        var item = datasource[i];
        item._index = i;
        rel += iPath.LineBind(template, item, varname);
    }
    return rel;
}

/**
 * 逐行绑定
 * template: 数据模版
 * item: 本行数据对象
 * varname: 循环变量
 */
iPath.LineBind = function (template, item, varname) {
    var line = template.toString();
    for (; line.indexOf('${') > -1 ;) {
        var el = line.substring(line.indexOf('${'), line.indexOf('}$', line.indexOf('${')) + 2);
        line = line.replace(el, iPath.ElInterpret(item, el, varname));
    }
    return line;
}

/**
 * 执行el表达式并反馈执行结果
 * item: 本行数据对象
 * el: 需要执行的el表达式
 * varname: 循环变量
 */
iPath.ElInterpret = function (item, el, varname) {
    el = el.substring(2, el.length - 2);
    var i1 = el.indexOf('(');
    var i2 = el.indexOf(')');
    if(i1 > -1 && i2 > -1) {
    	var r = eval(el);
    	return (undefined != r && null != r) ? r : '';
    } else if (varname == undefined) {
    	var els = el.split('.');
    	var el_all = '';
    	for(var i = 0; i < els.length; i++) {
    		var el_temp = els[i];
    		if(!el_all)
    			el_all = el_temp;
    		else
    			el_all += '.' + el_temp;
    		var r = eval(el_all);
    		if(undefined == r || null == r)
    			return '';
    	}
    	var r = eval(el);
        return (undefined != r && null != r) ? r : '';
    } else {
        el = 'var ' + varname + ' = item; \n' + el;
        return eval(el);
    }

}

iPath.Count = function (data, fn) {
    var rel = 0;
    for (var i in data) {
        var item = data[i];
        if (fn(item)) {
            rel++;
        }
    }
    return rel;
}

iPath.Sum = function (data, fn) {
    var rel = 0;
    for (var i in data) {
        var item = data[i];
        rel += fn(item);
    }
    return rel;
}

iPath.Select = function (data, fn) {
    var rel = new Array();
    for (var i in data) {
        var item = data[i];
        rel.push(fn(item));
    }
    return rel;
}

iPath.Where = function (data, fn) {
    var rel = new Array();
    for (var i in data) {
        var item = data[i];
        var _item = fn(item);
        if (_item != undefined && _item != null) {
            rel.push(_item);
        }
    }
    return rel;
}

var iPathDataBind = function () { };
iPathDataBind.fn = iPathDataBind.prototype;
iPathDataBind.fn.jq_obj = undefined;
iPathDataBind.fn.template = undefined;

jQuery.fn.iPathDataBind = function () {
    var $iPathDataBind = new iPathDataBind();
    $iPathDataBind.jq_obj = this;
    if (this.find('script').length > 0) {
        $iPathDataBind.template = this.find('script:eq(0)').html();
    } else {
        $iPathDataBind.template = this.html();
    }
    this.html('');
    return $iPathDataBind;
};

/**
 * 数据绑定
 * jQDom: jqueryDom对象
 * datasource: 数据源(数据结构定义，要求必须是Array类型)
 */
iPathDataBind.fn.DataBind = function (datasource) {
    var html = iPath.DataBind(this.template, datasource, this.jq_obj.attr('var'));
    this.jq_obj.html(html);
}

/**
 * 数据绑定 追加
 * jQDom: jqueryDom对象
 * datasource: 数据源(数据结构定义，要求必须是Array类型)
 */
iPathDataBind.fn.AppendDataBind = function (datasource) {
    var html = iPath.DataBind(this.template, datasource, this.jq_obj.attr('var'));
    this.jq_obj.append(html);
}

/**
 * 清空绑定数据
 */
iPathDataBind.fn.Clear = function () {
    this.jq_obj.html('');
}


/**
* 从下面开始，是Master.Jiang扩展的拼图数据表格插件
*/
function PagingBar() { };
PagingBar.fn = PagingBar.prototype;
PagingBar.fn.prev = undefined;
PagingBar.fn.page = undefined;
PagingBar.fn.next = undefined;
PagingBar.fn.index = undefined;
PagingBar.fn.go = undefined;

function iPathDataGrid() { };
iPathDataGrid.fn = iPathDataGrid.prototype;
iPathDataGrid.fn.jq_obj = undefined;
iPathDataGrid.fn.total = 0;
iPathDataGrid.fn.rows = 10;
iPathDataGrid.fn.page = 1;
iPathDataGrid.fn.total = 0;
iPathDataGrid.fn.url = '';
iPathDataGrid.fn.paging = false;
iPathDataGrid.fn.pagingBar = undefined;
iPathDataGrid.fn.rowsData = undefined;
iPathDataGrid.fn.QueryParams = function () {
    return {};
};
iPathDataGrid.fn.trTmpl = '';
iPathDataGrid.fn.LineFormatter = function (dr) {
    dr._index = dr.index;
    return iPath.LineBind(this.trTmpl, dr, 'dr');
};
iPathDataGrid.fn.LoadComplete = function (dr) {

};
iPathDataGrid.fn.LoadData = function () {
    var postdata = this.QueryParams();
    if (postdata == false)
        return;
    postdata.rows = this.rows;
    postdata.page = this.page;

    var pdg = this;
    window.top.showLoading();
    $.ajax(
        {
            url: this.url,
            type: 'post',
            data: postdata,
            dataType: 'json',
            success: function (data) {
                window.top.hideLoading();
                if (data.state == 1) {
                    pdg.total = data.total;
                    var tbody = pdg.jq_obj.find('tbody');
                    tbody.html('');

                    pdg.rowsData = data.rows;
                    var tbodyhtml = '';
                    var index = (pdg.page - 1) * pdg.rows;
                    for (var i in data.rows) {
                        index++;
                        var dr = data.rows[i];
                        dr.index = index;
                        tbodyhtml += pdg.LineFormatter(dr);
                    }
                    tbody.html(tbodyhtml);

                    if (pdg.paging == true) {
                        var maxPage = pdg.total < 1 ? 1 : Math.ceil(pdg.total / pdg.rows);
                        var _pageHtml = '' + pdg.page + '/' + maxPage;
                        pdg.pagingBar.page.html(_pageHtml);
                        pdg.pagingBar.index.val(pdg.page);
                    }
                    pdg.LoadComplete();
                } else {
                    $showdialog({ body: data.txt });
                }
            },
            error: function () {
                window.top.hideLoading();
                $showdialog({ body: '通讯错误' });
            }
        }
    );
};
iPathDataGrid.fn.Load = function () {
    this.page = 1;
    this.LoadData();
};
iPathDataGrid.fn.LoadPage = function (page) {
    var maxPage = this.total < 1 ? 1 : Math.ceil(this.total / this.rows);
    if (maxPage < page || 1 > page) {
        $showdialog({ body: '请输入有效的页码值！' });
        return;
    }
    this.page = page;
    this.LoadData();
};
iPathDataGrid.fn.LoadPrev = function () {
    if (this.page > 1) {
        this.page = this.page - 1;
        this.LoadData();
    }
};
iPathDataGrid.fn.LoadNext = function () {
    var maxPage = this.total < 1 ? 1 : Math.ceil(this.total / this.rows);
    if (maxPage > this.page) {
        this.page = this.page + 1;
        this.LoadData();
    }
};
// 将拼图表格扩展为jQuery的插件
jQuery.fn.iPathDataGrid = function (e) {
    var pdg = new iPathDataGrid();
    pdg.jq_obj = this;
    pdg.trTmpl = pdg.jq_obj.find('tbody').html();
    pdg.jq_obj.find('tbody').html('');
    if (e.rows != undefined) {
        pdg.rows = e.rows
    }
    if (e.page != undefined) {
        pdg.page = e.page
    }
    if (e.paging == true) {
        pdg.paging = true;

        // 放入分页footbar
        var footHtml = '';
        footHtml += '        <div class="form-inline" >\n';
        footHtml += '            <button class="button icon-caret-left paging_prev" type="button"></button>';
        footHtml += '            <label class="paging_page">1/1</label>';
        footHtml += '            <button class="button icon-caret-right paging_next" type="button"></button>';
        footHtml += '            <input type="text" class="input input-auto paging_index" style="width:40px; text-align:center;" />';
        footHtml += '            <button class="button icon-anchor paging_go" type="button">&nbsp;&nbsp;跳转</button>';
        footHtml += '        </div>';

        var $paging;
        if (e.paging_id != undefined) {
            $paging = $('#' + e.paging_id);
        } else {
            $paging = this.find('.paging');
        }

        $paging.html(footHtml);

        var pagingBar = new PagingBar();

        pagingBar.prev = $paging.find('.paging_prev');
        pagingBar.page = $paging.find('.paging_page');
        pagingBar.next = $paging.find('.paging_next');
        pagingBar.index = $paging.find('.paging_index');
        pagingBar.go = $paging.find('.paging_go');

        pagingBar.prev.click(function () {
            pdg.LoadPrev();
        });
        pagingBar.next.click(function () {
            pdg.LoadNext();
        });
        pagingBar.go.click(function () {
            var index = parseInt(pagingBar.index.val());
            if (isNaN(index)) {
                index = 0;
            }
            pagingBar.index.val(index);
            pdg.LoadPage(index);
        });
        pdg.pagingBar = pagingBar;
    }
    pdg.url = e.url;

    pdg.jq_obj.find('thead input[type="checkbox"]').click(function () {
        var checked = this.checked;
        pdg.jq_obj.find('tbody input[type="checkbox"]').each(function () {
            this.checked = checked;
        });
    });

    return pdg;
};

/* iPath标签页切换 */
function iPathTabSheet() { };
iPathTabSheet.fn = iPathTabSheet.prototype;
iPathTabSheet.fn.jqobj = undefined;
iPathTabSheet.fn.Init = function () {
    var that = this;
    that.jqobj.find('li').bind('click', function () {
        that.HideAll();
        var target = $(this).attr('target');
        $('#' + target).show();
        $(this).addClass('checked');
    });
    that.jqobj.find('li:eq(0)').click();
}
iPathTabSheet.fn.HideAll = function () {
    this.jqobj.find('li').each(function () {
        $(this).removeClass('checked');
        var target = $(this).attr('target');
        $('#' + target).hide();
    });
}

jQuery.fn.iPathTabSheet = function () {
    var tabSheet = new iPathTabSheet();
    tabSheet.jqobj = $(this);
    tabSheet.Init();
    return tabSheet;
}


var mvcParamMatch = (function () {
    var MvcParameterAdaptive = {};
    //验证是否为数组
    MvcParameterAdaptive.isArray = Function.isArray || function (o) {
        return typeof o === "object" &&
                Object.prototype.toString.call(o) === "[object Array]";
    };

    //将数组转换为对象
    MvcParameterAdaptive.convertArrayToObject = function (/*数组名*/arrName, /*待转换的数组*/array, /*转换后存放的对象，不用输入*/saveOjb) {
        var obj = saveOjb || {};

        function func(name, arr) {
            for (var i in arr) {
                if (!MvcParameterAdaptive.isArray(arr[i]) && typeof arr[i] === "object") {
                    for (var j in arr[i]) {
                        if (MvcParameterAdaptive.isArray(arr[i][j])) {
                            func(name + "[" + i + "]." + j, arr[i][j]);
                        } else if (typeof arr[i][j] === "object") {
                            MvcParameterAdaptive.convertObject(name + "[" + i + "]." + j + ".", arr[i][j], obj);
                        } else {
                            obj[name + "[" + i + "]." + j] = arr[i][j];
                        }
                    }
                } else {
                    obj[name + "[" + i + "]"] = arr[i];
                }
            }
        }

        func(arrName, array);

        return obj;
    };

    //转换对象
    MvcParameterAdaptive.convertObject = function (/*对象名*/objName, /*待转换的对象*/turnObj, /*转换后存放的对象，不用输入*/saveOjb) {
        var obj = saveOjb || {};

        function func(name, tobj) {
            for (var i in tobj) {
                if (MvcParameterAdaptive.isArray(tobj[i])) {
                    MvcParameterAdaptive.convertArrayToObject(i, tobj[i], obj);
                } else if (typeof tobj[i] === "object") {
                    func(name + i + ".", tobj[i]);
                } else {
                    obj[name + i] = tobj[i];
                }
            }
        }

        func(objName, turnObj);
        return obj;
    };

    return function (json, arrName) {
        arrName = arrName || "";
        if (typeof json !== "object") throw new Error("请传入json对象");
        if (MvcParameterAdaptive.isArray(json) && !arrName) throw new Error("请指定数组名，对应Action中数组参数名称！");

        if (MvcParameterAdaptive.isArray(json)) {
            return MvcParameterAdaptive.convertArrayToObject(arrName, json);
        }
        return MvcParameterAdaptive.convertObject("", json);
    };
})();

$.fn.selectRange = function (start, end) {
    return this.each(function () {
        if (this.setSelectionRange) {
            this.focus();
            this.setSelectionRange(start, end);
        } else if (this.createTextRange) {
            var range = this.createTextRange();
            range.collapse(true);
            range.moveEnd('character', end);
            range.moveStart('character', start);
            range.select();
        }
    });
};


String.prototype.trim = function () {
    return this.replace(/(^\s*)|(\s*$)/g, "");
};
String.prototype.ltrim = function () {
    return this.replace(/(^\s*)/g, "");
};
String.prototype.rtrim = function () {
    return this.replace(/(\s*$)/g, "");
};

iPath.ChangeTitle = function (title) {
    var body = document.getElementsByTagName('body')[0];
    document.title = title;
    var iframe = document.createElement("iframe");
    iframe.setAttribute("src", "loading.png");
    function onload() {
        setTimeout(function () {
            iframe.removeEventListener('load', onload);
            document.body.removeChild(iframe);
        }, 0);
    }
    iframe.addEventListener('load', onload);
    document.body.appendChild(iframe);
};

// 页面前端路由
function iPathRoute() { }
iPathRoute.fn = iPathRoute.prototype;
iPathRoute.fn.basehref = undefined;
iPathRoute.fn.eventList = undefined;
iPathRoute.fn.Init = function () {
    this.basehref = window.location.href;
    this.eventList = new Array();
    var that = this;
    window.addEventListener('popstate', function (e) {
        var historyState = undefined;
        if (history.state) {
            historyState = e.state;
        }

        that.Do(location.pathname, historyState);

    }, false);
}
/**
 * 增加事件监听
 */
iPathRoute.fn.AddListener = function (pathname, callback) {
    this.eventList.push(
        {
            pathname: pathname,
            callback: callback
        }
    );

}
/**
 * 增加事件监听
 */
iPathRoute.fn.Do = function (pathname, eventState) {

    var list = iPath.Where(this.eventList, function (item) {
        if (pathname == item.pathname) {
            return item;
        }
    });

    for (var i in list) {
        var item = list[i];
        try {
            item.callback(pathname, eventState);
        } catch (e) { }
    }

}

/**
 * 导航到新界面
 */
iPathRoute.fn.Navigation = function (pathname, eventState, title) {
    title = title == undefined ? '' : title;
    window.history.pushState(eventState, title, pathname);
    this.Do(pathname, eventState);
}


