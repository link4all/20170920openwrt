#!/usr/bin/haserl
<%
shellgui '{"action": "check_session", "session_type": "http-session", "session": "'"$COOKIE_session"'"}' &>/dev/null
[ $? -ne 0 ] && printf "Location: /?app=login\r\n\r\n" && return 1
eval $(/usr/shellgui/progs/main.sbin l_p '_LANG_App_|_LANG_Form_' ${FORM_app} $COOKIE_lang)
%>
<!DOCTYPE html>
<html>
<% /usr/shellgui/progs/main.sbin h_h '{"title": "'"${_LANG_Form_Shellgui_Web_Control}"'"}'
%>
<body>
<div id="header">
<% /usr/shellgui/progs/main.sbin h_sf
/usr/shellgui/progs/main.sbin h_nav '{"active": "home"}' %>
</div>
<div id="main">
	<div class="container">
<% /usr/shellgui/progs/main.sbin hm '{"1": {"title": "'${_LANG_App_type}'", "url": "/?app=home#'${_LANG_App_type}'"}, "2": {"title": "'${_LANG_App_name}'"}}' %>
    	<div class="row">
    		<div class="app app-item col-lg-12">
		        <div class="row">
		            <div class="col-sm-12">
		                <h2 class="app-sub-title"><%= ${_LANG_App_name} %></h2>
		            </div>
		            <div class="col-sm-offset-1 col-sm-11">
		            	<div class="table-responsive">
		            		<table class="table">
		            			<thead class="hidden">
		            				<tr>
		            					<th><%= ${_LANG_Form_Device_info} %></th>
		            					<th><%= ${_LANG_Form_Device} %></th>
		            					<th><%= ${_LANG_Form_Type} %></th>
		            					<th><%= ${_LANG_Form_Mount_Point} %></th>
		            					<th><%= ${_LANG_Form_Enabled} %></th>
		            					<th><%= ${_LANG_Form_Detail} %></th>
		            				</tr>
		            			</thead>
		            			<tbody id="disk_container"></tbody>
		            		</table>
		            	</div>
	                </div>
	            </div>
	        </div>
    	</div>
    	<hr>
    	<div class="row">
    		<button class="btn btn-warning btn-lg pull-right" id="reset_page_btn"><%= ${_LANG_Form_Reset} %></button>
    		<button class="btn btn-default btn-lg pull-right" id="save_page_btn"><%= ${_LANG_Form_Apply} %></button>
    	</div>
	</div> 
</div>
<%	/usr/shellgui/progs/main.sbin h_f
	/usr/shellgui/progs/main.sbin h_end %>
<script src="/apps/disk/disk.js"></script>
<script>
var UI = {};
<% /usr/shellgui/progs/main.sbin l_p_J '_LANG_JsUI_' ${FORM_app} $COOKIE_lang %>
</script>
</body>
</html>