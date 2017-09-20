#!/usr/bin/haserl

<%
local_server '{"api":"auth","stage":"'$FORM_stage'","gw_id":"'$FORM_gw_id'","ip":"'$FORM_ip'","mac":"'$FORM_mac'","token":"'$FORM_token'","incoming":"'$FORM_incoming'","outgoing":"'$FORM_outgoing'"}' 2> /tmp/local_server.log
%>
