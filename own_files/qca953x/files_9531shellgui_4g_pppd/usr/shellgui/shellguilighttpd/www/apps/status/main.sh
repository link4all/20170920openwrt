#!/usr/bin/haserl
<%
shellgui '{"action":"check_session","session_type":"http-session","session":"'"$COOKIE_session"'"}' &>/dev/null
[ $? -ne 0 ] && printf "Location: /?app=login\r\n\r\n" && return 1
	if [ "${GET_action}" = "bw_status" ] &>/dev/null; then
	id=$(echo ${COOKIE_session} | grep -Eo '.....$')
        printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
		shellgui '{"action":"ifces_bw_status","session":"'"$id"'"}'
    return
	elif [ "${GET_action}" = "hw_status" ] &>/dev/null; then
        printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
memswap_str=$(shellgui '{"action": "get_mem_status", "readable": 1}' | jshon -j)
        cat <<EOF
{"uptime":$(shellgui '{"action":"get_uptime"}' | jshon -e "formatted" -j),"cpu":$(shellgui '{"action": "get_cpu_usage"}' | jshon -e "detail" -j),"swap":$(echo "$memswap_str" | jshon -e "swap" -j),"mem":$(echo "$memswap_str" | jshon -e "mem" -j)}
EOF
    return
	fi
	time_now=$(date +%s)
	ls /tmp/bw_last-*.json -l  -e | while read line; do
	time_file=$(date -D "%b %d %H:%M:%S %Y" -d "$(echo "${line}" | awk '{print $7" "$8" "$9" "$10}')" +%s)
	[ $(( ${time_now} - ${time_file})) -gt 300 ]  && file=$(echo "${line}" | awk '{print $NF}') && rm -f ${file}
	done
	eval $(/usr/shellgui/progs/main.sbin l_p '_LANG_App_|_LANG_Form_' ${FORM_app} $COOKIE_lang)
%>
<!DOCTYPE html>
<html>
<%in /usr/shellgui/shellguilighttpd/www/apps/status/html_lib.sh %>
<% /usr/shellgui/progs/main.sbin h_h '{"title":"'"${_LANG_Form_Shellgui_Web_Control}"'"}' %>
<body>
<div id="header">
<% /usr/shellgui/progs/main.sbin h_sf
/usr/shellgui/progs/main.sbin h_nav '{"active":"status"}' %>
</div>
<div id="main">
<div class="container">
  <div class="pull-right"><a target="_blank" href="http://shellgui-docs.readthedocs.io/<%= ${COOKIE_lang//-*/} %>/master/<%= ${_LANG_App_type// /-} %>.html#setting-<%= ${FORM_app}"("${_LANG_App_name// /-}")" %>"><span class="icon-link"></span></a></div>
</div>
    <div class="container">
    	<div class="header">
	        <h1><%= ${_LANG_Form_Running_state_of_the_system} %></h1>
	      </div>
	      <div class="row">
	        <div class="col-xs-12">
	          <div class="running-time"><%= ${_LANG_Form_Runs} %>: <span id="running-time">0 <%= ${_LANG_Form_Days} %> 00 <%= ${_LANG_Form_hours} %> 00 <%= ${_LANG_Form_mins} %> 00 <%= ${_LANG_Form_secs} %></span></div>
	          <div id="sysinfo-container" class="row">
	            <div id="cpu-container"></div>
	            <div class="col-xs-12 col-sm-4 col-md-3 net-status-item">
	               <h4 class="text-center"><%= ${_LANG_Form_Memory} %></h4>
	               <hr>
	               <div class="text-center">
	                 <svg width="120" height="120" id="mem_svg">
	                   <circle cx="60" cy="60" r="50" id="mem-circle" fill="#2ECC71"></circle>
	                   <text id="mem-usage" x="60" y="60" dy="6" text-anchor="middle" fill="white" font-size="18">0.00%</text>
	                   <g id="mem_prog"></g>
	                 </svg>
	                 <p><span id="mem-used">0M</span>/<span id="mem-total">0M</span></p>
	               </div>
	            </div>
	            <div class="col-xs-12 col-sm-4 col-md-3 net-status-item">
	               <h4 class="text-center"><%= ${_LANG_Form_Swap} %></h4>
	               <hr>
	               <div class="text-center">
	                 <svg width="120" height="120" id="swap_svg">
	                   <circle cx="60" cy="60" r="50" id="swap-circle" fill="hsl(145,63.2%,49.0%)"></circle>
	                   <text id="swap-usage" x="60" y="60" dy="6" text-anchor="middle" fill="white" font-size="18">0.00%</text>
	                   <g id="swap_prog"></g>
	                 </svg>
	                <p><span id="swap-used">0M</span>/<span id="swap-total">0M</span></p>
	               </div>
	            </div>
	          </div>
	          
	        </div>
	      </div>
	    </div>
	    <div class="container">
	      <div class="header">
	        <h1><%= ${_LANG_Form_Network_status} %></h1>
	      </div>
	      <div id="eths-container" class="row">
	    </div>
    </div>
  </div>
<div class="modal fade" id="ethModal">
  <div class="modal-dialog">
    <div class="modal-content">
      <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal"><span aria-hidden="true">&times;</span><span class="sr-only">Close</span></button>
        <h4 class="modal-title">编辑带宽</h4>
      </div>
      <form class="form-horizontal">
      <div class="modal-body">
          <div class="form-group">
		    <label for="eths" class="col-sm-2 control-label">Eth</label>
		    <div class="col-sm-10">
		      <select class="form-control hidden" id="eth_select" name="eth"></select>
		      <p class="form-control-static" id="eth_static"></p>
		    </div>
		  </div>
		  <div class="form-group has-feedback">
		    <label for="eth_bw" class="col-sm-2 control-label">带宽</label>
		    <div class="col-sm-10">
		      <input type="number" class="form-control" data-validate="vaLength-vaInt_1" name="bw" id="eth_bw" value="100">
		      <span class="form-control-feedback">M</span>
			  <span class="help-block hidden">请输入有效的 正整数</span>
		    </div>
		  </div>
      </div>
      <div class="modal-footer">
        <button type="submit" class="btn btn-default">保存</button>
        <button type="reset" class="btn btn-warning" data-dismiss="modal">取消</button>
      </div>
      </form>
    </div>
  </div>
</div>
<% /usr/shellgui/progs/main.sbin h_f
/usr/shellgui/progs/main.sbin h_end '{"js":["/apps/status/status.js"]}'
%>
<script>
<% /usr/shellgui/progs/main.sbin l_p_J '_LANG_JsUI_' ${FORM_app} $COOKIE_lang
if [ -z "$FORM_action" ]; then
%>
Ha.mask.show();
askStatus();
setInterval(function(){
    askStatus();
},5000);
<% fi %>
</script>
</body>
</html>
