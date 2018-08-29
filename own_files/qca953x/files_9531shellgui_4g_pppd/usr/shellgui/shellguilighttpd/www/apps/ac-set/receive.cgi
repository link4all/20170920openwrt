#!/usr/bin/haserl --upload-limit=16192 --upload-dir=/tmp/
<%
if cat /tmp/ap.session | grep -q "$HTTP_USER_AGENT"; then
echo "$POST_body" > /tmp/ap_receive.txt
fi
%>

