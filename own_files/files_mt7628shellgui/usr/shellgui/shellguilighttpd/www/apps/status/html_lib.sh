<% index() { %>
      <div class="header">
        <h1><%= ${_LANG_Form_Running_state_of_the_system} %></h1>
      </div>
      <div class="row">
        <div class="col-xs-12">
          <div class="running-time"><%= ${_LANG_Form_Runs} %>: <span id="running-time">0 <%= ${_LANG_Form_Days} %> 00 <%= ${_LANG_Form_hours} %> 00 <%= ${_LANG_Form_mins} %> 00 <%= ${_LANG_Form_secs} %></span></div>
          <div class="row" id="cpu-container">
            <div class="col-xs-12 col-sm-6 col-md-3 cpu-status">
              <div class="media">
                <div class="media-left">
                  <span class="circle"></span>
                </div>
                <div class="media-body">
                  <h4 class="media-heading">cpu0:<span> 0%</span></h4>
                </div>
              </div>
            </div>
          </div>
          <div class="media">
            <div class="media-left">
              <span class="circle"></span>
            </div>
            <div class="media-body">
              <h4 class="media-heading"><%= ${_LANG_Form_Memory} %>:<span id="mem-usage">0%</span></h4>
              <p><%= ${_LANG_Form_total} %><span id="mem-total">0M</span>,<%= ${_LANG_Form_used} %><span id="mem-used">0M</span></p>
            </div>
          </div>
          <div class="media">
            <div class="media-left">
              <span class="circle"></span>
            </div>
            <div class="media-body">
              <h4 class="media-heading"><%= ${_LANG_Form_Swap} %>:<span id="swap-usage">0%</span></h4>
              <p><%= ${_LANG_Form_total} %><span id="swap-total">0M</span>,<%= ${_LANG_Form_used} %><span id="swap-used">0M</span></p>
            </div>
          </div>
        </div>
      </div>
    </div>
    <div class="container">
      <div class="header">
        <h1><%= ${_LANG_Form_Network_status} %></h1><a href="?app=status&action=edit_network_status"><span id="wanType_wan"><%= ${_LANG_Form_Edit} %></span></a>
      </div>
      <div id="eths-container">
      <div class="row net-status-item">
        <div class="media col-md-4 col-sm-6">
          <div class="media-left">
            <span class="circle"></span>
          </div>
          <div class="media-body">
            <h4 class="media-heading">eth0</h4>
            <p>Loading</p>
          </div>
        </div>
        <div class="col-md-4 col-sm-6">
          <div class="row cpu-progress">
            <span class=""></span>
            <span class="cpu-progress-bar"></span>
            <div class="cpu-progress-text col-xs-offset-3 col-xs-9">----Loading----</div>
          </div>
        </div>
        <div class="col-md-4 col-sm-12">
          <div class="row">
            <div class="col-xs-6"><span class="glyphicon glyphicon-arrow-up">&nbsp;</span><span class="">0 B/s - 0 B</span></div>
            <div class="col-xs-6"><span class="glyphicon glyphicon-arrow-down">&nbsp;</span><span class="">0 B/s - 0 B</span></div>
          </div>
        </div>
      </div>
    </div>
<%
}
edit_network_status() {
bw_set_str=$(jshon -F /usr/shellgui/bw_set.conf 2>/dev/null | sed -e 's/M\"$/"/g' -e's/M\",$/",/g')
%>
<div class="app row app-item">
	<h2 class="app-sub-title col-sm-12">编辑带宽</h2>
<div class="col-sm-offset-2 col-sm-6 text-left">
	<form class="form-horizontal text-left" id="bw_set">
	<fieldset>
	<% for dev in $(shellgui '{"action": "get_ifces_status"}' | jshon -S -k); do 
	bw=$(echo "$bw_set_str" | jshon -e "${dev}" -u 2>/dev/null)
	%>
		<div class="form-group">
			<label class="col-sm-4 control-label"><%= ${dev} %></label>
			<div class="col-sm-8">
				<div class="input-group">
				  <input type="number" min="1" required data-validate="num" class="form-control" value=<%= ${bw:-100} %> name="dev_<%= ${dev} %>">
				  <span class="input-group-addon">M</span>
				</div>
				<span class="help-block hidden">请输入有效的 正整数</span>
			</div>
		</div>
	<% done %>
		<div class="form-group">
			<div class="col-sm-offset-4 col-sm-8">
				<button type="submit" id="submit_btn" class="btn btn-default">应用</button>
			</div>
		</div>
	</fieldset>
	</form>
</div>
</div>
<%
}
%>
