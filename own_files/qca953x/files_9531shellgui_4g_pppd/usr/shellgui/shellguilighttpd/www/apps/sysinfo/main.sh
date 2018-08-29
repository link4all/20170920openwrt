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
<% /usr/shellgui/progs/main.sbin hm '{"1":{"title":"'${_LANG_App_type}'","url":"/?app=home#'${_LANG_App_type}'"},"2":{"title":"'${_LANG_App_name}'"}}'
release_info=$(shellgui '{"action":"get_release_info"}' | jshon) %>
    	<div class="row">
            <div class="app app-item col-lg-12">
                <div class="row">
                    <div class="col-sm-6">
                        <h2 class="app-sub-title"><%= ${_LANG_Form_Host_name} %></h2>
                    </div>
                    <div class="col-sm-offset-1 col-sm-6">
                        <div class="text-left">
                            <form class="form-inline" name="hostname_edit" id="hostname_edit">
                                <div class="form-group">
                                    <input class="form-control" name="hostname" id="hostname" required placeholder="<%= ${_LANG_Form_Plz_input_host_name} %>" value="<% uci get system.@system[0].hostname %>">
    							</div>
                                <div class="form-group">
                                    <button type="submit" class="btn btn-default btn-block" id="submit_hostname"><%= $_LANG_Form_Save %></button>
                                </div>
                                <span class="help-block hidden"><%= ${_LANG_Form_Please_enter_a_valid_} ${_LANG_Form_Host_name} %></span>
                            </form>
                        </div>
                    </div>
                </div>
                <div class="row">
                    <div class="col-sm-6">
                        <h2 class="app-sub-title"><%= ${_LANG_Form_Kernel_info} %></h2>
                    </div>
                    <div class="col-sm-offset-1 col-sm-6">
                        <div>
                            <table class="table table-hover text-left">
                                <tr>
                                    <th><%= ${_LANG_Form_Current_time} %></th>
                                    <td><% date %></td>
                                </tr>
                                <tr>
                                    <th><%= ${_LANG_Form_Operating_system} %></th>
                                    <td><% echo "$release_info" | jshon -e "kernel" -e "sysname" -u %></td>
                                </tr>
                                <tr>
                                    <th><%= ${_LANG_Form_Kernel_version} %></th>
                                    <td><% echo "$release_info" | jshon -e "kernel" -e "release" -u %></td>
                                </tr>
                                <tr>
                                    <th><%= ${_LANG_Form_Hardware_architecture} %></th>
                                    <td><% echo "$release_info" | jshon -e "kernel" -e "machine" -u %></td>
                                </tr>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
            <hr class="col-lg-12">
            <div class="app app-item col-lg-12">
                <div class="row">
                    <div class="col-sm-6">
                        <h2 class="app-sub-title"><%= ${_LANG_Form_Processor_information} %></h2>
                    </div>
                    <div class="col-sm-offset-1 col-sm-6">
                        <table class="table-hover table text-left">
                            <tr>
                                <th><%= ${_LANG_Form_Processor_model} %></th>
                                <td><% (grep "system type" /proc/cpuinfo || grep "model name" /proc/cpuinfo) | cut -d ":" -f2- %></td>
                            </tr>
                            <tr>
                                <th><%= ${_LANG_Form_CPUS} %></th>
                                <td><% grep -c "processor" /proc/cpuinfo %></td>
                            </tr>
                            <tr>
							<% BogoMIPS=$(grep "BogoMIPS" /proc/cpuinfo | cut -d ":" -f2-); cpu_MHz=$(grep "cpu MHz" /proc/cpuinfo | cut -d ":" -f2-)
							if [ -n "$BogoMIPS" ];then
							%>
								<th>BogoMIPS</th>
                                <td><%= ${BogoMIPS} %></td>
							<% else %>
								<th>cpu MHz</th>
                                <td><%= ${cpu_MHz} %></td>
							<% fi %>
                            </tr>
                        </table>
                    </div>
                </div>
            </div>
            <hr class="col-lg-12">
<% mem_status=$(shellgui '{"action":"get_mem_status","readable":1}') %>
            <div class="app app-item col-lg-12">
                <div class="row">
                    <div class="col-sm-6">
                        <h2 class="app-sub-title"><%= ${_LANG_Form_MEM_info} %></h2>
                    </div>
                    <div class="col-sm-offset-1 col-sm-6">
                        <table class="table-hover table text-left">
                            <tr>
                                <th><%= ${_LANG_Form_Total_MEM} %></th>
                                <td><% echo "$mem_status" | jshon -e "mem" -e "total" -u %></td>
                            </tr>
                            <tr>
                                <th><%= ${_LANG_Form_Total_swap} %></th>
                                <td><% echo "$mem_status" | jshon -e "swap" -e "total" -u %></td>
                            </tr>
                        </table>
                    </div>
                </div>
            </div>
            <hr class="col-lg-12">
            <div class="app app-item col-lg-12">
                <div class="row">
                    <div class="col-sm-6">
                        <h2 class="app-sub-title"><%= ${_LANG_Form_Disk_device} %></h2>
                    </div>
                    <div class="col-sm-offset-1 col-sm-6">
                        <table class="table-hover table text-left">
                            <tr>
                                <th><%= ${_LANG_Form_Rootfs_space} %></th>
                                <td>
<% df -h | grep -m 1 ' /$' | while read rootfs total used ava used_p mounton; do
printf "${_LANG_Form_Total}: ${total}${_LANG_Form_Used}: ${used}${_LANG_Form_Available}: ${ava}${_LANG_Form_Accounting}: ${used_p}%"
done %>
                                </td>
                            </tr>
                        </table>
                    </div>
                </div>
            </div>
            <hr class="col-lg-12">
            <div class="app app-item col-lg-12">
                <div class="row">
                    <div class="col-sm-6">
                        <h2 class="app-sub-title"><%= ${_LANG_Form_Time_setting} %></h2>
                    </div>
                    <div class="col-sm-offset-1 col-sm-6">
                        <form class="form-horizontal text-left" name="timezone_edit" id="timezone_edit">
                            <div class="form-group">
                                <label for="" class="col-sm-5 control-label"><%= ${_LANG_Form_Time_zone} %></label>
                                <div class="col-sm-7">
<%
case $(uci get system.@system[0].timezone | tr -d '\n') in
UTC12)
tz_1='selected=""'
;;
UTC11)
tz_2='selected=""'
;;
UTC10)
tz_3='selected=""'
;;
NAST9NADT,M3.2.0/2,M11.1.0/2)
tz_4='selected=""'
;;
PST8PDT,M3.2.0/2,M11.1.0/2)
tz_5='selected=""'
;;
UTC7)
tz_6='selected=""'
;;
MST7MDT,M3.2.0/2,M11.1.0/2)
tz_7='selected=""'
;;
UTC6)
tz_8='selected=""'
;;
CST6CDT,M3.2.0/2,M11.1.0/2)
tz_9='selected=""'
;;
UTC5)
tz_10='selected=""'
;;
EST5EDT,M3.2.0/2,M11.1.0/2)
tz_11='selected=""'
;;
UTC4)
tz_12='selected=""'
;;
AST4ADT,M3.2.0/2,M11.1.0/2)
tz_13='selected=""'
;;
BRWST4BRWDT,M10.3.0/0,M2.5.0/0)
tz_14='selected=""'
;;
NST3:30NDT,M3.2.0/0:01,M11.1.0/0:01)
tz_15='selected=""'
;;
WGST3WGDT,M3.5.6/22,M10.5.6/23)
tz_16='selected=""'
;;
BRST3BRDT,M10.3.0/0,M2.5.0/0)
tz_17='selected=""'
;;
UTC3)
tz_18='selected=""'
;;
UTC2)
tz_19='selected=""'
;;
STD1DST,M3.5.0/2,M10.5.0/2)
tz_20='selected=""'
;;
UTC0)
tz_21='selected=""'
;;
GMT0BST,M3.5.0/2,M10.5.0/2)
tz_22='selected=""'
;;
UTC-1)
tz_23='selected=""'
;;
CET-1CEST,M3.5.0/2,M10.5.0/3)
tz_24='selected=""'
;;
UTC-2)
tz_25='selected=""'
;;
STD-2DST,M3.5.0/2,M10.5.0/2)
tz_26='selected=""'
;;
UTC-3)
tz_27='selected=""'
;;
EET-2EEST-3,M3.5.0/3,M10.5.0/4)
tz_28='selected=""'
;;
UTC-4)
tz_29='selected=""'
;;
UTC-5)
tz_30='selected=""'
;;
UTC-5:30)
tz_31='selected=""'
;;
UTC-6)
tz_32='selected=""'
;;
UTC-7)
tz_33='selected=""'
;;
UTC-8)
tz_34='selected=""'
;;
AWST-8)
tz_35='selected=""'
;;
UTC-8:45)
tz_36='selected=""'
;;
UTC-9)
tz_37='selected=""'
;;
ACST-9:30)
tz_38='selected=""'
;;
ACST-9:30ACDT,M10.1.0/2,M4.1.0/3)
tz_39='selected=""'
;;
AEST-10)
tz_40='selected=""'
;;
AEST-10AEDT-11,M10.1.0/2,M4.1.0/3)
tz_41='selected=""'
;;
UTC-10)
tz_42='selected=""'
;;
UTC-11)
tz_43='selected=""'
;;
UTC-12)
tz_44='selected=""'
;;
NZST-12NZDT,M9.5.0/2,M4.1.0/3)
tz_45='selected=""'
;;
esac
%>
                                    <select name="zonename" class="form-control">
<option value="UTC12" <%= ${tz_1} %>>UTC-12:00 <%= ${_LANG_Form_tz_1} %></option>
<option value="UTC11" <%= ${tz_2} %>>UTC-11:00 <%= ${_LANG_Form_tz_2} %></option>
<option value="UTC10" <%= ${tz_3} %>>UTC-10:00 <%= ${_LANG_Form_tz_3} %></option>
<option value="NAST9NADT,M3.2.0/2,M11.1.0/2" <%= ${tz_4} %>>UTC-09:00 <%= ${_LANG_Form_tz_4} %></option>
<option value="PST8PDT,M3.2.0/2,M11.1.0/2" <%= ${tz_5} %>>UTC-08:00 <%= ${_LANG_Form_tz_5} %></option>
<option value="UTC7" <%= ${tz_6} %>>UTC-07:00 <%= ${_LANG_Form_tz_6} %></option>
<option value="MST7MDT,M3.2.0/2,M11.1.0/2" <%= ${tz_7} %>>UTC-07:00 <%= ${_LANG_Form_tz_7} %></option>
<option value="UTC6" <%= ${tz_8} %>>UTC-06:00 <%= ${_LANG_Form_tz_8} %></option>
<option value="CST6CDT,M3.2.0/2,M11.1.0/2" <%= ${tz_9} %>>UTC-06:00 <%= ${_LANG_Form_tz_9} %></option>
<option value="UTC5" <%= ${tz_10} %>>UTC-05:00 <%= ${_LANG_Form_tz_10} %></option>
<option value="EST5EDT,M3.2.0/2,M11.1.0/2" <%= ${tz_11} %>>UTC-05:00 <%= ${_LANG_Form_tz_11} %></option>
<option value="UTC4" <%= ${tz_12} %>>UTC-04:00 <%= ${_LANG_Form_tz_12} %></option>
<option value="AST4ADT,M3.2.0/2,M11.1.0/2" <%= ${tz_13} %>>UTC-04:00 <%= ${_LANG_Form_tz_13} %></option>
<option value="BRWST4BRWDT,M10.3.0/0,M2.5.0/0" <%= ${tz_14} %>>UTC-04:00 <%= ${_LANG_Form_tz_14} %></option>
<option value="NST3:30NDT,M3.2.0/0:01,M11.1.0/0:01" <%= ${tz_15} %>>UTC-03:30 <%= ${_LANG_Form_tz_15} %></option>
<option value="WGST3WGDT,M3.5.6/22,M10.5.6/23" <%= ${tz_16} %>>UTC-03:00 <%= ${_LANG_Form_tz_16} %></option>
<option value="BRST3BRDT,M10.3.0/0,M2.5.0/0" <%= ${tz_17} %>>UTC-03:00 <%= ${_LANG_Form_tz_17} %></option>
<option value="UTC3" <%= ${tz_18} %>>UTC-03:00 <%= ${_LANG_Form_tz_18} %></option>
<option value="UTC2" <%= ${tz_19} %>>UTC-02:00 <%= ${_LANG_Form_tz_19} %></option>
<option value="STD1DST,M3.5.0/2,M10.5.0/2" <%= ${tz_20} %>>UTC-01:00 <%= ${_LANG_Form_tz_20} %></option>
<option value="UTC0" <%= ${tz_21} %>>UTC+00:00 <%= ${_LANG_Form_tz_21} %></option>
<option value="GMT0BST,M3.5.0/2,M10.5.0/2" <%= ${tz_22} %>>UTC+00:00 <%= ${_LANG_Form_tz_22} %></option>
<option value="UTC-1" <%= ${tz_23} %>>UTC+01:00 <%= ${_LANG_Form_tz_23} %></option>
<option value="CET-1CEST,M3.5.0/2,M10.5.0/3" <%= ${tz_24} %>>UTC+01:00 <%= ${_LANG_Form_tz_24} %></option>
<option value="UTC-2" <%= ${tz_25} %>>UTC+02:00 <%= ${_LANG_Form_tz_25} %></option>
<option value="STD-2DST,M3.5.0/2,M10.5.0/2" <%= ${tz_26} %>>UTC+02:00 <%= ${_LANG_Form_tz_26} %></option>
<option value="UTC-3" <%= ${tz_27} %>>UTC+03:00 <%= ${_LANG_Form_tz_27} %></option>
<option value="EET-2EEST-3,M3.5.0/3,M10.5.0/4" <%= ${tz_28} %>>UTC+03:00 <%= ${_LANG_Form_tz_28} %></option>
<option value="UTC-4" <%= ${tz_29} %>>UTC+04:00 <%= ${_LANG_Form_tz_29} %></option>
<option value="UTC-5" <%= ${tz_30} %>>UTC+05:00 <%= ${_LANG_Form_tz_30} %></option>
<option value="UTC-5:30" <%= ${tz_31} %>>UTC+05:30 <%= ${_LANG_Form_tz_31} %></option>
<option value="UTC-6" <%= ${tz_32} %>>UTC+06:00 <%= ${_LANG_Form_tz_32} %></option>
<option value="UTC-7" <%= ${tz_33} %>>UTC+07:00 <%= ${_LANG_Form_tz_33} %></option>
<option value="UTC-8" <%= ${tz_34} %>>UTC+08:00 <%= ${_LANG_Form_tz_34} %></option>
<option value="AWST-8" <%= ${tz_35} %>>UTC+08:00 <%= ${_LANG_Form_tz_35} %></option>
<option value="UTC-8:45" <%= ${tz_36} %>>UTC+08:45 <%= ${_LANG_Form_tz_36} %></option>
<option value="UTC-9" <%= ${tz_37} %>>UTC+09:00 <%= ${_LANG_Form_tz_37} %></option>
<option value="ACST-9:30" <%= ${tz_38} %>>UTC+09:30 <%= ${_LANG_Form_tz_38} %></option>
<option value="ACST-9:30ACDT,M10.1.0/2,M4.1.0/3" <%= ${tz_39} %>>UTC+09:30 <%= ${_LANG_Form_tz_39} %></option>
<option value="AEST-10" <%= ${tz_40} %>>UTC+10:00 <%= ${_LANG_Form_tz_40} %></option>
<option value="AEST-10AEDT-11,M10.1.0/2,M4.1.0/3" <%= ${tz_41} %>>UTC+10:00 <%= ${_LANG_Form_tz_41} %></option>
<option value="UTC-10" <%= ${tz_42} %>>UTC+10:00 <%= ${_LANG_Form_tz_42} %></option>
<option value="UTC-11" <%= ${tz_43} %>>UTC+11:00 <%= ${_LANG_Form_tz_43} %></option>
<option value="UTC-12" <%= ${tz_44} %>>UTC+12:00 <%= ${_LANG_Form_tz_44} %></option>
<option value="NZST-12NZDT,M9.5.0/2,M4.1.0/3" <%= ${tz_45} %>>UTC+12:00 <%= ${_LANG_Form_tz_45} %></option>
                                    </select>
                                </div>
                            </div>
                            <div class="form-group">
                                <label for="" class="col-sm-5 control-label"><%= ${_LANG_Form_NTP_Time_server} %></label>
                                <div class="col-sm-7">
<%
num=1
for server in $(uci get system.ntp.server); do
eval ntp_server_${num}="${server}"
num=$(expr ${num} + 1)
done
for num in $(seq 1 5); do
%>
<div class="input-group">
    <input type="text" name="ntp_server_<%= ${num}%>" placeholder="Enter NTP TimeServer" value="<% eval echo '$'ntp_server_${num} %>" class="form-control timezone_host_input">
    <span class="help-block hidden"><%= ${_LANG_Form_Please_enter_a_valid_} ${_LANG_Form_domain} %></span>
</div>
<%
done
ntp_server_local=$(uci get system.ntp.enable_server)
%>
                                </div>
                            </div>
                            <div class="form-group">
                                <label for="" class="col-sm-5 control-label"><%= ${_LANG_Form_Local_NTP_Server} %></label>
                                <div class="col-sm-7">
                                    <select name="enable_server" class="form-control">
                                        <option value="0" <% [ ${ntp_server_local} -lt 1 ] && printf 'selected=""' %>>off</option>
                                        <option value="1" <% [ ${ntp_server_local} -gt 0 ] && printf 'selected=""' %>>on</option>
                                    </select>
                                </div>
                            </div>
							<div class="form-group">
								<label for="web_ctl_port" class="col-sm-5 control-label"><%= ${_LANG_Form_Web_control_panel_port} %></label>
								<div class="col-sm-7">
									<input type="number" min="1" max="65535" class="form-control" name="web_ctl_port" id="web_ctl_port" data-validate="vaPort-vaLength" value=<% grep '^server.port' /usr/shellgui/shellguilighttpd/etc/lighttpd/lighttpd.conf | grep -Eo '[0-9]*$' %>>
                                    <span class="help-block hidden"><%= ${_LANG_Form_Please_enter_a_valid_} ${_LANG_Form__Port} %></span>
								</div>
							</div>
                            <div class="form-group">
                                <div class="col-sm-offset-5 col-sm-7">
                                    <button type="submit" id="submit_timezone_btn" class="btn btn-default"><%= ${_LANG_Form_Save} %></button>
                                </div>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
<% /usr/shellgui/progs/main.sbin h_f
/usr/shellgui/progs/main.sbin h_end %>
<script src="/apps/sysinfo/sysinfo.js"></script>
</body>
</html>
