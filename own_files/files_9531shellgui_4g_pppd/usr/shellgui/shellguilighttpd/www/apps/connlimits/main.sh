#!/usr/bin/haserl
<%
shellgui '{"action":"check_session","session_type":"http-session","session":"'"$COOKIE_session"'"}' &>/dev/null
[ $? -ne 0 ] && printf "Location: /?app=login\r\n\r\n" && return 1
eval $(/usr/shellgui/progs/main.sbin l_p '_LANG_App_|_LANG_Form_' ${FORM_app} $COOKIE_lang)
%>
<!DOCTYPE html>
<html>
<% /usr/shellgui/progs/main.sbin h_h '{"title":"'"${_LANG_Form_Shellgui_Web_Control}"'"}' %>
<body>
<div id="header">
<% /usr/shellgui/progs/main.sbin h_sf
/usr/shellgui/progs/main.sbin h_nav '{"active":"home"}' %>
</div>
<div id="main">
	<div class="container">
<% /usr/shellgui/progs/main.sbin hm '{"1":{"title":"'${_LANG_App_type}'","url":"/?app=home#'${_LANG_App_type}'"},"2":{"title":"'${_LANG_App_name}'"}}' %>
		<div class="content">
			<div class="app row app-item">
				<h2 class="app-sub-title col-sm-12"><%= ${_LANG_App_name} %></h2>
				<div class="col-sm-offset-1 col-sm-5 text-left">
					<form class="form-horizontal">
						<div class="form-group">
							<label for="" class="col-sm-5 control-label"><%= ${_LANG_Form_Max_Connections} %></label>
							<div class="col-sm-7">
								<input type="text" id="max_connections" name="max_connections" class="form-control" value="<% grep -Eo '[0-9]*' /proc/sys/net/netfilter/nf_conntrack_max || printf 4096 %>">
								<span class="help-block">(<%= ${_LANG_Form_Max} %> 16384)</span>
							</div>
						</div>
						<div class="form-group">
							<label for="" class="col-sm-5 control-label"><%= ${_LANG_Form_TCP_Timeout} %></label>
							<div class="col-sm-7">
								<input type="text" id="tcp_timeout" name="tcp_timeout" class="form-control" value="<% grep -Eo '[0-9]*' /proc/sys/net/netfilter/nf_conntrack_tcp_timeout_established || printf 180 %>">
								<span class="help-block"><%= ${_LANG_Form_Secs} %> (<%= ${_LANG_Form_Max} %> 3600)</span>
							</div>
						</div>
						<div class="form-group">
							<label for="" class="col-sm-5 control-label"><%= ${_LANG_Form_UDP_Timeout} %></label>
							<div class="col-sm-7">
								<input type="text" id="udp_timeout" name="udp_timeout" class="form-control" value="<% grep -Eo '[0-9]*' /proc/sys/net/netfilter/nf_conntrack_udp_timeout_stream || printf 180 %>">
								<span class="help-block"><%= ${_LANG_Form_Secs} %> (<%= ${_LANG_Form_Max} %> 3600)</span>
							</div>
						</div>
						<div class="form-group">
							<label for="" class="col-sm-5 control-label"><%= ${_LANG_Form_Max_FD__file_max} %></label>
							<div class="col-sm-7">
								<input type="text" id="fs_file_max" name="fs_file_max" class="form-control" value="<% grep -Eo '[0-9]*' /proc/sys/fs/file-max || printf 25281 %>">
								<span class="help-block"><%= ${_LANG_Form_Recommended_value} %>:<% grep -r MemTotal /proc/meminfo | awk '{printf("%d",$2/10)}' %><br/><%= ${_LANG_Form_Number_of_Current_FDs} %>:<br/><% awk '{printf "'"${_LANG_Form_Assigned} "'FDs:"$1",<br/>'"${_LANG_Form_Assigned_but_unused} "'FDs:"$2",<br/>'"${_LANG_Form_Max} "'FDs:"$3 }' /proc/sys/fs/file-nr %></span>
							</div>
						</div>
					</form>
				</div>
			</div>
			<hr>
			<div class="app row app-item">
			<div class="col-sm-6">
				<div class="pull-right">
					<button class="btn btn-default btn-lg" id="submit_btn"><%= ${_LANG_Form_Apply} %></button>
				</div>
			</div>
			</div>
		</div>
	</div> 
</div>
<% /usr/shellgui/progs/main.sbin h_f
/usr/shellgui/progs/main.sbin h_end %>
<script>
	$('#submit_btn').click(function(){
		var data = $('form').serialize();
		data = 'app=connlimits&action=connlimits_setting&' + data;
		$.post('/',data,Ha.showNotify,'json');
	});
</script>
</body>
</html>