$(function () {
    $(".win-homepage").click(function () {
        if (document.all) {
            document.body.style.behavior = 'url(#default#homepage)';
            document.body.setHomePage(document.URL);
        } else { alert("Set failed, try again锛�"); }
    });
    $(".win-favorite").click(function () {
        var sURL = document.URL;
        var sTitle = document.title;
        try { window.external.addFavorite(sURL, sTitle); }
        catch (exp) {
            try { window.sidebar.addPanel(sTitle, sURL, ""); }
            catch (exp) { alert("Failed锛寀se Ctrl+D"); }
        }
    });
    $(".win-forward").click(function () {
        window.history.forward(1);
    });
    $(".win-back").click(function () {
        window.history.back(-1);
    });
    $(".win-backtop").click(function () { $('body,html').animate({ scrollTop: 0 }, 1000); return false; });
    $(".win-refresh").click(function () {
        window.location.reload();
    });
    $(".win-print").click(function () {
        window.print();
    });
    $(".win-close").click(function () {
        window.close();
    });
    $('.checkall').click(function () {
        var e = $(this);
        var name = e.attr("name");
        var checkfor = e.attr("checkfor");
        var type;
        if (checkfor != '' && checkfor != null && checkfor != undefined) {
            type = e.closest('form').find("input[name='" + checkfor + "']");
        } else {
            type = e.closest('form').find("input[type='checkbox']");
        };
        if (name == "checkall") {
            $(type).each(function (index, element) {
                element.checked = true;
            });
            e.attr("name", "ok");
        } else {
            $(type).each(function (index, element) {
                element.checked = false;
            });
            e.attr("name", "checkall");
        }
    });
    $('.dropdown-toggle').click(function () {
        $(this).closest('.button-group, .drop').addClass("open");
    });
    $(document).bind("click", function (e) {
        if ($(e.target).closest(".button-group.open, .drop.open").length == 0) {
            $(".button-group, .drop").removeClass("open");
        }
    });
    $checkplaceholder = function () {
        var input = document.createElement('input');
        return 'placeholder' in input;
    };
    if (!$checkplaceholder()) {
        $("textarea[placeholder], input[placeholder]").each(function (index, element) {
            if ($(element).attr("placeholder") || $emptyplaceholder(element)) {
                $(element).val($(element).attr("placeholder"));
                $(element).data("pintuerholder", $(element).css("color"));
                $(element).css("color", "rgb(169,169,169)");
                $(element).focus(function () { $hideplaceholder($(this)); });
                $(element).blur(function () { $showplaceholder($(this)); });
            }
        })
    };
    $emptyplaceholder = function (element) {
        var $content = $(element).val();
        return ($content.length === 0) || $content == $(element).attr("placeholder");
    };
    $showplaceholder = function (element) {
        //涓嶄负绌哄強瀵嗙爜妗�
        if ($emptyplaceholder(element) && $(element).attr("type") != "password") {
            $(element).val($(element).attr("placeholder"));
            $(element).data("pintuerholder", $(element).css("color"));
            $(element).css("color", "rgb(169,169,169)");
        }
    };
    var $hideplaceholder = function (element) {
        if ($(element).data("pintuerholder")) {
            $(element).val("");
            $(element).css("color", $(element).data("pintuerholder"));
            $(element).removeData("pintuerholder");
        }
    };
    $('textarea, input, select').blur(function () {
        var e = $(this);
        if (e.attr("data-validate")) {
            e.closest('.field').find(".input-help").remove();
            var $checkdata = e.attr("data-validate").split(',');
            var $checkvalue = e.val();
            var $checkstate = true;
            var $checktext = "";
            if (e.attr("placeholder") == $checkvalue) { $checkvalue = ""; }
            if ($checkvalue != "" || e.attr("data-validate").indexOf("required") >= 0) {
                for (var i = 0; i < $checkdata.length; i++) {
                    var $checktype = $checkdata[i].split(':');
                    if (!$pintuercheck(e, $checktype[0], $checkvalue)) {
                        $checkstate = false;
                        $checktext = $checktext + "<li>" + $checktype[1] + "</li>";
                    }
                }
            };
            if ($checkstate) {
                e.closest('.form-group').removeClass("check-error");
                e.parent().find(".input-help").remove();
                //e.closest('.form-group').addClass("check-success");
            } else {
                e.closest('.form-group').removeClass("check-success");
                e.closest('.form-group').addClass("check-error");
                e.closest('.field').append('<div class="input-help"><ul>' + $checktext + '</ul></div>');
            }
        }
    });
    $pintuercheck = function (element, type, value) {
        $pintu = value.replace(/(^\s*)|(\s*$)/g, "");
        switch (type) {
            case "required": return /[^(^\s*)|(\s*$)]/.test($pintu); break;
            case "chinese": return /^[\u0391-\uFFE5]+$/.test($pintu); break;
            case "cnennumber": return /^[\u0391-\uFFE5,a-z,A-Z,0-9]+$/.test($pintu); break;
            case "number": return /^\d+$/.test($pintu); break;
            case "integer": return /^[-\+]?\d+$/.test($pintu); break;
            case "plusinteger": return /^[+]?\d+$/.test($pintu); break;
            case "double": return /^[-\+]?\d+(\.\d+)?$/.test($pintu); break;
            case "plusdouble": return /^[+]?\d+(\.\d+)?$/.test($pintu); break;
            case "english": return /^[A-Za-z]+$/.test($pintu); break;
            case "username": return /^[a-z]\w{3,}$/i.test($pintu); break;
            case "mobile": return /^((\(\d{3}\))|(\d{3}\-))?1[0-9]\d{9}?$|15[0-9]\d{8}?$|170\d{8}?$|147\d{8}?$/.test($pintu); break;
            case "phone": return /^((\(\d{2,3}\))|(\d{3}\-))?(\(0\d{2,3}\)|0\d{2,3}-)?[1-9]\d{6,7}(\-\d{1,4})?$/.test($pintu); break;
            case "tel": return /^((\(\d{3}\))|(\d{3}\-))?13[0-9]\d{8}?$|15[89]\d{8}?$|170\d{8}?$|147\d{8}?$/.test($pintu) || /^((\(\d{2,3}\))|(\d{3}\-))?(\(0\d{2,3}\)|0\d{2,3}-)?[1-9]\d{6,7}(\-\d{1,4})?$/.test($pintu); break;
            case "email": return /^[^@]+@[^@]+\.[^@]+$/.test($pintu); break;
            case "url": return /^((http|https):\/\/)?[A-Za-z0-9\-]+\.[A-Za-z0-9\-]+[\/=\?%\-&_~`@[\]\':+!]*([^<>\"\"])*$/.test($pintu); break;
            case "ip": return /^[\d\.]{7,15}$/.test($pintu); break;
            case "qq": return /^[1-9]\d{4,10}$/.test($pintu); break;
            case "currency": return /^\d+(\.\d+)?$/.test($pintu); break;
            case "zip": return /^[1-9]\d{5}$/.test($pintu); break;
            case "menukey": return /^[A-Z,a-z]\w{3,}$/i.test($pintu); break;
            case "radio":
                var radio = element.closest('form').find('input[name="' + element.attr("name") + '"]:checked').length;
                return eval(radio == 1);
                break;
            default:
                var $test = type.split('#');
                if ($test.length > 1) {
                    switch ($test[0]) {
                        case "compare":
                            return eval(Number($pintu) + $test[1]);
                            break;
                        case "regexp":
                            return new RegExp($test[1], "gi").test($pintu);
                            break;
                        case "length":
                            var $length;
                            if (element.attr("type") == "checkbox") {
                                $length = element.closest('form').find('input[name="' + element.attr("name") + '"]:checked').length;
                            } else {
                                $length = $pintu.replace(/[\u4e00-\u9fa5]/g, "***").length;
                            }
                            return eval($length + $test[1]);
                            break;
                        case "ajax":
                            var $getdata;
                            var $url = $test[1] + $pintu;
                            $.ajaxSetup({ async: false });
                            $.getJSON($url, function (data) {
                                $getdata = data.getdata;
                            });
                            if ($getdata == "true") { return true; }
                            break;
                        case "repeat":
                            return $pintu == jQuery('input[name="' + $test[1] + '"]').eq(0).val();
                            break;
                        default: return true; break;
                    }
                    break;
                } else {
                    return true;
                }
        }
    };

    $validateElement = function (domId) {
        $('#' + domId).trigger("blur");
    };

    $validateForm = function (formId, form) {
        var _this;
        if (formId == '' || formId == null || formId == undefined) {
            _this = form;
        } else {
            _this = $('#' + formId);
        }

        _this.find('input[data-validate],textarea[data-validate],select[data-validate]').trigger("blur");
        var numError = _this.find('.check-error').length;
        if (numError) {
            _this.find('.check-error').first().find('input[data-validate],textarea[data-validate],select[data-validate]').first().focus().select();
            return false;
        }
        return true;
    };
    //    $('form').submit(function () {
    //        $(this).find('input[data-validate],textarea[data-validate],select[data-validate]').trigger("blur");
    //        var numError = $(this).find('.check-error').length;
    //        if (numError) {
    //            $(this).find('.check-error').first().find('input[data-validate],textarea[data-validate],select[data-validate]').first().focus().select();
    //            return false;
    //        }
    //    });
    $ajaxSubmit = function (formId, action, success, error, isFrame) {
        var validateRel = $validateForm(formId);
        if (!validateRel)
            return;
        var queryString = $('#' + formId).formSerialize();

        if (isFrame != true)
            isFrame = false;

        $.PintuerPost(action, queryString, success, error, isFrame);
    }

    $('.form-reset').click(function () {
        $(this).closest('form').find(".input-help").remove();
        $(this).closest('form').find('.form-submit').removeAttr('disabled');
        $(this).closest('form').find('.form-group').removeClass("check-error");
        $(this).closest('form').find('.form-group').removeClass("check-success");
    });
    $('.tab .tab-nav li').each(function () {
        var e = $(this);
        var trigger = e.closest('.tab').attr("data-toggle");
        if (trigger == "hover") {
            e.mouseover(function () {
                $showtabs(e);
            });
            e.click(function () {
                return false;
            });
        } else {
            e.click(function () {
                $showtabs(e);
                return false;
            });
        }
    });
    $showtabs = function (e) {
        var detail = e.children("a").attr("href");
        e.closest('.tab .tab-nav').find("li").removeClass("active");
        e.closest('.tab').find(".tab-body .tab-panel").removeClass("active");
        e.addClass("active");
        $(detail).addClass("active");
    };
    $('.dialogs').each(function () {
        var e = $(this);
        var trigger = e.attr("data-toggle");
        if (trigger == "hover") {
            e.mouseover(function () {
                $showdialogs(e);
            });
        } else if (trigger == "click") {
            e.click(function () {
                $showdialogs(e);
            });
        }
    });
    $showdialogs = function (e) {
        var trigger = e.attr("data-toggle");
        var getid = e.attr("data-target");
        var data = e.attr("data-url");
        var mask = e.attr("data-mask");
        var width = e.attr("data-width");
        var detail = "";
        var masklayout = $('<div class="dialog-mask"></div>');
        if (width == null) { width = "80%"; }

        if (mask == "1") {
            $("body").append(masklayout);
        }
        detail = '<div class="dialog-win" style="position:fixed;width:' + width + ';z-index:11000;">';
        if (getid != null) { detail = detail + $(getid).html(); }
        if (data != null) { detail = detail + $.ajax({ url: data, async: false }).responseText; }
        detail = detail + '</div>';

        var win = $(detail);
        win.find(".dialog").addClass("open");
        $("body").append(win);
        var x = parseInt($(window).width() - win.outerWidth()) / 2;
        var y = parseInt($(window).height() - win.outerHeight()) / 2;
        if (y <= 10) { y = "10" }
        win.css({ "left": x, "top": y });
        win.find(".dialog-close,.close").each(function () {
            $(this).click(function () {
                win.remove();
                $('.dialog-mask').remove();
            });
        });
        masklayout.click(function () {
            win.remove();
            $(this).remove();
        });
    };

    showdialog_z_index = 11;

    $showdialog = function (e) {
        if (window.parent.$showdialog != undefined && window.parent.$showdialog != $showdialog) {
            window.parent.$showdialog(e)
            return;
        }

        var title = e.title == '' || e.title == null || e.title == undefined ? 'Msg' : e.title;
        var body = e.body;

        var width = e.width;
        var detail = "";
        var masklayout = $('<div class="dialog-mask" style="z-index:' + (showdialog_z_index++) + '"></div>');
        if (width == null || width == undefined) { width = "500px"; }

        var $masklayout = $(masklayout);
        $("body").append($masklayout);

        detail = '<div class="dialog-win" style="position:fixed;width:' + width + ';z-index:' + (showdialog_z_index++) + ';">';

        detail += '<div id="mydialog">';
        detail += '<div class="dialog">';
        detail += '<div class="dialog-head">';
        detail += '  <span class="close rotate-hover"></span>';
        detail += '  <strong>' + title + '</strong>';
        detail += '</div>';
        detail += '<div class="dialog-body">';
        detail += body;
        detail += '</div>';
        detail += '<div class="dialog-foot">';
        // detail += '  <button class="button dialog-close">鍙栨秷</button>';
        detail += '  <button class="button bg-green btn_ok">Confirm</button>';
        detail += '</div>';
        detail += '</div>';
        detail += '</div>';


        detail = detail + '</div>';

        var win = $(detail);
        win.find(".dialog").addClass("open");
        $("body").append(win);
        var x = parseInt($(window).width() - win.outerWidth()) / 2;
        var y = parseInt($(window).height() - win.outerHeight()) / 2;
        if (y <= 10) { y = "10" }
        win.css({ "left": x, "top": y });
        win.find(".btn_ok,.close").click(function () {
            win.remove();
            $masklayout.remove();
            try {
                if (e.success != undefined) {
                    e.success();
                }
            } catch (exp) {
                console.error(exp);
            }
        });

    };

    $showdialog_autoclose = function (e) {
        if (window.parent.$showdialog != undefined && window.parent.$showdialog != $showdialog) {
            window.parent.$showdialog(e)
            return;
        }

        var title = e.title == '' || e.title == null || e.title == undefined ? 'Msg' : e.title;
        var body = e.body;

        var width = e.width;
        var detail = "";
        var masklayout = $('<div class="dialog-mask" style="z-index:' + (showdialog_z_index++) + '"></div>');
        if (width == null || width == undefined) { width = "500px"; }

        var $masklayout = $(masklayout);
        $("body").append($masklayout);

        detail = '<div class="dialog-win" style="position:fixed;width:' + width + ';z-index:' + (showdialog_z_index++) + ';">';

        detail += '<div id="mydialog">';
        detail += '<div class="dialog">';
        detail += '<div class="dialog-head">';
        detail += '  <span class="close rotate-hover"></span>';
        detail += '  <strong>' + title + '</strong>';
        detail += '</div>';
        detail += '<div class="dialog-body">';
        detail += body;
        detail += '</div>';
        detail += '<div class="dialog-foot">';
        //detail += '  <button class="button dialog-close">鍙栨秷</button>';
        //detail += '  <button class="button bg-green btn_ok">纭</button>';
        detail += '</div>';
        detail += '</div>';
        detail += '</div>';


        detail = detail + '</div>';

        var win = $(detail);
        win.find(".dialog").addClass("open");
        $("body").append(win);
        var x = parseInt($(window).width() - win.outerWidth()) / 2;
        var y = parseInt($(window).height() - win.outerHeight()) / 2;
        if (y <= 10) { y = "10" }
        win.css({ "left": x, "top": y });
        win.find(".btn_ok,.close").click(function () {
            win.remove();
            $masklayout.remove();
            try {
                if (e.success != undefined) {
                    e.success();
                }
            } catch (exp) {
                console.error(exp);
            }
        });

        setTimeout(function () {
            win.find(".close").click();
        }, 3000);

    };

    $showdialogForConfim = function (e) {
        if (window.parent.$showdialogForConfim != undefined && window.parent.$showdialogForConfim != $showdialogForConfim) {
            window.parent.$showdialogForConfim(e)
            return;
        }

        var title = e.title == '' || e.title == null || e.title == undefined ? 'Msg' : e.title;
        var body = e.body;

        var width = e.width;
        var detail = "";
        var masklayout = $('<div class="dialog-mask" style="z-index:' + (showdialog_z_index++) + '"></div>');
        if (width == null || width == undefined) { width = "500px"; }

        var $masklayout = $(masklayout);
        $("body").append($masklayout);

        detail = '<div class="dialog-win" style="position:fixed;width:' + width + ';z-index:' + (showdialog_z_index++) + ';">';

        detail += '<div id="mydialog">';
        detail += '<div class="dialog">';
        detail += '<div class="dialog-head">';
        detail += '  <span class="close rotate-hover"></span>';
        detail += '  <strong>' + title + '</strong>';
        detail += '</div>';
        detail += '<div class="dialog-body">';
        detail += body;
        detail += '</div>';
        detail += '<div class="dialog-foot">';
        detail += '  <button class="button bg-green btn_ok">Confirm</button>';
        detail += '  <button class="button dialog-close">Cancel</button>';
        detail += '</div>';
        detail += '</div>';
        detail += '</div>';

        detail = detail + '</div>';

        var win = $(detail);
        win.find(".dialog").addClass("open");
        $("body").append(win);
        var x = parseInt($(window).width() - win.outerWidth()) / 2;
        var y = parseInt($(window).height() - win.outerHeight()) / 2;
        if (y <= 10) { y = "10" }
        win.css({ "left": x, "top": y });
        win.find(".dialog-close,.close").click(function () {
            win.remove();
            $masklayout.remove();
            if (e.cancel != undefined) {
                e.cancel();
            }
        });

        win.find(".btn_ok").click(function () {
            try {
                if (e.ok != undefined) {
                    var okrel = e.ok();
                    if (okrel != false) {
                        win.remove();
                        $masklayout.remove();
                    }
                }
            } catch (exp) {
                console.error(exp);
            }
            
        });

    };

    $showdialogForUrl = function (e) {

        if (window.parent.$showdialogForUrl != undefined && window.parent.$showdialogForUrl != $showdialogForUrl) {
            window.parent.$showdialogForUrl(e)
            return;
        }

        var _time = new Date().getTime();

        var width = e.width;
        var detail = "";
        var masklayout = $('<div class="dialog-mask" style="z-index:' + (showdialog_z_index++) + '"></div>');
        if (width == null || width == undefined) { width = "500px"; }

        if (e.height.indexOf('px' > -1)) {
            var maxHeight = parseInt(e.height);
            if (document.body.clientHeight - 150 < maxHeight) {
                maxHeight = document.body.clientHeight - 150;
                e.height = maxHeight + 'px';
            }

        }

        var $masklayout = $(masklayout);
        $("body").append($masklayout);

        detail = '<div class="dialog-win" style="position:fixed;width:' + width + ';z-index:' + (showdialog_z_index++) + ';">';

        detail += '<div id="mydialog">';
        detail += '<div class="dialog">';
        detail += '<div class="dialog-head">';
        detail += '  <span class="close rotate-hover"></span>';
        detail += '  <strong>' + e.title + '</strong>';
        detail += '</div>';
        detail += '<div>';
        detail += '<iframe id="c_' + e.pageid + '" name="c_' + e.pageid + '" scrolling="auto" frameborder="0"  src="' + e.url + '" style="width:100%;height:' + e.height + ';"></iframe>';
        detail += '</div>';
        detail += '<div class="dialog-foot">';

        if (e.buttons != undefined && e.buttons.length > 0) {
            for (var i in e.buttons) {
                detail += '  <button index="' + i + '" class="' + e.buttons[i].cls + '">' + e.buttons[i].txt + '</button>';
            }
        }

        detail += '</div>';
        detail += '</div>';
        detail += '</div>';


        detail = detail + '</div>';

        var win = $(detail);
        win.find(".dialog").addClass("open");
        $("body").append(win);
        var x = parseInt($(window).width() - win.outerWidth()) / 2;
        var y = parseInt($(window).height() - win.outerHeight()) / 2;
        if (y <= 10) { y = "10" }
        win.css({ "left": x, "top": y });

        // 鎺у埗寮圭獥灞傚璞�
        var _e = {};
        _e.close = function () {
            win.remove();
            $masklayout.remove();
        }
        // 鎸傝浇椤佃剼鎸夐挳浜嬩欢
        win.find('.button').click(function () {
            var i = $(this).attr('index');
            e.buttons[i].handler(_e);
        });

        win.find(".close").click(function () {
            _e.close();
        });

        return _e;

    };

    $('.tips').each(function () {
        var e = $(this);
        var title = e.attr("title");
        var trigger = e.attr("data-toggle");
        e.attr("title", "");
        if (trigger == "" || trigger == null) { trigger = "hover"; }
        if (trigger == "hover") {
            e.mouseover(function () {
                $showtips(e, title);
            });
        } else if (trigger == "click") {
            e.click(function () {
                $showtips(e, title);
            });
        } else if (trigger == "show") {
            e.ready(function () {
                $showtips(e, title);
            });
        }
    });
    $showtips = function (e, title) {
        var trigger = e.attr("data-toggle");
        var place = e.attr("data-place");
        var width = e.attr("data-width");
        var css = e.attr("data-style");
        var image = e.attr("data-image");
        var content = e.attr("content");
        var getid = e.attr("data-target");
        var data = e.attr("data-url");
        var x = 0;
        var y = 0;
        var html = "";
        var detail = "";

        if (image != null) { detail = detail + '<img class="image" src="' + image + '" />'; }
        if (content != null) { detail = detail + '<p class="tip-body">' + content + '</p>'; }
        if (getid != null) { detail = detail + $(getid).html(); }
        if (data != null) { detail = detail + $.ajax({ url: data, async: false }).responseText; }
        if (title != null && title != "") {
            if (detail != null && detail != "") { detail = '<p class="tip-title"><strong>' + title + '</strong></p>' + detail; } else { detail = '<p class="tip-line">' + title + '</p>'; }
        }
        detail = '<div class="tip">' + detail + '</div>';
        html = $(detail);

        $("body").append(html);
        if (width != null) {
            html.css("width", width);
        }
        if (place == "" || place == null) { place = "top"; }
        if (place == "left") {
            x = e.offset().left - html.outerWidth() - 5;
            y = e.offset().top - html.outerHeight() / 2 + e.outerHeight() / 2;
        } else if (place == "top") {
            x = e.offset().left - html.outerWidth() / 2 + e.outerWidth() / 2;
            y = e.offset().top - html.outerHeight() - 5;
        } else if (place == "right") {
            x = e.offset().left + e.outerWidth() + 5;
            y = e.offset().top - html.outerHeight() / 2 + e.outerHeight() / 2;
        } else if (place == "bottom") {
            x = e.offset().left - html.outerWidth() / 2 + e.outerWidth() / 2;
            y = e.offset().top + e.outerHeight() + 5;
        }
        if (css != "") { html.addClass(css); }
        html.css({ "left": x + "px", "top": y + "px", "position": "absolute" });
        if (trigger == "hover" || trigger == "click" || trigger == null) {
            e.mouseout(function () { html.remove(); e.attr("title", title) });
        }
    };
    $('.alert .close').each(function () {
        $(this).click(function () {
            $(this).closest('.alert').remove();
        });
    });
    $('.radio label').each(function () {
        var e = $(this);
        e.click(function () {
            e.closest('.radio').find("label").removeClass("active");
            e.addClass("active");
        });
    });
    $('.checkbox label').each(function () {
        var e = $(this);
        e.click(function () {
            if (e.find('input').is(':checked')) {
                e.addClass("active");
            } else {
                e.removeClass("active");
            };
        });
    });
    $('.collapse .panel-head').each(function () {
        var e = $(this);
        e.click(function () {
            e.closest('.collapse').find(".panel").removeClass("active");
            e.closest('.panel').addClass("active");
        });
    });
    $('.icon-navicon').each(function () {
        var e = $(this);
        var target = e.attr("data-target");
        e.click(function () {
            $(target).toggleClass("nav-navicon");
        });
    });
    $('.banner').each(function () {
        var e = $(this);
        var pointer = e.attr("data-pointer");
        var interval = e.attr("data-interval");
        var style = e.attr("data-style");
        var items = e.attr("data-item");
        var items_s = e.attr("data-small");
        var items_m = e.attr("data-middle");
        var items_b = e.attr("data-big");
        var num = e.find(".carousel .item").length;
        var win = $(window).width();
        var i = 1;

        if (interval == null) { interval = 5 };
        if (items == null || items < 1) { items = 1 };
        if (items_s != null && win > 760) { items = items_s };
        if (items_m != null && win > 1000) { items = items_m };
        if (items_b != null && win > 1200) { items = items_b };

        var itemWidth = Math.ceil(e.outerWidth() / items);
        var page = Math.ceil(num / items);
        e.find(".carousel .item").css("width", itemWidth + "px");
        e.find(".carousel").css("width", itemWidth * num + "px");

        var carousel = function () {
            i++;
            if (i > page) { i = 1; }
            $showbanner(e, i, items, num);
        };
        var play = setInterval(carousel, interval * 600);

        e.mouseover(function () { clearInterval(play); });
        e.mouseout(function () { play = setInterval(carousel, interval * 600); });

        if (pointer != 0 && page > 1) {
            var point = '<ul class="pointer"><li value="1" class="active"></li>';
            for (var j = 1; j < page; j++) {
                point = point + ' <li value="' + (j + 1) + '"></li>';
            };
            point = point + '</ul>';
            var pager = $(point);
            if (style != null) { pager.addClass(style); };
            e.append(pager);
            pager.css("left", e.outerWidth() * 0.5 - pager.outerWidth() * 0.5 + "px");
            pager.find("li").click(function () {
                $showbanner(e, $(this).val(), items, num);
            });
            var lefter = $('<div class="pager-prev icon-angle-left"></div>');
            var righter = $('<div class="pager-next icon-angle-right"></div>');
            if (style != null) { lefter.addClass(style); righter.addClass(style); };
            e.append(lefter);
            e.append(righter);

            lefter.click(function () {
                i--;
                if (i < 1) { i = page; }
                $showbanner(e, i, items, num);
            });
            righter.click(function () {
                i++;
                if (i > page) { i = 1; }
                $showbanner(e, i, items, num);
            });
        };
    });
    $showbanner = function (e, i, items, num) {
        var after = 0, leftx = 0;
        leftx = -Math.ceil(e.outerWidth() / items) * (items) * (i - 1);
        if (i * items > num) { after = i * items - num; leftx = -Math.ceil(e.outerWidth() / items) * (num - items); };
        e.find(".carousel").stop(true, true).animate({ "left": leftx + "px" }, 800);
        e.find(".pointer li").removeClass("active");
        e.find(".pointer li").eq(i - 1).addClass("active");
    };
    $(".spy a").each(function () {
        var e = $(this);
        var t = e.closest(".spy");
        var target = t.attr("data-target");
        var top = t.attr("data-offset-spy");
        var thistarget = "";
        var thistop = "";
        if (top == null) { top = 0; };
        if (target == null) { thistarget = $(window); } else { thistarget = $(target); };

        thistarget.bind("scroll", function () {
            if (target == null) {
                thistop = $(e.attr("href")).offset().top - $(window).scrollTop() - parseInt(top);
            } else {
                thistop = $(e.attr("href")).offset().top - thistarget.offset().top - parseInt(top);
            };

            if (thistop < 0) {
                t.find('li').removeClass("active");
                e.parents('li').addClass("active");
            };

        });
    });
    $(".fixed").each(function () {
        var e = $(this);
        var style = e.attr("data-style");
        var top = e.attr("data-offset-fixed");
        if (top == null) { top = e.offset().top; } else { top = e.offset().top - parseInt(top); };
        if (style == null) { style = "fixed-top"; };

        $(window).bind("scroll", function () {
            var thistop = top - $(window).scrollTop();
            if (style == "fixed-top" && thistop < 0) {
                e.addClass("fixed-top");
            } else {
                e.removeClass("fixed-top");
            };

            var thisbottom = top - $(window).scrollTop() - $(window).height();
            if (style == "fixed-bottom" && thisbottom > 0) {
                e.addClass("fixed-bottom");
            } else {
                e.removeClass("fixed-bottom");
            };
        });

    });

});

/**
* 浠庝笅闈㈠紑濮嬶紝鏄疢aster.Jiang鎵╁睍鐨勬嫾鍥続jax鏂规硶
*/
jQuery.PintuerPost = function (url, data, success, error, isIframe) {
    window.top.showLoading();
    $.ajax(
        {
            url: url,
            type: 'post',
            data: data,
            dataType: 'json',
            success: function (data) {
                window.top.hideLoading();
                if (data.state == 1) {
                    if (success != undefined) {
                        success(data);
                    }
                } else {
                    if (error != undefined) {
                        error(data);
                    } else if (isIframe == true) {
                        $showdialog({
                            title: '',
                            body: data.txt,
                            width: '90%'
                        });
                    } else {
                        $showdialog({ body: data.txt });
                    }
                }
            },
            error: function () {
                window.top.hideLoading();
                if (error != undefined) {
                    error();
                } else {
                    if (isIframe == true) {
                        $showdialog({
                            title: '',
                            body: 'Conmunication Error',
                            width: '80%'
                        });
                    } else {
                        $showdialog({ body: 'Conmunication Error' });
                    }

                }
            }
        }
    );
};


/**
* 浠庝笅闈㈠紑濮嬶紝鏄疢aster.Jiang鎵╁睍鐨勬嫾鍥炬暟鎹〃鏍兼彃浠�
*/
function PagingBar() { };
PagingBar.fn = PagingBar.prototype;
PagingBar.fn.prev = undefined;
PagingBar.fn.page = undefined;
PagingBar.fn.next = undefined;
PagingBar.fn.index = undefined;
PagingBar.fn.go = undefined;

function PintuerDataGrid() { };
PintuerDataGrid.fn = PintuerDataGrid.prototype;
PintuerDataGrid.fn.jq_obj = undefined;
PintuerDataGrid.fn.total = 0;
PintuerDataGrid.fn.rows = 10;
PintuerDataGrid.fn.page = 1;
PintuerDataGrid.fn.total = 0;
PintuerDataGrid.fn.url = '';
PintuerDataGrid.fn.paging = false;
PintuerDataGrid.fn.pagingBar = undefined;
PintuerDataGrid.fn.rowsData = undefined;
PintuerDataGrid.fn.QueryParams = function () {
    return {};
};
PintuerDataGrid.fn.LineFormatter = function (dr) {
    return '';
};
PintuerDataGrid.fn.LoadComplete = function (dr) {

};
PintuerDataGrid.fn.LoadData = function () {
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
                $showdialog({ body: 'Conmunication Error' });
            }
        }
    );
};
PintuerDataGrid.fn.Load = function () {
    this.page = 1;
    this.LoadData();
};
PintuerDataGrid.fn.LoadPage = function (page) {
    var maxPage = this.total < 1 ? 1 : Math.ceil(this.total / this.rows);
    if (maxPage < page || 1 > page) {
        $showdialog({ body: 'Invalid, input again锛�' });
        return;
    }
    this.page = page;
    this.LoadData();
};
PintuerDataGrid.fn.LoadPrev = function () {
    if (this.page > 1) {
        this.page = this.page - 1;
        this.LoadData();
    }
};
PintuerDataGrid.fn.LoadNext = function () {
    var maxPage = this.total < 1 ? 1 : Math.ceil(this.total / this.rows);
    if (maxPage > this.page) {
        this.page = this.page + 1;
        this.LoadData();
    }
};
// 灏嗘嫾鍥捐〃鏍兼墿灞曚负jQuery鐨勬彃浠�
jQuery.fn.pintuerDataGrid = function (e) {
    var pdg = new PintuerDataGrid();
    pdg.jq_obj = this;
    if (e.rows != undefined) {
        pdg.rows = e.rows
    }
    if (e.page != undefined) {
        pdg.page = e.page
    }
    if (e.paging == true) {
        pdg.paging = true;

        // 鏀惧叆鍒嗛〉footbar
        var footHtml = '';
        footHtml += '        <div class="form-inline" >\n';
        footHtml += '            <button class="button icon-caret-left paging_prev" type="button"></button>';
        footHtml += '            <label class="paging_page">1/1</label>';
        footHtml += '            <button class="button icon-caret-right paging_next" type="button"></button>';
        footHtml += '            <input type="text" class="input input-auto paging_index" style="width:40px; text-align:center;" />';
        footHtml += '            <button class="button icon-anchor paging_go" type="button">&nbsp;&nbsp;Skip</button>';
        footHtml += '        </div>';

        this.find('.paging').html(footHtml);

        var pagingBar = new PagingBar();

        pagingBar.prev = this.find('.paging_prev');
        pagingBar.page = this.find('.paging_page');
        pagingBar.next = this.find('.paging_next');
        pagingBar.index = this.find('.paging_index');
        pagingBar.go = this.find('.paging_go');

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

/**
* 浠庝笅闈㈠紑濮嬶紝鏄疢aster.Jiang鎵╁睍鐨勬嫾鍥惧崟閫夋彃浠�
*/
jQuery.fn.pintuerRadio = function (fn, e) {
    if (fn == 'init') {
        this.addClass('button-group radio');
        var html = '';
        for (var i in e.items) {
            var item = e.items[i];
            html += '<label class="button"><input name="' + this.attr('id') + '" value="' + item.val + '" type="radio">';
            html += '<span class="icon ' + item.cls + '"></span>' + item.txt + '</label>';
        }
        this.html(html);
        if (e.readonly != true) {
            //  杩欓噷搴旇閲嶆柊娓叉煋椤甸潰
        }
    } else if (fn == 'setValue') {
        this.find('label').removeClass('active');
        this.find("input[name='" + this.attr('id') + "']").attr('checked', false);
        var item = this.find("input[type='radio'][value='" + e + "']");
        item[0].checked = true;

        item.parent().addClass('active');
    }
};

jQuery.fn.pintuerBooleanRadio = function (val) {
    if (val == true || val == 'true') {
        val = 1;
    } else if (val == false || val == 'false') {
        val = 0;
    }
    if (!this.hasClass('radio')) {
        this.pintuerRadio('init', {
            items: [
                    { val: 1, cls: 'icon-check text-green', txt: 'Yes' },
                    { val: 0, cls: 'icon-times', txt: 'No' }
            ]
        });
    }
    this.pintuerRadio('setValue', val);
};

/**
* 浠庝笅闈㈠紑濮嬶紝鏄疢aster.Jiang鎵╁睍鐨勬嫾鍥炬爲
*/
function PintuerJsTree() { };
PintuerJsTree.fn = PintuerJsTree.prototype;
PintuerJsTree.fn.jq_obj = undefined;
PintuerJsTree.fn.listNode = undefined;
PintuerJsTree.fn.root = undefined;
PintuerJsTree.fn.FindTreeNodeById = function (id) {
    var pjt = this;
    return pjt.listNode[id];
};
PintuerJsTree.fn.FindTreeRootNode = function () {
    var pjt = this;
    return pjt.root;
};

jQuery.fn.pintuerTree = function (setting) {
    var pjt = new PintuerJsTree();
    pjt.jq_obj = this;

    var jstree = this;
    jstree.addClass('pintuer_tree');
    var jstreeid = jstree.attr('id');

    var root = new Array();
    var listNode = new Array();
    for (var i in setting.nodes) {
        var node = setting.nodes[i];
        listNode[node.id] = node;
    }

    pjt.root = root;
    pjt.listNode = listNode;

    for (var i in setting.nodes) {
        var node = setting.nodes[i];
        var parent = listNode[node.pid];
        if (parent == undefined) {
            root.push(node);
        } else {
            if (parent.children == undefined) {
                parent.children = new Array();
            }
            parent.children.push(node);
        }

    }

    var generateTree = function (node) {
        var _html = '';
        _html += '        <li>';
        _html += '            <div class="item">';
        if (node.children != undefined && node.children.length > 0) {
            _html += '                <i class="icon-caret-right"></i>';
        } else {
            _html += '                <i class="text-blue icon-paperclip"></i>';
        }
        _html += '                <a jstreeid="' + node.id + '">' + node.name + '</a>';

        if (setting.expand != undefined) {
            _html += setting.expand;
        }

        _html += '            </div>';

        if (node.children != undefined && node.children.length > 0) {
            _html += '    <ul class="children">';
            for (var i in node.children) {
                _html += generateTree(node.children[i]);
            }
            _html += '    </ul>';
        }
        _html += '        </li>';
        return _html;
    };

    var html = '';
    html += '    <ul>';
    for (var i in root) {
        html += generateTree(root[i]);
    }
    html += '    </ul>';

    jstree.html(html);

    $('.pintuer_tree a').click(function () {
        var a = $(this);
        var i = a.prev();
        var ul = a.parent().next();
        if (i.hasClass('icon-caret-right')) {
            // 濡傛灉褰撳墠鏄殣钘忕姸鎬侊紝鍒欐墽琛屽睍寮€瀛愯彍鍗曟搷浣�
            i.removeClass('icon-caret-right');
            i.addClass('icon-caret-down');
            ul.css('display', 'block');
        }

    });

    $('.pintuer_tree i').click(function () {
        var i = $(this);
        var ul = i.parent().next();

        if (i.hasClass('icon-caret-down')) {
            // 濡傛灉褰撳墠鏄睍寮€鐘舵€侊紝鍒欐墽琛岄殣钘忓瓙鑿滃崟鎿嶄綔
            i.removeClass('icon-caret-down');
            i.addClass('icon-caret-right');
            ul.css('display', 'none');
        } else if (i.hasClass('icon-caret-right')) {
            // 濡傛灉褰撳墠鏄殣钘忕姸鎬侊紝鍒欐墽琛屽睍寮€瀛愯彍鍗曟搷浣�
            i.removeClass('icon-caret-right');
            i.addClass('icon-caret-down');
            ul.css('display', 'block');
        }

    });

    jstree.find('a').click(function () {
        jstree.find('a').parent().removeClass('clicked');
        $(this).parent().addClass('clicked');
        if (setting.onNodeClick != undefined) {
            var jstreeid = $(this).attr('jstreeid');
            setting.onNodeClick(jstreeid, listNode[jstreeid]);
        }
    });

    if (setting.expand_callback != undefined) {
        setting.expand_callback(jstree);
    }

    return pjt;
};
// 鐢变簬蹇樿鏈変粈涔堢敤锛屽苟涓旇繖浠ｇ爜璧峰埌涓嶅ソ鐨勪綔鐢紝鎵€浠ユ敞閲婃帀浜�
///**
//* 鎶勬潵鐨勮緭鍏ユ鍏夋爣鎺у埗鎵╁睍
//* 鐢ㄦ硶锛氳浣嶇疆 alert($(this).position());  璁剧疆浣嶇疆锛� $(this).position(4);
//*/
//$.fn.extend({
//    position: function (value) {
//        var elem = this[0];
//        if (elem && (elem.tagName == "TEXTAREA" || (elem.type != undefined && elem.type.toLowerCase() == "text"))) {
//            if ($.browser && $.browser.msie) {
//                var rng;
//                if (elem.tagName == "TEXTAREA") {
//                    rng = event.srcElement.createTextRange();
//                    rng.moveToPoint(event.x, event.y);
//                } else {
//                    rng = document.selection.createRange();
//                }
//                if (value === undefined) {
//                    rng.moveStart("character", -event.srcElement.value.length);
//                    return rng.text.length;
//                } else if (typeof value === "number") {
//                    var index = this.position();
//                    index > value ? (rng.moveEnd("character", value - index)) : (rng.moveStart("character", value - index))
//                    rng.select();
//                }
//            } else {
//                if (value === undefined) {
//                    return elem.selectionStart;
//                } else if (typeof value === "number") {
//                    elem.selectionEnd = value;
//                    elem.selectionStart = value;
//                }
//            }
//        } else {
//            if (value === undefined)
//                return undefined;
//        }
//    }
//});


var mvcParamMatch = (function () {
    var MvcParameterAdaptive = {};
    //楠岃瘉鏄惁涓烘暟缁�
    MvcParameterAdaptive.isArray = Function.isArray || function (o) {
        return typeof o === "object" &&
                Object.prototype.toString.call(o) === "[object Array]";
    };

    //灏嗘暟缁勮浆鎹负瀵硅薄
    MvcParameterAdaptive.convertArrayToObject = function (/*鏁扮粍鍚�*/arrName, /*寰呰浆鎹㈢殑鏁扮粍*/array, /*杞崲鍚庡瓨鏀剧殑瀵硅薄锛屼笉鐢ㄨ緭鍏�*/saveOjb) {
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

    //杞崲瀵硅薄
    MvcParameterAdaptive.convertObject = function (/*瀵硅薄鍚�*/objName, /*寰呰浆鎹㈢殑瀵硅薄*/turnObj, /*杞崲鍚庡瓨鏀剧殑瀵硅薄锛屼笉鐢ㄨ緭鍏�*/saveOjb) {
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
        if (typeof json !== "object") throw new Error("Input json object");
        if (MvcParameterAdaptive.isArray(json) && !arrName) throw new Error("Specify array name锛�");

        if (MvcParameterAdaptive.isArray(json)) {
            return MvcParameterAdaptive.convertArrayToObject(arrName, json);
        }
        return MvcParameterAdaptive.convertObject("", json);
    };
})();

function PintuerPagePanel() { };
PintuerPagePanel.fn = PintuerPagePanel.prototype;
PintuerPagePanel.fn.jq_obj = undefined;
PintuerPagePanel.fn.url = '';
PintuerPagePanel.fn.isEnd = false;
PintuerPagePanel.fn.rows = 10;
PintuerPagePanel.fn.page = 1;
PintuerPagePanel.fn.lastID = '';
PintuerPagePanel.fn.isAsc = false;
PintuerPagePanel.fn.QueryParams = function () {
    return {};
};
PintuerPagePanel.fn.LineFormatter = function () {
    return '';
};
PintuerPagePanel.fn.LoadComplete = function (dr) { };
PintuerPagePanel.fn.LoadData = function () {
    var postdata = this.QueryParams();
    if (postdata == false)
        return;
    postdata.rows = this.rows;
    postdata.page = this.page;

    var that = this;

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
                    that.page++;
                    var pagepanel = that.jq_obj.find('.pintuer_pagepanel');

                    for (var i in data.rows) {
                        var dr = data.rows[i];
                        var innerhtml = that.LineFormatter(dr, that);
                        if (that.isAsc) {
                            pagepanel.append(innerhtml);
                        } else {
                            pagepanel.prepend(innerhtml);
                        }
                    }
                    that.LoadComplete();
                    if (data.rows.length == 0 && postdata.page > 1) {
                        $showdialog({ body: 'No more' });
                    }
                } else {
                    $showdialog({ body: data.txt });
                }
            },
            error: function () {
                window.top.hideLoading();
                $showdialog({ body: 'Conmunication Error' });
            }
        }
    );
};
PintuerPagePanel.fn.Load = function () {
    this.page = 1;
    this.jq_obj.find('.pintuer_pagepanel').html('');
    this.LoadData();
};
PintuerPagePanel.fn.AppendSendMessage = function (html) {
    var pagepanel = this.jq_obj.find('.pintuer_pagepanel');
    if (this.isAsc) {
        pagepanel.prepend(html);
    } else {
        pagepanel.append(html);
    }
};

jQuery.fn.pintuerPagePanel = function (e) {
    var pagePanel = new PintuerPagePanel();
    pagePanel.jq_obj = this;
    if (e.rows != undefined) {
        pagePanel.rows = e.rows
    }
    if (e.isAsc != undefined) {
        pagePanel.isAsc = e.isAsc;
    }
    pagePanel.url = e.url;

    pagePanel.jq_obj.find('.pintuer_pagepanel').html('');
    pagePanel.jq_obj.find('.pintuer_pageloading a').unbind();
    pagePanel.jq_obj.find('.pintuer_pageloading a').click(function () {
        pagePanel.LoadData();
    });
    return pagePanel;
};
