#!/bin/sh
main() {
# shellgui '{"action": "check_session", "session_type": "http-session", "session": "'"$COOKIE_session"'"}' &>/dev/null
# [ $? -ne 0 ] && printf "Location: /?app=login\r\n\r\n" && return 1
if [ "${FORM_action}" = "post_privilege" ] &>/dev/null; then
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	# chmod $(echo "${data}" | cut -c ) $FORM_file
	
	echo $FORM_data
	# cat <<EOF
# {"status":0,"msg":"权限已修改为: $FORM_data"}
# EOF
	return
elif [ "${FORM_action}" = "get_text_file" ] &>/dev/null; then
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	cat $FORM_file
	return
elif [ "${FORM_action}" = "get_line" ] &>/dev/null; then
# curl -d "app=filebrowser&action=get_line&path=/" -L "http://10.10.11.254"
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
script='BEGIN{FS=""}
{
	if ($1=="d") {
	printf("<pre class=\"shell-pre\">%s</pre></td><td><span class=\"glyphicon glyphicon-folder-open fb-dir\"></span>  <a class=\"fb-dir\" \n", $0);
	# 文件夹
	}
	else if ($1=="s" || $1=="c" || $1=="b") {
	printf("<pre class=\"shell-pre\">%s</pre></td><td><span class=\"glyphicon glyphicon-wrench fb-desc\"></span><a class=\"fb-desc\" \n", $0);
	# socks-like 描述型文件
	}
	else if ($1=="l") {
	printf("<pre class=\"shell-pre\">%s</pre></td><td><span class=\"glyphicon glyphicon-link fb-link\"></span>  <a class=\"fb-link\" \n", $0);
	# link 软链接文件
	}
	else {
		if ($10=="x") {
			printf("<pre class=\"shell-pre\">%s</pre></td><td><span class=\"glyphicon glyphicon-cog fb-exec\"></span>  <a class=\"fb-exec\" \n", $0);
			# 可执行文件
		}
		else {
			printf("<pre class=\"shell-pre\">%s</pre></td><td><span class=\"glyphicon glyphicon-file fb-file\"></span>  <a class=\"fb-file\" \n", $0);
			# 普通文件
		}
	}
}'

# 编辑这里 变更目录
str=$(ls -lahp "${FORM_path:-/}")
echo "$str" | cut -c56- | awk '{printf "data-value=\""$0"\">"$0"</a>\n"}'> /tmp/filebrowser.tmpp
# echo "$str" | cut -c58- | awk '{printf "value=\""$0"\"</a>"$0"\n"}'> /tmp/filebrowser.tmpp
echo "$str" | cut -c-55 | awk "$script" > /tmp/filebrowser.tmp
awk 'NR==FNR{a[FNR]=$0;next}{print "<tr><td>"a[FNR] $0"</td></tr>"}' /tmp/filebrowser.tmp /tmp/filebrowser.tmpp

	return
fi
}
