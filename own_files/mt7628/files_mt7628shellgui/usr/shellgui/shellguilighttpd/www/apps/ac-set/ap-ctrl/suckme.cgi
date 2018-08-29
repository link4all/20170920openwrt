#!/usr/bin/haserl
<%
mac=$(echo "${FORM_body}" | jshon -e "Mac" -u)
[ -z "${mac}" ] && exit
sed -i "/${mac}/d" /tmp/avable_ap.txt
echo "${FORM_body}" >> /tmp/avable_ap.txt
%>
