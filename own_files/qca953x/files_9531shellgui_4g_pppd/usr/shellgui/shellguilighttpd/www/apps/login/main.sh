#!/usr/bin/haserl
<%
if [ "$FORM_action" = "logout" ]; then
	shellgui '{"action":"del_session","session_type":"http-session","session":"'"$COOKIE_session"'"}' &>/dev/null
	printf "Location: /?app=login\r\n\r\n"
	return
fi
eval $(/usr/shellgui/progs/main.sbin l_p '_LANG_Form_' ${FORM_app} $COOKIE_lang)
%>
<!DOCTYPE html>
<html>
<% /usr/shellgui/progs/main.sbin h_h '{"title":"'"${_LANG_Form_Login}"'"}' %>
<body>
<div class="container login-content">
  <div class="row">
    <div class="logo">
      <div class="">
	  <% xsvg_height=200 xsvg_height=200 xsvg_id="login_svg" haserl /usr/shellgui/shellguilighttpd/www/apps/login/icon.xsvg %>
      </div>
      <h1><%= ${_LANG_Form_Wlelecome} %></h1>
    </div>
    <form class="form" name="loginform" method="post" id="loginform">
      <div class="form-group">
        <select class="form-control" id="lang" name="lang" onchange="lang_change()">
			<option value="zh-cn" <% [ "$COOKIE_lang" = "zh-cn" ] && printf 'selected="selected"'%>><%= ${_LANG_Form_lang_zh_cn} %></option>
			<option value="en" <% [ "$COOKIE_lang" = "en" ] && printf 'selected="selected"'%>><%= ${_LANG_Form_lang_en} %></option>
        </select>
      </div>
      <div class="form-group">
        <input type="text" class="form-control" name="username" required placeholder="<%= ${_LANG_Form_Username} %>" value="root">
      </div>
      <div class="form-group">
        <input type="password" class="form-control" name="password" required placeholder="<%= ${_LANG_Form_Password} %>">
      </div>
      <button type="submit" class="btn btn-default btn-block"><%= ${_LANG_Form_Login} %></button>
    </form>
  </div>
</div>
<script>var UI = {};</script>
<% /usr/shellgui/progs/main.sbin h_end %>
<script>
<% /usr/shellgui/progs/main.sbin l_p_J '_LANG_JsUI_' ${FORM_app} $COOKIE_lang %>
  $('#loginform').on('submit', function(e){
  	e.preventDefault();
  	var data = "app=login&"+$(this).serialize();
  	var url = '/';
  	Ha.ajax(url, 'json', data, 'post', 'loginform');
  });
  function lang_change(){
  	var data = "app=home&action=change_lang&lang=" + $('#lang').val();
  	var url = '/';
  	Ha.ajax(url, 'json', data, 'post', 'loginform');
  };
  function get_quotas(){
  	var data = "app=quotas&action=get_quotas";
  	var url = '/';
    $.post('/',data,function(data){
      if(!data){return;}
      var text = data.split(/[\r\n]+/);
      var limits = getInt(text[text.length-2]);
      var percents = getInt(text[text.length-3]);
      var used = getInt(text[text.length-4]);
      var statusTotal = 0;
      if(parseInt(percents[0]) >= 50){
        statusTotal = 1;
        if(parseInt(percents[0]) < 80){
          statusTotal = 2;
        }
      }
      var statusDown = 0;
      if(parseInt(percents[1]) >= 50){
        statusDown = 1;
        if(parseInt(percents[1]) < 80){
          statusDown = 2;
        }
      }
      var statusUp = 0;
      if(parseInt(percents[2]) >= 50){
        statusUp = 1;
        if(parseInt(percents[2]) < 80){
          statusUp = 2;
        }
      }
      var notifyTotal = {
        status: statusTotal,
        msg: UI.You_Bandwidth_Quotation_total_is+': '+parseBytes(parseInt(limits[0])) + ','+UI.has_been_used+': ' + percents[0] + '%(' + parseBytes(parseInt(used[0])) + ')。'
      };
      var notifyDown = {
        status: statusDown,
        msg: UI.You_Bandwidth_Quotation_Download_is+': ' + parseBytes(parseInt(limits[1])) + ','+UI.has_been_used+': ' + percents[1] + '%(' + parseBytes(parseInt(used[1])) + ')。'
      };
      var notifyUp = {
        status: statusUp,
        msg: UI.You_Bandwidth_Quotation_Upload_is+': ' + parseBytes(parseInt(limits[2])) + ','+UI.has_been_used+': ' + percents[2] + '%(' + parseBytes(parseInt(used[2])) + ')。'
      }
      if(parseInt(limits[0]) > 0){
        showNotify(notifyTotal);
      }
      if(parseInt(limits[1]) > 0){
        showNotify(notifyDown);
      }
      if(parseInt(limits[2]) > 0){
        showNotify(notifyUp);
      }
    });
  };
  function parseBytes(bytes, units, abbr, dDgt){
    var parsed;
    units = units != "KBytes" && units != "MBytes" && units != "GBytes" && units != "TBytes" ? "mixed" : units;
    spcr = abbr==null||abbr==0 ? " " : "";
    if( (units == "mixed" && bytes > 1024*1024*1024*1024) || units == "TBytes")
    {
      parsed = (bytes/(1024*1024*1024*1024)).toFixed(dDgt||2) + spcr + "TBytes";
    }
    else if( (units == "mixed" && bytes > 1024*1024*1024) || units == "GBytes")
    {
      parsed = (bytes/(1024*1024*1024)).toFixed(dDgt||2) + spcr + "GBytes";
    }
    else if( (units == "mixed" && bytes > 1024*1024) || units == "MBytes" )
    {
      parsed = (bytes/(1024*1024)).toFixed(dDgt||2) + spcr + "MBytes";
    }
    else
    {
      parsed = (bytes/(1024)).toFixed(dDgt||2) + spcr + "KBytes";
    }
    return parsed;
  }
  function getInt(str){
    var data = [];
    str = str.split('=').pop();
    data = str.replace('[','').replace(']','').replace(';','').replace(/\s/g, "").split(',');
    return data;
  }
  function showNotify(data){
    var type = 'success';
    var delay = 120000;
    if(data.status){
      type = 'warning';
      if(data.status == 1){
        type = 'error';
      }
    }
    Lobibox.notify(type, {
      msg: data.msg,
      img: data.img,
      title: UI.Bandwidth_Quotation_Notice,
      delay: delay,
      size: 'normal',
      showClass: 'bounceInDown',
      hideClass: 'fadeOut',
      sound: false
    });
  };
  $('.gotop-widget').empty();//TODO same method can be used at the header or footer...
  get_quotas();
</script>
</body>
</html>
