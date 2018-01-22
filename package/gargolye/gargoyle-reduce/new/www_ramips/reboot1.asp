<%
eval $( gargoyle_session_validator -c "$COOKIE_hash" -e "$COOKIE_exp" -a "$HTTP_USER_AGENT" -i "$REMOTE_ADDR" -r "login1.asp" -t $(uci get gargoyle.global.session_timeout) -b "$COOKIE_browser_time"  )
#echo ""
lang=`uci get gargoyle.global.lang`
. /www/data/lang/$lang/reboot.po
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title>AP client</title>
    <script type="text/javascript" src="/jjs/jquery.js"></script>
    <link rel="stylesheet" href="/jjs/plugin/pintuer/pintuer.css" />
    <script type="text/javascript" src="/jjs/plugin/pintuer/pintuer.js"></script>
    <link rel="stylesheet" type="text/css" href="css/layout.css" />
    <link rel="stylesheet" type="text/css" href="css/form.css" />

    <script type="text/javascript" src="jjs/plugin/jedate/jquery.jedate.min.js"></script>
    <link type="text/css" rel="stylesheet" href="jjs/plugin/jedate/skin/jedate.css">

    <script type="text/javascript">
    var restart_type = 0;
    $(function () {
    $.get('/cgi-bin/reboot.sh?type=get', {}, function (d) {
          switch(d.reboottype) {
                case 'none':
                    $('input[name="restart_type"]:eq(0)').click();
                  //  $('#calendar0').val(d.val);
                    break;
                case 'day':
                    $('input[name="restart_type"]:eq(1)').click();
                  //  $('#calendar1').val(d.val);
                    break;
                case 'week':
                    $('input[name="restart_type"]:eq(2)').click();
                //    $('#calendar2').val(d.val2);
                //    var week_selected = d.val.split(' ');
                var week_selected;
                    for (var i in week_selected) {
                        $('input[name="week"][value="' + week_selected[i] + '"]')[0].checked = true;
                    }
                    break;
            }
        }, 'json');


        $('input[name="restart_type"]').click(function() {
            restart_type = $(this).val();
            $('form').hide();
            $('#form' + restart_type).show();
        });

        $('input[name="restart_type"]:eq(0)').click();

        $("#calendar0").jeDate({
            isinitVal:false,
            festival:true,
            ishmsVal:false,
            minDate: '2010-01-11 23:59:59',
            maxDate: '2110-01-11 23:59:59',
            format:"YYYY-MM-DD hh:mm:ss"
        });

        $("#calendar1").jeDate({
            isinitVal:false,
            festival:true,
            ishmsVal:false,
            minDate: $.nowDate(0),
            maxDate: $.nowDate(0),
            format:"hh:mm:ss"
        });

        $("#calendar2").jeDate({
            isinitVal:false,
            festival:true,
            ishmsVal:false,
            minDate: $.nowDate(0),
            maxDate: $.nowDate(0),
            format:"hh:mm:ss"
        });
    });

    function submit0() {
        var post = {
            "type": 'none',
            };
      //  var json = JSON.stringify(post);
        submit_com(post);
    }
    function submit1() {
        var post = {
            "type": 'day',
            "time": $('#calendar1').val()
        };

      //  var json = JSON.stringify(post);
        submit_com(post);
    }

    function submit2() {
        var week_selected = new Array();
        $('input[name="week"]:checked').each(function() {
            week_selected.push($(this).val());
        });
        if (week_selected.length < 1) {
            $showdialog({body: 'Failed, choose a date'});
            return;
        }

        week_selected = week_selected.toString();
        week_selected = week_selected.replace(new RegExp(',',"gm"), ' ');
        var post = {
            "type": 'week',
            "week": week_selected,
            "time": $('#calendar2').val()
        };

        //var json = JSON.stringify(post);

        submit_com(post);
    }

    function submit_com(json) {
        $.post('/cgi-bin/reboot.sh',  json , function (d) {
          if (d.type==undefined){
            $("#status").html("<%= $error%>");
            }else{
              $("#status").html("<%= %finish%>");
            }
         }, 'json');
    }

 function rebootnow()
  {
  //var form = new FormData(document.getElementById("form1"));
           $.ajax({
          url: "/cgi-bin/reboot.sh?boot=now",
          type: "get",
        //  data:form, 
          processData:false,
          contentType:false,
         // contentType: "application/json; charset=utf-8",
          success: function(json) {
             if (json.rebootnow==undefined){
             $("#status").html("<%= $error%>");
             }else{
                $("#status").html("<%= $reboot%>");
             }
          },
        });
}




    </script>
    <style type="text/css">
    .current{
    height:50px;width:100%;background:#fff;color:#000;border-bottom:solid #e3e9ed 1px;font-size:14px;line-height:50px;text-indent:20px;
     }
    </style>
</head>
<body>
  <div class="current"><%= $location%></div>
    <div class="wrap-main" style="position: relative;min-height: 100%;">
        <div class="wrap">
            <div class="title"><%= $page%><p style="display:inline;color:#e81717;font-size:x-large;margin-left: 100px;" id="status"></p></div>
            <div class="wrap-form">

                <div class="tab">
                    <div class="tab-head">
                        <ul id="tabpanel1" class="tab-nav">
                            <li class="active">
                                <a href="#tab-1"><%= $reboot_now%></a>
                            </li>
                            <li>
                                <a href="#tab-2"><%= $reboot_sche%></a>
                            </li>
                        </ul>
                    </div>
                    <div class="tab-body ">
                      <div class="tab-panel active" id="tab-1" style="padding: 15px;">
    										  <div class="btn-wrap">
    					              <div class="save-btn fr"><a href="javascript:rebootnow()"><%= $reboot_now%></a></div>
    					            </div>
                      </div>
                        <div class="tab-panel" id="tab-2">

                          <div>
                              <input type="radio" value="0" name="restart_type"/><%= $dis_sche%>
                              &nbsp;&nbsp;&nbsp;&nbsp;
                              <input type="radio" value="1" name="restart_type"/><%= $everyday%>
                              &nbsp;&nbsp;&nbsp;&nbsp;
                              <input type="radio" value="2" name="restart_type"/><%= $everyweek%>
                          </div>

                          <form id="form0">
                              <div class="btn-wrap">
                              <div class="save-btn fr"><a href="javascript:submit0()"><%= $save%></a></div>
                              </div>
                          </form>
                          <form id="form1">
                              时间
                              <input type="text" value="<% uci get system.@system[0].time %>" class="input input-auto" name="time1" id="calendar1" readonly="readonly" /><br /><br />


                              <div class="btn-wrap">
                              <div class="save-btn fr"><a href="javascript:submit1()"><%= $save%></a></div>
                              </div>
                          </form>
                          <form id="form2">
                              <div style="padding-bottom: 25px;">
                                  <input type="checkbox" value="1" name="week" <% [ "`uci get system.@system[0].week |grep 1`" ] && echo "checked" %> /><%= $mon%>&nbsp;&nbsp;
                                  <input type="checkbox" value="2" name="week" <% [ "`uci get system.@system[0].week |grep 2`" ] && echo "checked" %> /><%= $tue%>&nbsp;&nbsp;
                                  <input type="checkbox" value="3" name="week" <% [ "`uci get system.@system[0].week |grep 3`" ] && echo "checked" %> /><%= $wed%>&nbsp;&nbsp;
                                  <input type="checkbox" value="4" name="week" <% [ "`uci get system.@system[0].week |grep 4`" ] && echo "checked" %> /><%= $thur%>&nbsp;&nbsp;
                                  <input type="checkbox" value="5" name="week" <% [ "`uci get system.@system[0].week |grep 5`" ] && echo "checked" %> /><%= $fri%>&nbsp;&nbsp;
                                  <input type="checkbox" value="6" name="week" <% [ "`uci get system.@system[0].week |grep 6`" ] && echo "checked" %> /><%= $sat%>&nbsp;&nbsp;
                                  <input type="checkbox" value="7" name="week" <% [ "`uci get system.@system[0].week |grep 7`" ] && echo "checked" %> /><%= $sun%>
                              </div>

                              时间
                              <input type="text" class="input input-auto" value="<% uci get system.@system[0].time %>" name="time2" id="calendar2" readonly="readonly" /><br /><br />
                              <div class="btn-wrap">
                              <div class="save-btn fr"><a href="javascript:submit2()"><%= $save%></a></div>
                              </div>
                          </form>

                        </div>
                    </div>
                </div>
           </div>
        </div>
    </div>
</body>
</html>
