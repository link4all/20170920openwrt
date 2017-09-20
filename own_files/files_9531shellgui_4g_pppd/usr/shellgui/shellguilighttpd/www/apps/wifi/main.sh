#!/usr/bin/haserl
<%
shellgui '{"action":"check_session","session_type":"http-session","session":"'"$COOKIE_session"'"}' &>/dev/null
[ $? -ne 0 ] && printf "Location: /?app=login\r\n\r\n" && return 1
eval $(/usr/shellgui/progs/main.sbin l_p '_LANG_Form_|_LANG_App_' ${FORM_app} $COOKIE_lang)
%>
<!DOCTYPE html>
<html>
<% /usr/shellgui/progs/main.sbin h_h '{"title":"'"${_LANG_Form_Shellgui_Web_Control}"'"}'
%>
<body>
<div id="header">
<% /usr/shellgui/progs/main.sbin h_sf
/usr/shellgui/progs/main.sbin h_nav '{"active":"wifi"}' %>
</div>
<%
wifi detect >/tmp/wireless_tmp
wireless_str=$(uci show wireless -X | sed "s#' '# #g")
if [ $(echo "$wireless_str" | grep -cE '=wifi-device$') -ne $(uci -c/tmp show -X wireless_tmp | grep -cE '=wifi-device$') ]; then
	wireless_tmp_str=$(uci -c/tmp show -X wireless_tmp)
	radios=$(echo "$wireless_tmp_str" | grep -E '=wifi-device$' | cut -d '=' -f1 | cut -d '.' -f2)
	last_num=$(echo "$wireless_str" | grep -E '=wifi-device$' | cut -d '=' -f1 | grep -Eo '[0-9]*$')
	last_num=${last_num:--1}
	touch /etc/config/wireless
	for radio in $radios; do
	eval $(uci -c/tmp show -X wireless_tmp | grep "\.${radio}\." | cut -d '.' -f3-)
	if ! grep -qE "path=[.]${path}" /etc/config/wireless; then
		last_num=$((${last_num} + 1))
		uci batch <<EOF
set wireless.radio${last_num}=wifi-device
set wireless.radio${last_num}.type="${type}"
set wireless.radio${last_num}.channel="${channel}"
set wireless.radio${last_num}.hwmode="${hwmode}"
set wireless.radio${last_num}.path="${path}"
set wireless.radio${last_num}.htmode="${htmode}"
set wireless.radio${last_num}.disabled='1'
EOF
		uci add wireless wifi-iface &>/dev/null
		uci batch <<EOF
set wireless.@wifi-iface[-1].device="radio${last_num}"
set wireless.@wifi-iface[-1].network='lan'
set wireless.@wifi-iface[-1].mode='ap'
set wireless.@wifi-iface[-1].ssid='ShellGui-new'
set wireless.@wifi-iface[-1].encryption='none'
set wireless.@wifi-iface[-1].disabled='1'
EOF
uci commit wireless
touch /tmp/wifi.restartnw
	fi
	done
wireless_str=$(uci show wireless -X  | sed "s#' '# #g")
w_u_b_s=$(ubus call -v network.wireless status)
fi
rm -f /tmp/wireless_tmp
w_i_s=$(echo "$wireless_str" | grep '=wifi-iface$')
w_e_i_s=$(uci show wireless | grep '=wifi-iface$')
w_i_s=${w_i_s%%'='*};w_i_s=${w_i_s#*'.'}
w_e_i_s=${w_e_i_s%%'='*};w_e_i_s=${w_e_i_s#*'.'}
echo "$w_i_s" >/tmp/w_i_s.tmp
echo "$w_e_i_s" >/tmp/w_e_i_s.tmp
eval $(awk 'NR==FNR{a[FNR]=$0;next}{print a[FNR] "=\"" $0"\""}' /tmp/w_i_s.tmp /tmp/w_e_i_s.tmp)
rm -f /tmp/w_*i_s.tmp
network_str=$(uci show network -X)
dhcp_str=$(uci show dhcp -X)
ifces=$(echo "$network_str" | grep '=interface$' | cut -d  '=' -f1 | cut -d '.' -f2)
for ifce in $ifces; do
type=;proto=;ipaddr=
eval $(echo "$network_str" | grep 'network\.'${ifce}'\.' | cut -d '.' -f3-)
[ "$type" = "bridge" ] && [ "$proto" = "static" ] && [ -n "$ipaddr" ] && lans="$lans ${ifce}"
done
nics=$(echo "$wireless_str" | grep '=wifi-device$' | cut -d  '=' -f1 | cut -d '.' -f2)
for nic in $nics; do
num=$(echo "${nic}" | grep -Eo '[0-9]*$')
if [ $(iw phy${num} info | grep -c 'VHT Capabilities') -gt 0 ] || iw phy${num} info | grep -q "Band 2" ; then
	nic_5gs="$nic_5gs $nic"
else
	nic_24gs="$nic_24gs $nic"
fi
done
%>
<div class="container" id="main">
<div class="container">
  <div class="pull-right"><a target="_blank" href="http://shellgui-docs.readthedocs.io/<%= ${COOKIE_lang//-*/} %>/master/<%= ${_LANG_App_type// /-} %>.html#setting-<%= ${FORM_app}"("${_LANG_App_name// /-}")" %>"><span class="icon-link"></span></a></div>
</div>
    <div class="content">
      <ul class="nav nav-tabs">
<%
for nic in $nic_24gs; do
%>
        <li class="active">
        	<a href="#net24g_<%= ${nic} %>" data-toggle="tab">
        		2.4G<%= ${_LANG_Form_Network} %>:&nbsp;&nbsp;<br class="visible-xs-block"><%= ${nic} %>
        	</a>
    	</li>
<%
done
for nic in $nic_5gs; do
%>
        <li>
        	<a href="#net5g_<%= ${nic} %>" data-toggle="tab">
        		5G<%= ${_LANG_Form_Network} %>:&nbsp;&nbsp;<br class="visible-xs-block"><%= ${nic} %>
    		</a>
		</li>
<% done %>
      </ul>

      <div class="tab-content">

<%
for nic in $nic_24gs; do
disabled=
eval $(echo "$wireless_str" | grep "^wireless\.${nic}" | grep -v '=wifi-device$' | cut -d '.' -f3-)
[ -z "$disabled" ] && disabled=0
w_u_b_s_n=$(echo "$w_u_b_s" | jshon -e "${nic}" -e "interfaces" -a -e "section" -u -p -e "ifname" -u)
if echo "${nic}" | grep -qE '^ra[0-9]'; then
%>
        <div class="tab-pane active" id="net24g_<%= ${nic} %>"  data-nic="<%= ${nic} %>">
          <div class="row">
            <div class="col-md-6">
              <div class="row">
                <div class="col-xs-3">
                  <label for="" class="pull-right"><%= ${_LANG_Form_Switch} %></label>
                </div>
                <div class="col-xs-9">
                  <div class="switch-ctrl head-switch" data-toggle="modal" data-target="#confirm_modal">
                    <input type="checkbox" name="" id="switch_<%= ${nic} %>" value="" <% [ $disabled -eq 0 ] && printf 'checked' || printf '' %>>
                    <label for="switch_<%= ${nic} %>"><span></span></label>
                  </div>
                </div>
              </div>
            </div>
          </div>
          <div class="row header">
            <form class="col-md-6 form-horizontal" id="wifi_set_<%= ${nic} %>">
              <div class="form-group">
                <label for="wifirode" class="col-sm-3 control-label"><%= ${_LANG_Form_Channel} %></label>
                <div class="col-sm-9">
                  <select type="text" class="form-control" name="channel">
                    <option value="auto" <% [ "${channel}" = "auto" ] && printf 'selected="selected"' %> ><%= ${_LANG_Form_Auto_11} %></option>
                  	<% for channel_html in $(seq 1 13); do %>
					<option value="<%= ${channel_html} %>" <% [ ${channel} -eq ${channel_html} ] && printf 'selected="selected"' %>><%= ${channel_html} %></option>
					<% done %>
                  </select>
                  <p class="help-block"><%= ${_LANG_Form_Commonly_used_channel} %>: [1,6,11]</p>
                </div>
              </div>
              <div class="form-group">
                <label for="channelwide" class="col-sm-3 control-label"><%= ${_LANG_Form_Htmode} %></label>
                <div class="col-sm-9">
                  <select type="text" class="form-control" name="ht">
                    <option value="20" <% [ ${ht} -eq 20 ] && printf 'selected="selected"' %>>20M</option>
                    <option value="40" <% [ ${ht} -eq 40 ] && printf 'selected="selected"' %>>40M</option>
                  </select>
                </div>
              </div>
              <div class="form-group">
                <label for="powlevel" class="col-sm-3 control-label"><%= ${_LANG_Form_Txpower} %></label>
                <div class="col-sm-9">
                  <select type="text" class="form-control" name="txpower">
                    <option value="max" <% [ ${txpower} -gt 20 ] && printf 'selected="selected"' %>><%= ${_LANG_Form_Max} %></option>
                    <option value="mid" <% [ ${txpower} -ge 10 ] && [ ${txpower} -le 20 ] && printf 'selected="selected"' %>><%= ${_LANG_Form_Mid} %></option>
                    <option value="min" <% [ ${txpower} -lt 10 ] && printf 'selected="selected"' %>><%= ${_LANG_Form_Min} %></option>
                  </select>
                </div>
              </div>
              <input type="hidden" value="<%= ${nic} %>" name="nic">
              <div class="form-group">
                <div class="col-sm-offset-3 col-sm-9">
                  <button type="submit" class="btn btn-default"><%= ${_LANG_Form_Apply} %></button>
                </div>
              </div>
            </form>
          </div>
          <div class="row" id='ssid_item_<%= ${nic} %>'>
<%
ifaces=$(echo "$wireless_str" | grep '.device=' | sed -e 's#[\"]##g' -e "s#[\']##g" | grep "\.device=${nic}$" | cut -d '.' -f2)
for iface in $ifaces; do
network=;mode=;ssid=;encryption=;key=;disabled=
eval $(echo "$wireless_str" | grep -E '^wireless\.'${iface}'\.' | cut -d '.' -f3-)
[ "$mode" != "ap" ] && continue
[ -z "$disabled" ] && disabled=0
[ -z "$hidden" ] && hidden=0
%>
            <div class="col-sm-6">
              <h2 class="ssid-title">SSID: <span><%= ${ssid} %></span>
                <div class="switch-ctrl" data-toggle="modal" data-target="#confirm_modal">
                  <input type="checkbox" name="" id="switch_${iface}" <% [ $disabled -eq 0  ] && printf 'checked' || printf '' %>>
                  <label for="switch_${iface}"><span></span></label>
                </div>
              </h2>
              <form class="form-horizontal" id="ssid_set_<%= ${iface} %>" name="ssid_set">
                <div class="form-group">
                  <label for="ssid_name" class="col-sm-4 control-label"><%= ${_LANG_Form_SSID} %></label>
                  <div class="col-sm-8">
                    <input type="text" class="form-control" name="ssid" data-validate="vaLength_2" value="<%= ${ssid} %>">
                    <span class="help-block hidden"><%= ${_LANG_Form_SSID_length_must_more_then_2_char} %></span>
                  </div>
                </div>
                <div class="form-group">
                  <label class="col-sm-offset-4 col-sm-8">
                    <input type="checkbox" name="hidden" value="1" <% [ ${hidden} -gt 0 ] && printf 'checked="checked"' %>>&nbsp;&nbsp;<%= ${_LANG_Form_Hide_the_SSID} %>
                  </label>
                </div>
                <div class="form-group">
                  <label for="secretype" class="col-sm-4 control-label"><%= ${_LANG_Form_Encryption} %></label>
                  <div class="col-sm-8">
                    <select type="text" class="form-control" name="encryption" id="encryption_<%= ${iface} %>">
	                    <option value="psk2" <% [ "$encryption" = "psk2" ] && printf 'selected="selected"' %>><%= ${_LANG_Form_WPA2_PSK} %></option>
	                    <option value="mixed-psk" <% [ "$encryption" = "mixed-psk" ] && printf 'selected="selected"' %>><%= ${_LANG_Form_WPA2_Mix_PSK} %></option>
	                    <option value="none" <% [ "$encryption" = "none" ] && printf 'selected="selected"' %>><%= ${_LANG_Form_None} %></option>
                    </select>
                  </div>
                </div>
                <div class="form-group hidden" id="<%= ${iface} %>_key">
                  <label for="" class="col-sm-4 control-label"><%= ${_LANG_Form_Key} %></label>
                  <div class="col-sm-8">
                    <input type="text" class="form-control" id="key_<%= ${iface} %>" name="key" data-validate="vaLength_8" value="<%= ${key} %>">
                    <span class="help-block hidden"><%= ${_LANG_Form_Password_length_must_more_then_8_char} %></span>
                  </div>
                </div>
                <div class="form-group">
                  <label for="ssidnet" class="col-sm-4 control-label"><%= ${_LANG_Form_Network} %></label>
                  <div class="col-sm-8">
                    <select type="text" class="form-control" name="network">
	  					<% for lan in $lans
					    do %>
	                    <option value="<%= ${lan} %>" <% [ "$network" = "${lan}" ] && printf 'selected="selected"' %>><%= ${lan} %></option>
						<% done %>
                    </select>
                  </div>
                </div><div class="form-group">
                  <label for="" class="col-sm-4 control-label"><%= ${_LANG_Form_Mac_Filter} %></label>
                  <div class="col-sm-8">
                    <select name="macfilter" class="form-control" id="">
                      <option value="disabled"><%= ${_LANG_Form_Disabled_Mode} %></option>
                      <option value="deny" <% [ "${macfilter}" = "deny" ] && printf 'selected' %>><%= ${_LANG_Form_Deny_Mode} %></option>
                      <option value="whitelist" <% [ "${macfilter}" = "whitelist" ] && printf 'selected' %>><%= ${_LANG_Form_Whitelist_Mode} %></option>
                    </select>
                  </div>
                </div>
                <div class="form-group">
                  <label for="" class="col-sm-4 control-label"><%= ${_LANG_Form_Mac_List} %></label>
                    <div class="col-sm-8 form-control-static maclist-container">
                    <% for mac in ${maclist}; do %>
                      <span class="mac-item"><span class="mac-text"><%= ${mac} %></span> <span class="icon-cross"></span>&nbsp;&nbsp;</span>
                    <% done %>
                    </div>
                </div>
                <div class="form-group">
                  <label for="" class="col-sm-4 control-label"></label>
                  <div class="col-sm-8">
                    <div class="input-group">
                      <input type="text" class="form-control add-mac-input">
                      <span class="input-group-btn">
                        <button class="btn btn-success add-mac-btn" type="button"><span class="icon-plus"></span></button>
                      </span>
                    </div>
                    <span class="help-block hidden">请输入合法的Mac地址!</span>
                  </div>
                </div>
                <div class="form-group">
                  <div class="col-sm-offset-4 col-sm-8">
                    <button type="submit" class="btn btn-default"><%= ${_LANG_Form_Apply} %></button>
                  </div>
                </div>
              </form>
            </div>
<% done %>
          </div>
        </div>

<% else
%>
        <div class="tab-pane active" id="net24g_<%= ${nic} %>"  data-nic="<%= ${nic} %>">
          <div class="row">
            <div class="col-md-6">
              <div class="row">
                <div class="col-xs-3">
                  <label for="" class="pull-right"><%= ${_LANG_Form_Switch} %></label>
                </div>
                <div class="col-xs-9">
                  <div class="switch-ctrl head-switch" id="switch_ctrl_<%= ${nic} %>" data-toggle="modal" data-target="#confirm_modal">
                    <input type="checkbox" name="nic-switch" id="switch_<%= ${nic} %>" value="" <% [ $disabled -eq 0 ] && printf 'checked' || printf '' %>>
                    <label for="switch_<%= ${nic} %>"><span></span></label>
                  </div>
                </div>
              </div>
            </div>
          </div>
          <div class="row header">
            <form class="col-md-6 form-horizontal" id="wifi_set_<%= ${nic} %>" name="wifi_set">
              <div class="form-group">
                <label for="channel_<%= ${nic} %>" class="col-sm-3 control-label"><%= ${_LANG_Form_Channel} %></label>
                <div class="col-sm-9">
                  <select type="text" class="form-control 24_channel" name="channel" id="channel_<%= ${nic} %>">
                    <option value="auto" <% [ "${channel}" = "auto" ] && printf 'selected="selected"' %> ><%= ${_LANG_Form_Auto_11} %></option>
                  	<% for channel_html in $(seq 1 13)
					do %>
					<option value="<%= ${channel_html} %>" <% [ ${channel} -eq ${channel_html} ] && printf 'selected="selected"' %>><%= ${channel_html} %></option>
					<% done %>
                  </select>
                  <p class="help-block"><%= ${_LANG_Form_Commonly_used_channel} %>: [1,6,11]</p>
                </div>
              </div>
              <input type="hidden" value="<%= ${nic} %>" name="nic">
              <div class="form-group" id="ht_container_<%= ${nic} %>">
                <label for="ht_<%= ${nic} %>" class="col-sm-3 control-label"><%= ${_LANG_Form_Htmode} %></label>
                <div class="col-sm-9">
                  <select type="text" class="form-control" name="htmode" id="ht_<%= ${nic} %>">
                    <option value="HT20" <% [ ${htmode} = "HT20" ] && printf 'selected="selected"' %>>20M</option>
                    <option value="HT40" <% echo "${htmode}" | grep -q "HT40" && printf 'selected="selected"' %>>40M</option>
                  </select>
                </div>
              </div>
              <div class="form-group">
                <label for="txpower_<%= ${nic} %>" class="col-sm-3 control-label"><%= ${_LANG_Form_Txpower} %></label>
                <div class="col-sm-9">
                  <select type="text" class="form-control" name="txpower" id="txpower_<%= ${nic} %>">
                    <option value="max" <% [ ${txpower} -gt 20 ] && printf 'selected="selected"' %>><%= ${_LANG_Form_Max} %></option>
                    <option value="mid" <% [ ${txpower} -ge 10 ] && [ ${txpower} -le 20 ] && printf 'selected="selected"' %>><%= ${_LANG_Form_Mid} %></option>
                    <option value="min" <% [ ${txpower} -lt 10 ] && printf 'selected="selected"' %>><%= ${_LANG_Form_Min} %></option>
                  </select>
                </div>
              </div>
              <div class="form-group">
                <div class="col-sm-offset-3 col-sm-9">
                  <button type="submit" class="btn btn-default"><%= ${_LANG_Form_Apply} %></button>
                </div>
              </div>
            </form>
          </div>
          <div class="row" id='ssid_item_<%= ${nic} %>'>
<%
ifaces=$(echo "$wireless_str" | grep '.device=' | sed -e 's#[\"]##g' -e "s#[\']##g" | grep "\.device=${nic}$" | cut -d '.' -f2)
for iface in $ifaces; do
network=;mode=;ssid=;encryption=;key=;disabled=;macfilter=;maclist=
eval $(echo "$wireless_str" | grep -E '^wireless\.'${iface}'\.' | cut -d '.' -f3-)
[ "$mode" != "ap" ] && continue
[ -z "$disabled" ] && disabled=0
[ -z "$hidden" ] && hidden=0
xcfg=$(eval echo '$'${iface})
xcfg=${xcfg//[\[|\]]/.}
wnic=$(echo "$w_u_b_s_n" | sed -n "/$xcfg/{n;p;}")
%>
            <div class="col-sm-6" data-nic="<%= ${nic} %>">
              <h2 class="ssid-title">SSID: <span><%= ${ssid} %></span>
                <div class="switch-ctrl" id="switch_ctrl_<%= ${iface} %>" data-toggle="modal" data-target="#confirm_modal">
                  <input type="checkbox" name="ssid-switch" id="switch_<%= ${iface} %>" <% [ $disabled -eq 0  ] && printf 'checked' || printf '' %>>
                  <label for="switch_<%= ${iface} %>"><span></span></label>
                </div>
              </h2>
              <form class="form-horizontal" id="ssid_set_<%= ${iface} %>" name="ssid_set">
                <div class="form-group">
                  <label for="ssid_<%= ${iface} %>" class="col-sm-4 control-label"><%= ${_LANG_Form_SSID} %></label>
                  <div class="col-sm-8">
                    <input type="text" class="form-control" name="ssid" data-validate="vaLength_2" id="ssid_<%= ${iface} %>" value="<%= ${ssid} %>">
                    <span class="help-block hidden"><%= ${_LANG_Form_SSID_length_must_more_then_2_char} %></span>
                  </div>
                </div>
                <div class="form-group">
                  <label class="col-sm-offset-4 col-sm-8">
                    <input type="checkbox" name="hidden" value="1" <% [ ${hidden} -gt 0 ] && printf 'checked="checked"' %>>&nbsp;&nbsp;<%= ${_LANG_Form_Hide_the_SSID} %>
                  </label>
                </div>
                <div class="form-group">
                  <label for="encryption_<%= ${iface} %>" class="col-sm-4 control-label"><%= ${_LANG_Form_Encryption} %></label>
                  <div class="col-sm-8">
                    <select type="text" class="form-control" name="encryption" id="encryption_<%= ${iface} %>">
	                    <option value="psk2" <% [ "$encryption" = "psk2" ] && printf 'selected="selected"' %>><%= ${_LANG_Form_WPA2_PSK} %></option>
	                    <option value="mixed-psk" <% [ "$encryption" = "mixed-psk" ] && printf 'selected="selected"' %>><%= ${_LANG_Form_WPA2_Mix_PSK} %></option>
	                    <option value="none" <% [ "$encryption" = "none" ] && printf 'selected="selected"' %>><%= ${_LANG_Form_None} %></option>
                    </select>
                  </div>
                </div>
                <div class="form-group hidden" id="<%= ${iface} %>_key">
                  <label for="key_<%= ${iface} %>" class="col-sm-4 control-label"><%= ${_LANG_Form_Key} %></label>
                  <div class="col-sm-8">
                    <input type="text" class="form-control" id="key_<%= ${iface} %>" name="key" data-validate="vaLength_8" value="<%= ${key} %>">
                    <span class="help-block hidden"><%= ${_LANG_Form_Password_length_must_more_then_8_char} %></span>
                  </div>
                </div>
                <div class="form-group">
                  <label for="network_<%= ${iface} %>" class="col-sm-4 control-label"><%= ${_LANG_Form_Network} %></label>
                  <div class="col-sm-8">
                    <select type="text" class="form-control" name="network" id="network_<%= ${iface} %>">
	  					<% for lan in $lans
					    do %>
	                    <option value="<%= ${lan} %>" <% [ "$network" = "${lan}" ] && printf 'selected="selected"' %>><%= ${lan} %></option>
						<% done %>
                    </select>
                  </div>
                </div>
                <div class="form-group">
                  <label for="" class="col-sm-4 control-label"><%= ${_LANG_Form_Mac_Filter} %></label>
                  <div class="col-sm-8">
                    <select name="macfilter" class="form-control" id="">
                      <option value="disabled"><%= ${_LANG_Form_Disabled_Mode} %></option>
                      <option value="deny" <% [ "${macfilter}" = "deny" ] && printf 'selected' %>><%= ${_LANG_Form_Deny_Mode} %></option>
                      <option value="whitelist" <% [ "${macfilter}" = "whitelist" ] && printf 'selected' %>><%= ${_LANG_Form_Whitelist_Mode} %></option>
                    </select>
                  </div>
                </div>
                <div class="form-group">
                  <label for="" class="col-sm-4 control-label"><%= ${_LANG_Form_Mac_List} %></label>
                    <div data-maclist-wnic="<%= ${wnic} %>" class="col-sm-8 form-control-static maclist-container">
                    <% for mac in ${maclist}; do %>
                      <span class="mac-item"><span class="mac-text"><%= ${mac} %></span> <span class="icon-cross"></span>&nbsp;&nbsp;</span>
                    <% done %>
                    </div>
                </div>
                <div class="form-group">
                  <label for="" class="col-sm-4 control-label"></label>
                  <div class="col-sm-8">
                    <div class="input-group">
                      <input type="text" class="form-control add-mac-input">
                      <span class="input-group-btn">
                        <button class="btn btn-success add-mac-btn" type="button"><span class="icon-plus"></span></button>
                      </span>
                    </div>
                    <span class="help-block hidden">请输入合法的Mac地址!</span>
                  </div>
                </div>
                <div class="form-group">
                  <div class="col-sm-offset-4 col-sm-8">
                    <button type="submit" class="btn btn-default"><%= ${_LANG_Form_Apply} %></button>
                  </div>
                </div>
              </form>
            </div>
            <div class="col-sm-6">
              <div class="hosts-container hidden table-responsive" data-wnic="<%= ${wnic} %>">
                <table class="table">
                  <caption><%= ${_LANG_Form_Wireless_Client_List} %></caption>
                  <tbody></tbody>
                </table>
              </div>
            </div>
<% done %>
          </div>
        </div>
<%
fi
done
for nic in $nic_5gs; do
disabled=
eval $(echo "$wireless_str" | grep "^wireless\.${nic}" | grep -v '=wifi-device$' | cut -d '.' -f3-)
[ -z "$disabled" ] && disabled=0
w_u_b_s_n=$(echo "$w_u_b_s" | jshon -e "${nic}" -e "interfaces" -a -e "section" -u -p -e "ifname" -u)
%>
        <div class="tab-pane" id="net5g_<%= ${nic} %>" data-nic="<%= ${nic} %>">
          <div class="row">
            <div class="col-md-6">
              <div class="row">
                <div class="col-xs-3">
                  <label for="" class="pull-right"><%= ${_LANG_Form_Switch} %></label>
                </div>
                <div class="col-xs-9">
                  <div class="switch-ctrl head-switch" id="switch_ctrl_<%= ${nic} %>" data-toggle="modal" data-target="#confirm_modal">
                    <input type="checkbox" name="nic-switch" id="switch_<%= ${nic} %>" value="" <% [ $disabled -eq 0 ] && printf 'checked' || printf '' %>>
                    <label for="switch_<%= ${nic} %>"><span></span></label>
                  </div>
                </div>
              </div>
            </div>
          </div>
          <div class="row header">
            <form class="col-md-6 form-horizontal" data-form="5g_form" id="wifi_set_<%= ${nic} %>" name="wifi_set">
              <div class="form-group">
                <label for="channel_<%= ${nic} %>" class="col-sm-3 control-label"><%= ${_LANG_Form_Channel} %></label>
                <div class="col-sm-9">
                <!-- <script> var channel_<%= ${nic} %>=<%= ${channel} %>;</script> -->
                  <select type="text" data-channel="<%= ${channel} %>" class="form-control 5g_channel" name="channel" id="channel_<%= ${nic} %>">
                    <!-- <option value="auto" <% [ "${channel}" = "auto" ] && printf 'selected="selected"' %>>自动</option>
          					<% for channel_html in 33 44 48 52 56 60 64 149 153 157 161 165; do %>
          					<option value="<%= ${channel_html} %>" <% [ ${channel} -eq ${channel_html} ] && printf 'selected="selected"' %>><%= ${channel_html} %></option>
          					<% done %> -->
                  </select>
                  <p class="help-block"><%= ${_LANG_Form_Commonly_used_channel} %>: [36,40,44,48,149,153,157,161]</p>
                </div>
              </div>
              <input type="hidden" value="<%= ${nic} %>" name="nic">
              <div class="form-group" id="ht_container_<%= ${nic} %>">
                <label for="ht_<%= ${nic} %>" class="col-sm-3 control-label"><%= ${_LANG_Form_Htmode} %></label>
                <div class="col-sm-9">
                  <select type="text" class="form-control" name="htmode" id="ht_<%= ${nic} %>">
					          <option value="HT20" <% echo ${htmode} | grep -q 20 && printf 'selected="selected"' %>>20M</option>
                    <option value="HT40+" <% echo ${htmode} | grep -q 40 && printf 'selected="selected"' %>>40M</option>
                    <option value="VHT80" <% echo ${htmode} | grep -q 80 && printf 'selected="selected"' %>>80M</option>
                  </select>
                </div>
              </div>
              <div class="form-group">
                <label for="txpower_<%= ${nic} %>" class="col-sm-3 control-label"><%= ${_LANG_Form_Txpower} %></label>
                <div class="col-sm-9">
                  <select type="text" class="form-control" name="txpower" id="txpower_<%= ${nic} %>">
					<option value="max" <% [ ${txpower} -gt 20 ] && printf 'selected="selected"' %>><%= ${_LANG_Form_Max} %></option>
                    <option value="mid" <% [ ${txpower} -ge 10 ] && [ ${txpower} -le 20 ] && printf 'selected="selected"' %>><%= ${_LANG_Form_Mid} %></option>
                    <option value="min" <% [ ${txpower} -lt 10 ] && printf 'selected="selected"' %>><%= ${_LANG_Form_Min} %></option>
                  </select>
                </div>
              </div>
              <div class="form-group">
                <div class="col-sm-offset-3 col-sm-9">
                  <button type="submit" class="btn btn-default"><%= ${_LANG_Form_Apply} %></button>
                </div>
              </div>
            </form>
          </div>
          <div class="row" id='ssid_item_<%= ${nic} %>'>
<%
ifaces=$(echo "$wireless_str" | grep '.device=' | sed -e 's#[\"]##g' -e "s#[\']##g" | grep "\.device=${nic}$" | cut -d '.' -f2)
for iface in $ifaces; do
network=;mode=;ssid=;encryption=;key=;disabled=;macfilter=;maclist=
eval $(echo "$wireless_str" | grep -E '^wireless\.'${iface}'\.' | cut -d '.' -f3-)
[ "$mode" != "ap" ] && continue
[ -z "$disabled" ] && disabled=0
[ -z "$hidden" ] && hidden=0
xcfg=$(eval echo '$'${iface})
xcfg=${xcfg//[\[|\]]/.}
wnic=$(echo "$w_u_b_s_n" | sed -n "/$xcfg/{n;p;}")
%>
            <div class="col-sm-6" data-nic="<%= ${nic} %>">
              <h2 class="ssid-title">SSID: <span><%= ${ssid} %></span>
                <div class="switch-ctrl" id="switch_ctrl_<%= ${iface} %>" data-toggle="modal" data-target="#confirm_modal">
                  <input type="checkbox"  name="ssid-switch" id="switch_<%= ${iface} %>" value="" <% [ $disabled -eq 0 ] && printf 'checked' || printf '' %>>
                  <label for="switch_<%= ${iface} %>"><span></span></label>
                </div>
              </h2>
              <form class="form-horizontal" name="ssid_set" id="ssid_set_<%= ${iface} %>">
                <div class="form-group">
                  <label for="ssid_<%= ${iface} %>" class="col-sm-4 control-label"><%= ${_LANG_Form_SSID} %></label>
                  <div class="col-sm-8">
                    <input type="text" class="form-control" name="ssid" data-validate="vaLength_2" value="<%= ${ssid} %>" id="ssid_<%= ${iface} %>">
                    <span class="help-block hidden"><%= ${_LANG_Form_SSID_length_must_more_then_2_char} %></span>
                  </div>
                </div>
                <div class="form-group">
                  <label class="col-sm-offset-4 col-sm-8">
                    <input type="checkbox" name="hidden" value="1" <% [ ${hidden} -gt 0 ] && printf 'checked="checked"' %>>&nbsp;&nbsp;<%= ${_LANG_Form_Hide_the_SSID} %>
                  </label>
                </div>
                <div class="form-group">
                  <label for="encryption_<%= ${iface} %>" class="col-sm-4 control-label"><%= ${_LANG_Form_Encryption} %></label>
                  <div class="col-sm-8">
                    <select type="text" class="form-control" name="encryption" id="encryption_<%= ${iface} %>">
                    	<option value="psk2" <% [ "$encryption" = "psk2" ] && printf 'selected="selected"' %>><%= ${_LANG_Form_WPA2_PSK} %></option>
                        <option value="mixed-psk" <% [ "$encryption" = "mixed-psk" ] && printf 'selected="selected"' %>><%= ${_LANG_Form_WPA2_Mix_PSK} %></option>
                        <option value="none" <% [ "$encryption" = "none" ] && printf 'selected="selected"' %>><%= ${_LANG_Form_None} %></option>
                    </select>
                  </div>
                </div>
                <div class="form-group hidden" id="<%= ${iface} %>_key">
                  <label for="key_<%= ${iface} %>" class="col-sm-4 control-label"><%= ${_LANG_Form_Key} %></label>
                  <div class="col-sm-8">
                    <input type="text" class="form-control" id="key_<%= ${iface} %>" name="key" data-validate="vaLength_8" value="<%= ${key} %>">
                    <span class="help-block hidden"><%= ${_LANG_Form_Password_length_must_more_then_8_char} %></span>
                  </div>
                </div>
                <div class="form-group">
                  <label for="network_<%= ${iface} %>" class="col-sm-4 control-label"><%= ${_LANG_Form_Network} %></label>
                  <div class="col-sm-8">
                    <select type="text" class="form-control" name="network" id="network_<%= ${iface} %>">
	                    <% for lan in $lans; do %>
	                        <option value="<%= ${lan} %>" <% [ "$network" = "${lan}" ] && printf 'selected="selected"' %>><%= ${lan} %></option>
						<% done %>
                    </select>
                  </div>
                </div>
                <div class="form-group">
                  <label for="" class="col-sm-4 control-label"><%= ${_LANG_Form_Mac_Filter} %></label>
                  <div class="col-sm-8">
                    <select name="macfilter" class="form-control" id="">
                      <option value="disabled"><%= ${_LANG_Form_Disabled_Mode} %></option>
                      <option value="deny" <% [ "${macfilter}" = "deny" ] && printf 'selected' %>><%= ${_LANG_Form_Deny_Mode} %></option>
                      <option value="whitelist" <% [ "${macfilter}" = "whitelist" ] && printf 'selected' %>><%= ${_LANG_Form_Whitelist_Mode} %></option>
                    </select>
                  </div>
                </div>
                <div class="form-group">
                  <label for="" class="col-sm-4 control-label"><%= ${_LANG_Form_Mac_List} %></label>
                    <div data-maclist-wnic="<%= ${wnic} %>" class="col-sm-8 form-control-static maclist-container">
                    <% for mac in ${maclist}; do %>
                      <span class="mac-item"><span class="mac-text"><%= ${mac} %></span> <span class="icon-cross"></span>&nbsp;&nbsp;</span>
                    <% done %>
                    </div>
                </div>
                <div class="form-group">
                  <label for="" class="col-sm-4 control-label"></label>
                  <div class="col-sm-8">
                    <div class="input-group">
                      <input type="text" class="form-control add-mac-input">
                      <span class="input-group-btn">
                        <button class="btn btn-success add-mac-btn" type="button"><span class="icon-plus"></span></button>
                      </span>
                    </div>
                    <span class="help-block hidden">请输入合法的Mac地址!</span>
                  </div>
                </div>
                <div class="form-group">
                  <div class="col-sm-offset-4 col-sm-8">
                    <button type="submit" class="btn btn-default"><%= ${_LANG_Form_Apply} %></button>
                  </div>
                </div>
              </form>
            </div>
            <div class="col-sm-6">
              <div class="hosts-container hidden table-responsive" data-wnic="<%= ${wnic} %>">
                <table class="table">
                  <caption><%= ${_LANG_Form_Wireless_Client_List} %></caption>
                  <tbody></tbody>
                </table>
              </div>
            </div>
<% done %>
          </div>
        </div>
<% done
%>
      </div>
    </div>
</div>
<div class="modal fade" id="confirm_modal" tabindex="-1">
  <div class="modal-dialog" role="document">
    <div class="modal-content">
      <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
        <h4 class="modal-title" id="confirm_modal_title"><%= ${_LANG_App_name} %></h4>
      </div>
      <div class="modal-body center-block">
        <p id="modal_ensure_text" class="confirm-msg"></p>
        <p id="modal_result_text" class="text-danger confirm-msg"></p>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-default" data-dismiss="modal"><%= ${_LANG_Form_Cancel} %></button>
        <button type="button" class="btn btn-danger" id="disable_btn" data-dismiss="modal"><%= ${_LANG_Form_Confirm} %></button>
      </div>
    </div>
  </div>
</div>
<div class="modal fade" id="killHostModal"  tabindex="-1">
  <div class="modal-dialog">
    <div class="modal-content">
      <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal"><span aria-hidden="true">&times;</span></button>
        <h4 class="modal-title">禁用主机</h4>
      </div>
      <form id="killHostForm">
      <div class="modal-body">
        <input type="hidden" name="mac" value="">
        <div class="form-horizontal">
          <div class="form-group">
            <label class="control-label col-sm-3">Mac</label>
            <div class="col-sm-9">
              <p class="form-control-static" id="host-mac"></p>
            </div>
          </div>
          <div class="form-group">
            <label for="time" class="control-label col-sm-3">禁用时长</label>
            <div class="col-sm-9">
              <select name="time" class="form-control">
                <option value="60000">1分钟</option>
                <option value="300000">5分钟</option>
                <option value="1800000">30分钟</option>
                <option value="43200000">12小时</option>
                <option value="86400000">24小时</option>
              </select>
            </div>
          </div>
        </div>
      </div>
      <div class="modal-footer">
        <button type="submit" class="btn btn-default">确认</button>
        <button type="button" class="btn btn-warning" data-dismiss="modal">取消</button>
      </div>
      </form>
    </div>
  </div>
</div>
<% /usr/shellgui/progs/main.sbin h_f %>
<script>var UI = {};</script>
<% /usr/shellgui/progs/main.sbin h_end %>
<script>
<% /usr/shellgui/progs/main.sbin l_p_J '_LANG_JsUI_' ${FORM_app} $COOKIE_lang %>
</script>
<script src="/apps/wifi/wifi.js"></script>
</body>
</html>
