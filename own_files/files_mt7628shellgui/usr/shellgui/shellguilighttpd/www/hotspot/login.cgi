#!/usr/bin/haserl

<%
local_server '{"api":"login","gw_id":"'$FORM_gw_id'","gw_address":"'$FORM_gw_address'","gw_port":"'$FORM_gw_port'","ip":"'$FORM_ip'","mac":"'$FORM_mac'","url":"'$FORM_url'"}' 2>/tmp/local_server.log
%>
