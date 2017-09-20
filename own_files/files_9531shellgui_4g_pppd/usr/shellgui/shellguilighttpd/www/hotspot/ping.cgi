#!/usr/bin/haserl

<%
local_server '{"api":"ping","gw_id":"'$GET_gw_id'","sys_uptime":"'$GET_sys_uptime'","sys_memfree":"'$GET_sys_memfree'","sys_load":"'$GET_sys_load'","wifidog_uptime":"'$GET_wifidog_uptime'"}' 2>/tmp/local_server.log
%>
