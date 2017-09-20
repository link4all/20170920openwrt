#!/bin/sh
main() {
shellgui '{"action":"check_session","session_type":"http-session","session":"'"$COOKIE_session"'"}' &>/dev/null
[ $? -ne 0 ] && printf "Location: /?app=login\r\n\r\n" && return 1
eval $(/usr/shellgui/progs/main.sbin l_p '_LANG_Form_' ${FORM_app} $COOKIE_lang)
if [ "${FORM_action}" = "post_text_file" ] &>/dev/null; then
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	echo "$FORM_data" > $FORM_file
	cat <<EOF
{"status":0,"msg":"${_LANG_Form_File_has_success_modified}."}
EOF
	return
elif [ "${FORM_action}" = "test_file" ] &>/dev/null; then
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	if file $FORM_file | grep -q 'text'; then
	cat <<EOF
{"status":0}
EOF
	else
	cat <<EOF
{"status":1,"msg":"${_LANG_Form_File_can_not_be_modify}."}
EOF
	fi
	return
elif [ "${FORM_action}" = "get_text_file" ] &>/dev/null; then
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	cat $FORM_file
	return
elif [ "${FORM_action}" = "del_file" ] &>/dev/null; then
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	rm -rf $FORM_file
	if [ -e $FORM_file ]; then
	cat <<EOF
{"status":1,"msg":"${_LANG_Form_File_can_not_be_del__unknow_error}!"}
EOF
	else
	cat <<EOF
{"status":0,"msg":"${_LANG_Form_File_has_been_deleted}: $FORM_file"}
EOF
	fi
	return
elif [ "${FORM_action}" = "post_privilege" ] &>/dev/null; then
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	(u_str=$(echo "${FORM_data}" | cut -c1-3 )
	g_str=$(echo "${FORM_data}" | cut -c4-6 )
	o_str=$(echo "${FORM_data}" | cut -c7-9 )
	chmod -R u=${u_str/-/},g=${g_str/-/},o=${o_str/-/} $FORM_file) &>/dev/null
	cat <<EOF
{"status":0,"msg":"${_LANG_Form_Permissions_modified_to}: $FORM_data"}
EOF
	return
elif [ "${FORM_action}" = "get_line" ] &>/dev/null; then
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
script='BEGIN{FS=""}
{
	if ($1=="d") {
	printf("<pre class=\"shell-pre\">%s</pre></td><td><span class=\"file-icons icon-folder fb-dir\"></span>  <a class=\"fb-dir\" \n", $0);
	}
	else if ($1=="s" || $1=="c" || $1=="b") {
	printf("<pre class=\"shell-pre\">%s</pre></td><td><span class=\"file-icons icon-wrench fb-desc\"></span><a class=\"fb-desc\" \n", $0);
	}
	else if ($1=="l") {
	printf("<pre class=\"shell-pre\">%s</pre></td><td><span class=\"file-icons icon-link fb-link\"></span>  <a class=\"fb-link\" \n", $0);
	}
	else {
		if ($10=="x") {
			printf("<pre class=\"shell-pre\">%s</pre></td><td><span class=\"file-icons icon-set fb-exec\"></span>  <a class=\"fb-exec\" \n", $0);
		}
		else {
			printf("<pre class=\"shell-pre\">%s</pre></td><td><span class=\"file-icons icon-file fb-file\"></span>  <a class=\"fb-file\" \n", $0);
		}
	}
}'

str=$(ls -lah "${FORM_path:-/}")
echo "$str" | cut -c56- | awk '{printf "data-value=\""$0"\">"$0"</a>\n"}'> /tmp/filebrowser.tmpp
echo "$str" | cut -c-55 | awk "$script" > /tmp/filebrowser.tmp
awk 'NR==FNR{a[FNR]=$0;next}{print "<tr><td>"a[FNR] $0"</td></tr>"}' /tmp/filebrowser.tmp /tmp/filebrowser.tmpp
	return
fi
}
