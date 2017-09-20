#!/bin/sh
main() {
shellgui '{"action": "check_session", "session_type": "http-session", "session": "'"$COOKIE_session"'"}' &>/dev/null
[ $? -ne 0 ] && printf "Location: /?app=login\r\n\r\n" && return 1
eval $(/usr/shellgui/progs/main.sbin l_p '_LANG_Form_' ${FORM_app} $COOKIE_lang)
if [ "${FORM_action}" = "connlimits_setting" ] &>/dev/null; then
sed -i '/net.netfilter.nf_conntrack_max/d' /etc/sysctl.conf
sed -i '/net.netfilter.nf_conntrack_tcp_timeout_established/d' /etc/sysctl.conf
sed -i '/net.netfilter.nf_conntrack_udp_timeout_stream/d' /etc/sysctl.conf
sed -i '/fs.file-max/d' /etc/sysctl.conf
cat <<EOF >> /etc/sysctl.conf
net.netfilter.nf_conntrack_max=${FORM_max_connections}
net.netfilter.nf_conntrack_tcp_timeout_established=${FORM_tcp_timeout}
net.netfilter.nf_conntrack_udp_timeout_stream=${FORM_udp_timeout}
fs.file-max=${FORM_fs_file_max}
EOF
sysctl -p /etc/sysctl.conf &>/dev/null
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	cat <<EOF
{"status": 0, "msg": "${_LANG_Form_Modify_successful}!"}
EOF
	return
fi
}