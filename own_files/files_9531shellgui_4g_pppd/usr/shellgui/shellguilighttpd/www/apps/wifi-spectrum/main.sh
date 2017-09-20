#!/usr/bin/haserl
<%
shellgui '{"action":"check_session","session_type":"http-session","session":"'"$COOKIE_session"'"}' &>/dev/null
[ $? -ne 0 ] && printf "Location: /?app=login\r\n\r\n" && exit 1
eval $(/usr/shellgui/progs/main.sbin l_p '_LANG_App_|_LANG_Form_' ${FORM_app} $COOKIE_lang)
%>
<!DOCTYPE html>
<html>
<% /usr/shellgui/progs/main.sbin h_h '{"title":"'"${_LANG_Form_Shellgui_Web_Control}"'"}' %>
<body>
<div id="header">
    <% /usr/shellgui/progs/main.sbin h_sf %>
    <% /usr/shellgui/progs/main.sbin h_nav '{"active":"home"}' %>
</div>
<div id="main">
	<div class="container">
<% /usr/shellgui/progs/main.sbin hm '{"1":{"title":"'${_LANG_App_type}'","url":"/?app=home#'${_LANG_App_type}'"},"2":{"title":"'${_LANG_App_name}'"}}' %>
    	<div class="row">
	    	<div class="col-sm-12 form-inline">
    			<select id="interface" class="form-control" onchange="changeBand()"></select>
    			<button class="btn btn-default" onclick="changeBand()"><%= ${_LANG_Form_Flash} %></button>
    			<div class="btn-group hidden-xs hidden" id="sm-range">
		    		<button type="button" class="btn btn-default active" id="5g_1_btn">5170-5330 <span class="badge"></span></button>
		    		<button type="button" class="btn btn-default" id="5g_2_btn">5490-5710 <span class="badge"></span></button>
		    		<button type="button" class="btn btn-default" id="5g_3_btn">5735-5835 <span class="badge"></span></button>
    			</div>
    			<span id="xs-range" class="hidden">
    			<select class="form-control visible-xs-inline">
    				<option value="5g_1">5170-5330</option>
    				<option value="5g_2">5490-5710</option>
    				<option value="5g_3">5735-5835</option>
    			</select>
				</span>
	    	</div>
	    	<div class="col-xs-8 col-sm-4">
	    	</div>
	    	<div class="col-sm-12" id="line_container"></div>
    	</div>
	</div> 
</div>
<% /usr/shellgui/progs/main.sbin h_f
/usr/shellgui/progs/main.sbin h_end %>
<script>
<% /usr/shellgui/progs/main.sbin l_p_J '_LANG_JsUI_' ${FORM_app} $COOKIE_lang %>
var wifiLines = new Array();
<% for ap in $( iwinfo | grep ESSID | awk ' { print $1 ; } ' ) ; do iwinfo $ap info | awk ' /^wlan/ { printf "wifiLines.push(\""$1" " ;} /Channel:/ {print ""$4"\");"}'; done %>
</script>
<script src="apps/home/common/js/Chart.js"></script>
<script src="apps/wifi-spectrum/spectrum_analyser.js"></script>
</body>
</html>
