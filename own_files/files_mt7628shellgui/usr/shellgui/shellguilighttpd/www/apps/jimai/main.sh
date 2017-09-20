#!/usr/bin/haserl
<%
shellgui '{"action": "check_session", "session_type": "http-session", "session": "'"$COOKIE_session"'"}' &>/dev/null
[ $? -ne 0 ] && printf "Location: /?app=login\r\n\r\n" && return 1
. /usr/shellgui/shellguilighttpd/www/apps/jimai/lib.sh
lan_mac=$(get_lan_mac)
board_name=$(sed -n 1p /tmp/sysinfo/board_name)
lan_mac_formated=$(echo "$lan_mac" | tr -d ":" | tr "a-z" "A-Z")
if [ "$FORM_action" = "get_qrcode" ]; then
	printf "Content-Type: image/bmp\r\nContent-Disposition: attachment;filename=${lan_mac_formated}.bmp\r\n\r\n"
	qr -s0 -eM -x6 -fBMP -mS '{"MAC":"'$(echo "${lan_mac_formated}" | tr -d ':' | tr "a-z" "A-Z")'","board_name":"'"${board_name}"'"}'
	exit
fi
eval $(/usr/shellgui/progs/main.sbin l_p '_LANG_App_|_LANG_Form_' ${FORM_app} $COOKIE_lang)
%>
<!DOCTYPE html>
<html>
<% /usr/shellgui/progs/main.sbin h_h '{"title": "'"${_LANG_Form_Shellgui_Web_Control}"'"}'
%>
<body>
<div id="header">
    <% /usr/shellgui/progs/main.sbin h_sf %>
    <% /usr/shellgui/progs/main.sbin h_nav '{"active": "home"}' %>
</div>
<div id="main">
	<div class="container">
<% /usr/shellgui/progs/main.sbin hm '{"1": {"title": "'${_LANG_App_type}'", "url": "/?app=home#'${_LANG_App_type}'"}, "2": {"title": "'${_LANG_App_name}'"}}' %>

<div class="content">
    <div class="app row app-item">
        <h2 class="app-sub-title col-sm-12">设备信息</h2>
        <div class="col-sm-offset-2 col-sm-6 text-left">
            <div class="form-group">
                <label for="" class="control-label col-sm-4">型号</label>
                <div class="col-sm-8">
                    <p><%= ${board_name} %></p>
                </div>
                <label for="" class="control-label col-sm-4">序列号</label>
                <div class="col-sm-8">
                    <p><%= ${lan_mac_formated} %></p>
                </div>
                <label for="" class="control-label col-sm-4">Portal版本号</label>
                <div class="col-sm-8">
                    <p><% cat /usr/shellgui/shellguilighttpd/www/apps/jimai/hotspot.ver %></p>
                </div>
                <label for="" class="control-label col-sm-4">审计版本号</label>
                <div class="col-sm-8">
                    <p><% cat /usr/shellgui/shellguilighttpd/www/apps/jimai/audit.ver  %></p>
                </div>
                <label for="" class="control-label col-sm-4">二维码</label>
                <div class="col-sm-8">
                    <img src="/?app=jimai&action=get_qrcode" alt="<%= ${lan_mac_formated} %>" height="96" width="96" />
                </div>
            </div>
        </div>
    </div>
</div>


	</div> 
</div>
<% /usr/shellgui/progs/main.sbin h_f
/usr/shellgui/progs/main.sbin h_end %>
</body>
</html>