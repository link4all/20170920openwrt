#!/usr/bin/haserl
<%
shellgui '{"action":"check_session","session_type":"http-session","session":"'"$COOKIE_session"'"}' &>/dev/null
[ $? -ne 0 ] && printf "Location: /?app=login\r\n\r\n" && return 1
eval $(/usr/shellgui/progs/main.sbin l_p '_LANG_Form_|_LANG_App_' ${FORM_app} $COOKIE_lang)
%>
<!DOCTYPE html>
<html>
<% /usr/shellgui/progs/main.sbin h_h '{"title":"'"${_LANG_Form_Shellgui_Web_Control}"'"}' %>
<body>
<div id="header">
<% /usr/shellgui/progs/main.sbin h_sf %>
<% /usr/shellgui/progs/main.sbin h_nav '{"active":"lan"}' %>
</div>
<div id="main">
<div class="container">
  <div class="pull-right"><a target="_blank" href="http://shellgui-docs.readthedocs.io/<%= ${COOKIE_lang//-*/} %>/master/<%= ${_LANG_App_type// /-} %>.html#setting-<%= ${FORM_app}"("${_LANG_App_name// /-}")" %>"><span class="icon-link"></span></a></div>
</div>
<%
network_str=$(uci show network -X)
dhcp_str=$(uci show dhcp -X)
ifces=$(echo "$network_str" | grep '=interface$' | cut -d  '=' -f1 | cut -d '.' -f2)
for ifce in $ifces; do
type=;proto=;ipaddr=
eval $(echo "$network_str" | grep 'network\.'${ifce}'\.' | cut -d '.' -f3-)
[ "$type" = "bridge" ] && [ "$proto" = "static" ] && [ -n "$ipaddr" ] && lans="$lans ${ifce}"
done
for lan in $lans; do
type=;proto=;ipaddr=;netmask=
eval $(echo "$network_str" | grep 'network\.'${lan}'\.' | cut -d '.' -f3-)
%>
  <div class="container">
    <div class="header">
      <h1><%= ${_LANG_Form_Lan_Setting} %>(<%= ${lan} %>)</h1>
    </div>
    <div class="content row">
      <div class="col-md-6">
        <form class="form-horizontal" name="lan_ip_mask" id="lan_ip_mask_<%= ${lan} %>" data-order="<%= ${lan} %>">
          <div class="form-group">
            <label for="lanip_<%= ${lan} %>" class="col-sm-3 control-label"><%= ${_LANG_Form_Lan_IP} %></label>
            <div class="col-sm-9">
              <input type="text" class="form-control" data-validate="vaIP-vaLength" id="lanip_<%= ${lan} %>" name="ip"  maxlength="15" value="<%= $ipaddr %>">
              <span class="help-block hidden"><%= ${_LANG_Form_Please_enter_a_valid_} ${_LANG_Form_IP_Address} %></span>
            </div>
          </div>
          <div class="form-group">
            <label for="netmask_<%= ${lan} %>" class="col-sm-3 control-label"><%= ${_LANG_Form_Netmask} %></label>
            <div class="col-sm-9">
              <select name="netmask" class="form-control" id="netmask_<%= ${lan} %>">
<%
masks="255.255.255.254
255.255.255.252
255.255.255.248
255.255.255.240
255.255.255.224
255.255.255.192
255.255.255.128
255.255.255.0
255.255.254.0
255.255.252.0
255.255.248.0
255.255.240.0
255.255.224.0
255.255.192.0
255.255.128.0
255.255.0.0
255.254.0.0
255.252.0.0
255.248.0.0
255.240.0.0
255.224.0.0
255.192.0.0
255.128.0.0
255.0.0.0
254.0.0.0
252.0.0.0
248.0.0.0
240.0.0.0
224.0.0.0
192.0.0.0
128.0.0.0"
now_mask=$netmask
  num=32
  for mask in $masks; do
  num=$(expr $num - 1)
    if [ "$now_mask" = "${mask}" ]; then
    echo '<option value="'${mask}'" selected>'"$num | "${mask}'</option>'
    else
    echo '<option value="'${mask}'">'"$num | "${mask}'</option>'
    fi
  done
echo "$dhcp_str" | grep -q 'dhcp\.'${lan}'.' && dhcp_enabled=1 ||  dhcp_enabled=0
%>
              </select>
            </div>
          </div>
          <div class="form-group">
            <div class="col-sm-offset-3 col-sm-9">
              <button type="submit" class="btn btn-default" data-order="<%= ${lan} %>"data-toggle="modal" data-target="#confirmModal"><%= ${_LANG_Form_Apply} %></button>
            </div>
          </div>
        </form>
      </div>
    </div>
    <hr>
    <div class="dhcp-header" id="lanDhcp_<%= ${lan} %>">
      <h2 class=""><%= ${_LANG_Form_DHCP_Setting} %>(<%= ${lan} %>)</h2>
      <div class="switch-ctrl">
        <input type="checkbox" name="switch-lan" id="switch-input-<%= ${lan} %>" value="" <% [ ${dhcp_enabled} -gt 0 ] && printf "checked" %> data-order="<%= ${lan} %>">
        <label for="switch-input-<%= ${lan} %>"><span></span></label>
      </div>
    </div>
    <div class='content row' id="dhcp_container_<%= ${lan} %>">
      <div class="col-md-6">
        <form class="form-horizontal" id="dhcp_<%= ${lan} %>" name="dhcp" data-order="<%= ${lan} %>">
          <div class="form-group">
            <label for="startip_<%= ${lan} %>" class="col-sm-3 control-label"><%= ${_LANG_Form_Start_IP} %></label>
<%
eval $(ipcalc.sh $ipaddr $netmask)
start_ip_prefix=$(echo "$NETWORK" | sed 's#\.[0-9]*$#\.#')
end_ip="$(echo "$BROADCAST" | sed 's#\.[0-9]*$#\.#')$(expr $(echo "$BROADCAST" | cut -d '.' -f4) - 1)"
tmp=$(expr $PREFIX - 24)
tmp=$(expr 8 - $tmp)
max_ips=2
for i in $(seq 2 $tmp); do
max_ips=$(expr $max_ips \* 2)
done
max_ips=$(expr $max_ips - 2)
start=;limit=;leasetime=
eval $(echo "$dhcp_str" | grep -E 'dhcp.'${lan}.'start=|limit=|leasetime=' | cut -d '.' -f3-)
if [ -z "$start" ]; then
eval $(cat /usr/shellgui/backup/dhcp.${lan} | cut -d '.' -f3)
fi
%>
            <div class="col-sm-9">
              <div class="input-group">
                <div class="input-group-addon" name="start_ip_prefix"><%= $start_ip_prefix %></div>
                <input type="number" class="form-control" data-validate="vaInt_1_254-vaLength" id="startip_<%= ${lan} %>" name="start" value="<%= $start %>" maxlength="3">
              </div>
              <span class="help-block hidden"><%= ${_LANG_Form_Please_enter_a_valid_} ${_LANG_Form_IP_Address} %>(1-254)</span>
            </div>
          </div>
          <div class="form-group">
            <label for="endip_<%= ${lan} %>" class="col-sm-3 control-label"><%= ${_LANG_Form_Stop_IP} %></label>
            <div class="col-sm-9">
              <input type="text" class="form-control" id="endip_<%= ${lan} %>" name="end_ip" value="<%= ${end_ip} %>" readonly>
            </div>
          </div>
          <div class="form-group">
            <label for="allow_<%= ${lan} %>" class="col-sm-3 control-label"><%= ${_LANG_Form_Available} %></label>
            <div class="col-sm-9">
              <div class="input-group">
                <input type="number" class="form-control" data-validate="vaInt_1-vaLength" id="allow_<%= ${lan} %>" name="limit" value="<%= $limit %>">
                <div class="input-group-addon"><%= ${_LANG_Form_IPS} %>&nbsp;&nbsp;(<%= ${_LANG_Form_most} %><span name="max_ips"><%= $max_ips %></span>&nbsp;&nbsp;<%= ${_LANG_Form_pics} %>)</div>
              </div>
              <span class="help-block hidden"><%= ${_LANG_Form_Please_enter_a_valid_} ${_LANG_Form_Positive_integer} %></span>
            </div>
          </div>
          <div class="form-group">
            <label for="time_<%= ${lan} %>" class="col-sm-3 control-label"><%= ${_LANG_Form_Lease} %></label>
            <div class="col-sm-9">
              <input type="number" class="form-control" data-validate="vaInt_1-vaLength" id="time_<%= ${lan} %>" name="leasetime" value=<% printf $leasetime | grep -Eo '[0-9]*' %> maxlength="6">
              <span class="help-block hidden"><%= ${_LANG_Form_Please_enter_a_valid_} ${_LANG_Form_Positive_integer} %></span>
            </div>
          </div>
          <div class="form-group">
            <div class="col-sm-offset-3 col-sm-9">
              <button type="submit" class="btn btn-default" id="submitbtn_<%= ${lan} %>" data-order="<%= ${lan} %>"><%= ${_LANG_Form_Apply} %></button>
            </div>
          </div>
        </form>
      </div>
    </div>
  </div>
<% done %>
</div>
<div class="modal fade" id="confirmModal" tabindex="-1">
  <div class="modal-dialog">
    <div class="modal-content">
      <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
        <h4 class="modal-title" id="confirm_title"><%= ${_LANG_Form_Warning} %></h4>
      </div>
      <div class="modal-body">
        <h5 id="confirm_text"><%= ${_LANG_Form_Confirm_to_operate_it} %>?</h5>
      </div>
      <div class="modal-footer">
        <button type="submit" class="btn btn-default" id="confirm_submit" data-dismiss="modal"><%= ${_LANG_Form_Apply} %></button>
        <button type="button" class="btn btn-warning" data-dismiss="modal"><%= ${_LANG_Form_Cancel} %></button>
      </div>
    </div>
  </div>
</div>
<% /usr/shellgui/progs/main.sbin h_f
/usr/shellgui/progs/main.sbin h_end '{"js":["/apps/lan/lan.js"]}'
%>
</body>
</html>
