#!/usr/bin/haserl
<%
shellgui '{"action":"check_session","session_type":"http-session","session":"'"$COOKIE_session"'"}' &>/dev/null
[ $? -ne 0 ] && printf "Location: /?app=login\r\n\r\n" && exit 1
eval $(/usr/shellgui/progs/main.sbin l_p '_LANG_Form_|_LANG_App_' ${FORM_app} $COOKIE_lang)
%>
<!DOCTYPE html>
<html>
<% /usr/shellgui/progs/main.sbin h_h '{"title":"'"${_LANG_Form_Shellgui_Web_Control}"'"}' %>
<body>
<div id="header">
<% /usr/shellgui/progs/main.sbin h_sf
/usr/shellgui/progs/main.sbin h_nav '{"active":"wan"}' %>
</div>
<div id="main">
<div class="container">
  <div class="pull-right"><a target="_blank" href="http://shellgui-docs.readthedocs.io/<%= ${COOKIE_lang//-*/} %>/master/<%= ${_LANG_App_type} %>.html#setting-<%= ${FORM_app}"("${_LANG_App_name}")" %>"><span class="icon-link"></span></a></div>
</div>
<div class="container">
	<div class="header row">
		<h1><%= ${_LANG_Form_Advanced} %></h1>
	</div>
	<div class="form-group">
		<label for="" class="control-label col-sm-4"><%= ${_LANG_Form_syncppp} %></label>
		<div class="col-sm-8">
		  <div class="switch-ctrl head-switch" id="switch_syncppp" data-toggle="modal" data-target="#confirmModal">
			  <input type="checkbox" name="nic-switch" id="switch_syncppp_in" value="" <% [ -f /usr/shellgui/shellguilighttpd/www/apps/wan/mpppoe ] && printf 'checked'%>>
			  <label for="switch_syncppp_in"><span></span></label>
		  </div>
		</div>
	</div>
</div>
<%in /usr/shellgui/shellguilighttpd/www/apps/wan/html_lib.sh %>
<%
network_str=$(uci show network -X)
ifces=$(echo "$network_str" | grep '=interface$' | cut -d  '=' -f1 | cut -d '.' -f2 | grep -v '6$')
for ifce in $ifces; do
type=;ifname=
eval $(echo "$network_str" | grep 'network\.'${ifce}'\.' | cut -d '.' -f3-)
[ -z "$type" ] && [ "$ifname" != "lo" ] && wans="$wans ${ifce}"
done
for wan in $wans; do
proto=;dns=;mtu=;macaddr=;_Global_HW_mode=;_Global_SW_mode=
type=;ip6assign=;ipaddr=;netmask=;metric=
dhcp=
username=;password=
device=;service=;apn=;dialnumber=;pincode=
pre_exec=$(echo "$network_str" | grep 'network\.'${wan}'\.' | cut -d '.' -f3-)
echo "$pre_exec" | grep -qE "[\']$" || echo "$pre_exec" | grep -qE "[\"]$"
if [ $? -eq 0 ]; then
eval $pre_exec
else
eval $(echo "$pre_exec" | sed -e 's#=#=\"#g' -e 's#$#\"#g')
fi
dns1=$(echo "$dns" | awk '{print $1}')
dns2=$(echo "$dns" | awk '{print $2}')
echo "${wan}" | grep -qE '^v[a-z0-9]*_[0-9]*' && is_vwan=1 || is_vwan=0
%>
  <div class="container" id="<%= ${wan} %>_container">
    <div class="header row">
      <h1><%= ${_LANG_Form_Wan_Setting} %>(<%= ${wan} %><%
	  if [ -n "${_Global_HW_mode}" ]; then
	  printf "|${_LANG_Form_Global_HW_mode}:"
	  jshon -F /usr/shellgui/shellguilighttpd/www/apps/${_Global_HW_mode}/i18n.json -e "${COOKIE_lang}" -e "_LANG_App_name" -u
	  fi
	  if [ -n "${_Global_SW_mode}" ]; then
	  printf "|${_LANG_Form_Global_SW_mode}:"
	  jshon -F /usr/shellgui/shellguilighttpd/www/apps/${_Global_SW_mode}/i18n.json -e "${COOKIE_lang}" -e "_LANG_App_name" -u
	  fi
	  %>)</h1>
	  <% if [ $is_vwan -gt 0 ]; then %><span class="icon-cross text-danger remove_vwan_btn" id="remove_btn_<%= ${wan} %>" data-toggle="modal" data-target="#confirmModal"></span> <% fi %>
      <span id="wanType_<%= ${wan} %>"><%= ${_LANG_Form_Watting_for_connection_check} %>...</span>
    </div>
    <div class="hidden" id="<%= ${wan} %>_info">
      <table class="table table-hover">
        <tr>
          <th><%= ${_LANG_Form_IP_Address} %></th>
          <td id="<%= ${wan} %>_info_ip"></td>
        </tr>
        <tr>
          <th><%= ${_LANG_Form_Netmask} %></th>
          <td id="<%= ${wan} %>_info_mask"></td>
        </tr>
        <tr>
          <th><%= ${_LANG_Form_Gateway} %></th>
          <td id="<%= ${wan} %>_info_gateway"></td>
        </tr>
        <tr>
          <th>DNS</th>
          <td id="<%= ${wan} %>_info_dns"></td>
        </tr>
        <tr>
          <td colspan='2'>
            <button class="btn btn-default btn-sm show-set-btn" id="<%= ${wan} %>_set_btn"><%= ${_LANG_Form_Set_Wan} %></button>
          </td>
        </tr>
      </table>
    </div>
    <div class="content row status-block" id="wanSet_<%= ${wan} %>">
<% if [ "$proto" != "none" ] || ifconfig ${ifname} &>/dev/null; then
	if echo ${wan} | grep -qE '_[3|4]g$'; then
		m_3g_like
	else
		tab_like
	fi
fi %>
    </div>
  </div>
<% done %>
</div>
<div class="modal fade" id="confirmModal">
  <div class="modal-dialog">
    <div class="modal-content">
      <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal"><span>&times;</span></button>
        <h4 class="modal-title">title</h4>
      </div>
      <div class="modal-body">
        <p class="text-center text-danger confirm-text">text</p>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-default" id="confirm_btn"><%= ${_LANG_Form_Apply} %></button>
        <button type="button" class="btn btn-warning" data-dismiss="modal"><%= ${_LANG_Form_Cancel} %></button>
      </div>
    </div>
  </div>
</div>
<% /usr/shellgui/progs/main.sbin h_f%>
<script>var UI = {};</script>
<% /usr/shellgui/progs/main.sbin h_end '{"js":["/apps/wan/wan.js"]}' %>
<script>
<% /usr/shellgui/progs/main.sbin l_p_J '_LANG_JsUI_' ${FORM_app} $COOKIE_lang %>
$('#switch_syncppp').click(function() {
	var checked = $(this).find('[type="checkbox"]').prop('checked');
	var text = checked ? '<%= ${_LANG_Form_syncppp} ${_LANG_Form_Enabled} %>?' : '<%= ${_LANG_Form_syncppp} ${_LANG_Form_Enabled} %>?';
	Ha.alterModal('confirmModal','<%= ${_LANG_Form_syncppp} %>',text,submitsyncppp,'switch_syncppp');
});
function submitsyncppp(switchId){
  	var status = $('#' + switchId).find('[type="checkbox"]').prop('checked');
  	var enable = status ? 0 : 1;
  	var post_data = 'app=wan&action=enable_syncppp&enabled=' + enable;
	$.post('/',post_data,function(data){
		Ha.showNotify(data);
	  	var result = data.status == 1 ? false : true;
	  	var checked = status;
	  	Ha.setSwitchBtn(switchId,result,checked);
	  	console.log($('#' + switchId).find('[type="checkbox"]').prop('checked'));
	},'json');
}
</script>
</body>
</html>
