<%
eval $( gargoyle_session_validator -c "$COOKIE_hash" -e "$COOKIE_exp" -a "$HTTP_USER_AGENT" -i "$REMOTE_ADDR" -r "login1.asp" -t $(uci get gargoyle.global.session_timeout) -b "$COOKIE_browser_time"  )
#echo ""
lang=`uci get gargoyle.global.lang`
. /www/data/lang/$lang/time.po
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <script type="text/javascript" src="/jjs/jquery.js"></script>
    <link rel="stylesheet" href="/jjs/plugin/pintuer/pintuer.css" />
    <script type="text/javascript" src="/jjs/plugin/pintuer/pintuer.js"></script>
    <link rel="stylesheet" type="text/css" href="css/layout.css" />
    <link rel="stylesheet" type="text/css" href="css/form.css" />

    <script type="text/javascript" src="/jjs/plugin/iPath1/iPath.js"></script>
    <link rel="stylesheet" type="text/css" href="/jjs/plugin/iPath1/iPath.css" />
    <script type="text/javascript" src="jjs/plugin/iPath1/validate.js"></script>
    <script type="text/javascript" src="/jjs/plugin/pintuer/respond.js"></script>

    <script type="text/javascript" src="jjs/plugin/jedate/jquery.jedate.min.js"></script>
    <link type="text/css" rel="stylesheet" href="jjs/plugin/jedate/skin/jedate.css">


    <script type="text/javascript">
    function saveTimeZone(){
      $("#status").html("<%= $processing%>");
    var form = new FormData(document.getElementById("form1"));
        $.ajax({
       url: "/cgi-bin/settimezone.sh",
       type: "POST",
       data: form, 
       processData:false,
       contentType:false,
       success: function(json) {
          if (json.timezone==undefined){
          $("#status").html("<%= $error%>");
          }else{
          $("#status").html("<%= $finish_zone%>："+json.timezone+"！");
          }
       },
       error: function(error) {
         //alert("调用出错" + error.responseText);
       }
     });

    }

    function getsystime(){
           $.ajax({
          url: "/cgi-bin/systime.sh",
          type: "get",
          //data: form, 
          cache: false,
          processData:false,
          contentType:false,
          success: function(json) {
             if (json.time==undefined){
             $("#now")[0].value="<%= $finish_time%>";
             }else{
                $("#now")[0].value=json.time;
             }
          },
        });
    }


    function systime(){
         //$("#status").html("正在上传并升级固件！");
       var form = new FormData(document.getElementById("form0"));
           $.ajax({
          url: "/cgi-bin/systime.sh",
          type: "POST",
          data: form, 
          processData:false,
          contentType:false,
          success: function(json) {
             if (json.time==undefined){
             $("#now")[0].value="<%= $finish_time%>";
             }else{
                $("#now")[0].value=json.time;
             }

          },
          error: function(error) {
            //alert("调用出错" + error.responseText);
          }
        });

    }

    $(function () {
     //使能 jedate
        $("#settime").jeDate({
        format: "YYYY-MM-DD hh:mm:ss"
        });

       //使能 jedate
        $("#settime").jeDate({
        format: "YYYY-MM-DD hh:mm:ss"
        });
      //从系统取得时间
          getsystime();
          setInterval(getsystime,1000);
    });


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
                                <a href="#tab-1"><%= $systime%></a>
                            </li>
                            <li>
                                <a href="#tab-2"><%= $timezone%></a>
                            </li>
                        </ul>
                    </div>
                    <div class="tab-body ">
                   <div class="tab-panel active" id="tab-1" style="padding: 15px;">
                 <form class="form-info" id="form0">
                                <label>
                                    <div class="name"><%= $cur_time%>：</div>
                                    <div>
                                        <input id="now" type="text"  readonly="readonly" value="<% date "+%Y-%m-%d %H:%M:%S" %>" />
                                    </div>
                                </label>
                                <label>
                                    <div class="name"><%= $set_time%>：</div>
                                    <div>
                                       <input id="settime" name="settime" type="text"  />
                                    </div>
                                </label>
                            </form>
										  <div class="btn-wrap">
					            <div class="save-btn fr"><a href="javascript:systime()"><%= $save%></a></div>
					            </div>

                    </div>
                        <div class="tab-panel" id="tab-2">
                         <form class="form-info" id="form1">
                                <label>
                                    <div class="name"><%= $cur_zone%>：</div>
                                    <div>
                                        <select class="input input-auto" id="timezone" name="timezone">
      <option value="UTC-10:00 TiZ.UTC10 UTC10" <% [ "`uci get system.@system[0].zonename |grep TiZ.UTC10 `" ] && echo selected  %>>UTC-10:00 TiZ.UTC10</option>
      <option value="UTC-12:00 TiZ.UTC12 UTC12" <% [ "`uci get system.@system[0].zonename |grep TiZ.UTC12 `" ] && echo selected  %>>UTC-12:00 TiZ.UTC12</option>
      <option value="UTC-11:00 TiZ.UTC11 UTC11" <% [ "`uci get system.@system[0].zonename |grep TiZ.UTC11 `" ] && echo selected  %>>UTC-11:00 TiZ.UTC11</option>
      <option value="UTC-09:00 TiZ.NAST9 NAST9NADT,M3.2.0/2,M11.1.0/2" <% [ "`uci get system.@system[0].zonename |grep TiZ.NAST9 `" ] && echo selected  %>>UTC-09:00 TiZ.NAST9</option>
      <option value="UTC-08:00 TiZ.PST8 PST8PDT,M3.2.0/2,M11.1.0/2" <% [ "`uci get system.@system[0].zonename |grep TiZ.PST8 `" ] && echo selected  %>>UTC-08:00 TiZ.PST8</option>
      <option value="UTC-07:00 TiZ.UTC7 UTC7" <% [ "`uci get system.@system[0].zonename |grep TiZ.UTC7 `" ] && echo selected  %>>UTC-07:00 TiZ.UTC7</option>
      <option value="UTC-07:00 TiZ.MST7 MST7MDT,M3.2.0/2,M11.1.0/2" <% [ "`uci get system.@system[0].zonename |grep TiZ.MST7 `" ] && echo selected  %>>UTC-07:00 TiZ.MST7</option>
      <option value="UTC-06:00 TiZ.UTC6 UTC6" <% [ "`uci get system.@system[0].zonename |grep TiZ.UTC6 `" ] && echo selected  %>>UTC-06:00 TiZ.UTC6</option>
      <option value="UTC-06:00 TiZ.CST6 CST6CDT,M3.2.0/2,M11.1.0/2" <% [ "`uci get system.@system[0].zonename |grep TiZ.CST6 `" ] && echo selected  %>>UTC-06:00 TiZ.CST6</option>
      <option value="UTC-05:00 TiZ.UTC5 UTC5" <% [ "`uci get system.@system[0].zonename |grep TiZ.UTC5 `" ] && echo selected  %>>UTC-05:00 TiZ.UTC5</option>
      <option value="UTC-05:00 TiZ.EST5 EST5EDT,M3.2.0/2,M11.1.0/2" <% [ "`uci get system.@system[0].zonename |grep TiZ.EST5 `" ] && echo selected  %>>UTC-05:00 TiZ.EST5</option>
      <option value="UTC-04:00 TiZ.UTC4 UTC4" <% [ "`uci get system.@system[0].zonename |grep TiZ.UTC4 `" ] && echo selected  %>>UTC-04:00 TiZ.UTC4</option>
      <option value="UTC-04:00 TiZ.AST4 AST4ADT,M3.2.0/2,M11.1.0/2" <% [ "`uci get system.@system[0].zonename |grep TiZ.AST4 `" ] && echo selected  %>>UTC-04:00 TiZ.AST4</option>
      <option value="UTC-04:00 TiZ.BRW BRWST4BRWDT,M10.3.0/0,M2.5.0/0" <% [ "`uci get system.@system[0].zonename |grep TiZ.BRW  `" ] && echo selected  %>>UTC-04:00 TiZ.BRW</option>
      <option value="UTC-03:30 TiZ.NST3 NST3:30NDT,M3.2.0/0:01,M11.1.0/0:01" <% [ "`uci get system.@system[0].zonename |grep TiZ.NST3 `" ] && echo selected  %>>UTC-03:30 TiZ.NST3</option>
      <option value="UTC-03:00 TiZ.WGST WGST3WGDT,M3.5.6/22,M10.5.6/23" <% [ "`uci get system.@system[0].zonename |grep TiZ.WGST  `" ] && echo selected  %>>UTC-03:00 TiZ.WGST</option>
      <option value="UTC-03:00 TiZ.BRS BRST3BRDT,M10.3.0/0,M2.5.0/0" <% [ "`uci get system.@system[0].zonename |grep TiZ.BRS `" ] && echo selected  %>>UTC-03:00 TiZ.BRS</option>
      <option value="UTC-03:00 TiZ.UTC3 UTC3" <% [ "`uci get system.@system[0].zonename |grep TiZ.UTC3 `" ] && echo selected  %>>UTC-03:00 TiZ.UTC3</option>
      <option value="UTC-02:00 TiZ.UTC2 UTC2" <% [ "`uci get system.@system[0].zonename |grep TiZ.UTC2 `" ] && echo selected  %>>UTC-02:00 TiZ.UTC2</option>
      <option value="UTC-01:00 TiZ.STD1 STD1DST,M3.5.0/2,M10.5.0/2" <% [ "`uci get system.@system[0].zonename |grep TiZ.STD1 `" ] && echo selected  %>>UTC-01:00 TiZ.STD1</option>
      <option value="UTC+00:00 TiZ.UTC0 UTC0" <% [ "`uci get system.@system[0].zonename |grep TiZ.UTC0 `" ] && echo selected  %>>UTC+00:00 TiZ.UTC0</option>
      <option value="UTC+00:00 TiZ.GMT0 GMT0BST,M3.5.0/2,M10.5.0/2" <% [ "`uci get system.@system[0].zonename |grep TiZ.GMT0 `" ] && echo selected  %>>UTC+00:00 TiZ.GMT0</option>
      <option value="UTC+01:00 TiZ.UTCm1 UTC-1" <% [ "`uci get system.@system[0].zonename |grep  `" ] && echo selected  %>>UTC+01:00 TiZ.UTCm1</option>
      <option value="UTC+02:00 TiZ.STDm2 STD-2DST,M3.5.0/2,M10.5.0/2" <% [ "`uci get system.@system[0].zonename |grep TiZ.UTCm1 `" ] && echo selected  %>>UTC+02:00 TiZ.STDm2</option>
      <option value="UTC+01:00 TiZ.CETm1 CET-1CEST,M3.5.0/2,M10.5.0/3" <% [ "`uci get system.@system[0].zonename |grep TiZ.CETm1 `" ] && echo selected  %>>UTC+01:00 TiZ.CETm1</option>
      <option value="UTC+02:00 TiZ.UTCm2 UTC-2" <% [ "`uci get system.@system[0].zonename |grep TiZ.UTCm2 `" ] && echo selected  %>>UTC+02:00 TiZ.UTCm2</option>
      <option value="UTC+03:00 TiZ.UTCm3 UTC-3" <% [ "`uci get system.@system[0].zonename |grep TiZ.UTCm3 `" ] && echo selected  %>>UTC+03:00 TiZ.UTCm3</option>
      <option value="UTC+03:00 TiZ.EETm2 EET-2EEST-3,M3.5.0/3,M10.5.0/4" <% [ "`uci get system.@system[0].zonename |grep TiZ.EETm2 `" ] && echo selected  %>>UTC+03:00 TiZ.EETm2</option>
      <option value="UTC+03:30 TiZ.IRST IRST-3:30IRDT,80/0,264/0" <% [ "`uci get system.@system[0].zonename |grep TiZ.IRST `" ] && echo selected  %>>UTC+03:30 TiZ.IRST</option>
      <option value="UTC+04:00 TiZ.UTCm4 UTC-4" <% [ "`uci get system.@system[0].zonename |grep TiZ.UTCm4 `" ] && echo selected  %>>UTC+04:00 TiZ.UTCm4</option>
      <option value="UTC+05:00 TiZ.UTCm5 UTC-5" <% [ "`uci get system.@system[0].zonename |grep TiZ.UTCm5 `" ] && echo selected  %>>UTC+05:00 TiZ.UTCm5</option>
      <option value="UTC+05:30 TiZ.UTCm5c3 UTC-5:30" <% [ "`uci get system.@system[0].zonename |grep TiZ.UTCm5c3 `" ] && echo selected  %>>UTC+05:30 TiZ.UTCm5c3</option>
      <option value="UTC+06:00 TiZ.UTCm6 UTC-6" <% [ "`uci get system.@system[0].zonename |grep TiZ.UTCm6 `" ] && echo selected  %>>UTC+06:00 TiZ.UTCm6</option>
      <option value="UTC+07:00 TiZ.UTCm7 UTC-7" <% [ "`uci get system.@system[0].zonename |grep TiZ.UTCm7 `" ] && echo selected  %>>UTC+07:00 TiZ.UTCm7</option>
      <option value="UTC+08:00 TiZ.UTCm8 UTC-8" <% [ "`uci get system.@system[0].zonename |grep TiZ.UTCm8 `" ] && echo selected  %>>UTC+08:00 TiZ.UTCm8</option>
      <option value="UTC+08:00 TiZ.AWSTm8 AWST-8" <% [ "`uci get system.@system[0].zonename |grep TiZ.AWSTm8 `" ] && echo selected  %>>UTC+08:00 TiZ.AWSTm8</option>
      <option value="UTC+08:45 TiZ.UTCm8c45 UTC-8:45" <% [ "`uci get system.@system[0].zonename |grep TiZ.UTCm8c45 `" ] && echo selected  %>>UTC+08:45 TiZ.UTCm8c45</option>
      <option value="UTC+09:00 TiZ.UTCm9 UTC-9" <% [ "`uci get system.@system[0].zonename |grep TiZ.UTCm9 `" ] && echo selected  %>>UTC+09:00 TiZ.UTCm9</option>
      <option value="UTC+09:30 TiZ.ACSTm9c3 ACST-9:30" <% [ "`uci get system.@system[0].zonename |grep TiZ.ACSTm9c3 `" ] && echo selected  %>>UTC+09:30 TiZ.ACSTm9c3</option>
      <option value="UTC+09:30 TiZ.ACDT ACST-9:30ACDT,M10.1.0/2,M4.1.0/3" <% [ "`uci get system.@system[0].zonename |grep TiZ.ACDT `" ] && echo selected  %>>UTC+09:30 TiZ.ACDT</option>
      <option value="UTC+10:00 TiZ.AESTm10 AEST-10" <% [ "`uci get system.@system[0].zonename |grep TiZ.AESTm10 `" ] && echo selected  %>>UTC+10:00 TiZ.AESTm10</option>
      <option value="UTC+10:00 TiZ.AEDT AEST-10AEDT-11,M10.1.0/2,M4.1.0/3" <% [ "`uci get system.@system[0].zonename |grep TiZ.AEDT `" ] && echo selected  %>>UTC+10:00 TiZ.AEDT</option>
      <option value="UTC+10:00 TiZ.UTCm10 UTC-10" <% [ "`uci get system.@system[0].zonename |grep TiZ.UTCm10 `" ] && echo selected  %>>UTC+10:00 TiZ.UTCm10</option>
      <option value="UTC+11:00 TiZ.UTCm11 UTC-11" <% [ "`uci get system.@system[0].zonename |grep TiZ.UTCm11 `" ] && echo selected  %>>UTC+11:00 TiZ.UTCm11</option>
      <option value="UTC+12:00 TiZ.UTCm12 UTC-12" <% [ "`uci get system.@system[0].zonename |grep TiZ.UTCm12 `" ] && echo selected  %>>UTC+12:00 TiZ.UTCm12</option>
      <option value="UTC+12:00 TiZ.NZST NZST-12NZDT,M9.5.0/2,M4.1.0/3" <% [ "`uci get system.@system[0].zonename |grep TiZ.NZST `" ] && echo selected  %> >UTC+12:00 TiZ.NZST</option>
                                        </select>
                                    </div>
                                </label>
                            </form>
              <div class="btn-wrap">
              <div class="save-btn fr"><a href="javascript:saveTimeZone()">保存</a></div>
              </div>
                        </div>
                    </div>
                </div>
           </div>
        </div>
    </div>
</body>
</html>
