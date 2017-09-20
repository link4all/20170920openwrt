#!/bin/sh
MAIN_SBIN="/usr/shellgui/progs/main.sbin"
do_editgroup() {
printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
if [ -z "$FORM_group" ]; then
	cat <<EOF
{"status":1,"msg":"${_LANG_Form_Group} ${_LANG_Form_Can_not_be_empty}!"}
EOF
	return 1
fi
old_group_str=`cat /etc/group | grep "^$FORM_oldgroup:"`
old_group_gid=`echo "$old_group_str" | awk -F ":" {'print $3'}`
if cat /etc/passwd | awk -F ":" {'print $1'} | grep -v "^$FORM_oldgroup$" | grep -q "^$FORM_group$"; then
	cat <<EOF
{"status":1,"msg":"${_LANG_Form_Group} ${_LANG_Form_already_exists}!"}
EOF
	return 1
fi
if [ "$FORM_oldgroup" != "$FORM_group" ]; then
	echo "$FORM_group" | ${MAIN_SBIN} regex_str islang_enalb
	if [ $? -ne 0 ]; then
		cat <<EOF
{"status":1,"msg":"${_LANG_Form_Group} ${_LANG_Form_must_be_in_Eng_or_Eng_with_number}!"}
EOF
		return 1
	fi
	if [ $(expr length "$FORM_group") -gt 16 ]; then
		cat <<EOF
{"status":1,"msg":"${_LANG_Form_Group} ${_LANG_Form_must_be_shorter_than_16_characters}!"}
EOF
		return 1
	fi
groupmod -n $FORM_group $FORM_group >/dev/null 2>&1
	if [ $? -ne 0 ]; then
		cat <<EOF
{"status":1,"msg":"${_LANG_Form_An_unknown_error_happens}!"}
EOF
		return 1
	fi
fi
if [ -n "$FORM_gid" ]; then
	echo "$FORM_gid" | ${MAIN_SBIN} regex_str islang_alb
	if [ $? -ne 0 ]; then
		cat <<EOF
{"status":1,"msg":"gid ${_LANG_Form_must_be_number}!"}
EOF
		return 1
	fi
	if [ $FORM_gid -gt 65535 ]; then
		cat <<EOF
{"status":1,"msg":"uid ${_LANG_Form_can_not_beyond} 65535!"}
EOF
		return 1
	fi
groupmod -g $FORM_gid $FORM_group >/dev/null 2>&1
	if [ $? -ne 0 ]; then
		cat <<EOF
{"status":1,"msg":"gid ${_LANG_Form_An_unknown_error_happens}!"}
EOF
		return 1
	fi
fi
	if [ "$FORM_password" != "$FORM_password_cf" ]; then
		cat <<EOF
{"status":1,"msg":"${_LANG_Form_Enter_the_password_confirm_inconsistent}!"}
EOF
		return 1
	fi
	cat <<EOF
{"status":0,"msg":"${_LANG_Form_Successful}!"}
EOF
	return 0
}
do_addgroup() {
printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
args=""
if [ -z "$FORM_group" ]; then
	cat <<EOF
{"status":1,"msg":"${_LANG_Form_Group} ${_LANG_Form_can_not_be_empty}!"}
EOF
	return 1
fi
if [ -n "$FORM_gid" ]; then
	echo "$FORM_gid" | ${MAIN_SBIN} regex_str islang_alb
	if [ $? -ne 0 ]; then
		cat <<EOF
{"status":1,"msg":"gid ${_LANG_Form_must_be_number}!"}
EOF
		return 1
	fi
	
	if [ $FORM_gid -gt 65535 ]; then
		cat <<EOF
{"status":1,"msg":"gid ${_LANG_Form_can_not_beyond} 65535!"}
EOF
		return 1
	fi
args="$args -g $FORM_gid"
fi
groupadd $FORM_group $args >/dev/null 2>&1
if [ $? -eq 0 ]; then
	cat <<EOF
{"status":0,"msg":"${_LANG_Form_Successful}!"}
EOF
	return 0
else
	cat <<EOF
{"status":1,"msg":"${_LANG_Form_An_unknown_error_happens}!"}
EOF
	return 1
fi
}
do_adduser() {
printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
args=""
if [ -n "$FORM_uid" ]; then
	echo "$FORM_uid" | ${MAIN_SBIN} regex_str islang_alb
	if [ $? -ne 0 ]; then
	cat <<EOF
{"status":1,"msg":"uid ${_LANG_Form_must_be_number}!"}
EOF
	return 1
	fi
	if [ $FORM_uid -ge 65535 ]; then
	cat <<EOF
{"status":1,"msg":"uid ${_LANG_Form_can_not_beyond} 65535!"}
EOF
	return 1
	fi
	args="$args -u $FORM_uid"
fi
if [ -n "$FORM_username" ]; then
	echo "$FORM_username" | ${MAIN_SBIN} regex_str islang_enalb
	if [ $? -ne 0 ]; then
	cat <<EOF
{"status":1,"msg":"${_LANG_Form_Username} ${_LANG_Form_must_be_in_Eng_or_Eng_with_number}!"}
EOF
	return 1
	fi
	if [ $(expr length $(echo "$FORM_username")) -gt 16 ]; then
	cat <<EOF
{"status":1,"msg":"${_LANG_Form_Username} ${_LANG_Form_must_be_shorter_than_16_characters}!"}
EOF
	return 1
	fi
	args="$args $FORM_username"
else
	cat <<EOF
{"status":1,"msg":"${_LANG_Form_Username} ${_LANG_Form_Can_not_be_empty}!"}
EOF
	return 1
fi
if cat /etc/passwd | awk -F ":" {'print $1'} | grep -q "^$FORM_username$";then
	cat <<EOF
{"status":1,"msg":"${_LANG_Form_Username} ${_LANG_Form_already_exists}!"}
EOF
	return 1
fi
if [ -n "$FORM_password" ]; then
	if [ $(expr length $(echo "$FORM_password")) -lt 6 ]; then
	cat <<EOF
{"status":1,"msg":"${_LANG_Form_Password} ${_LANG_Form_must_be_longer_than_6_characters}!"}
EOF
	return 1
	fi
fi
if [ -n "$FORM_group" ]; then
	args="$args -g $FORM_group"
fi
if [ -n "$FORM_gecos" ]; then
	if echo "$FORM_gecos" | grep -q ":"; then
		cat <<EOF
{"status":1,"msg":"gecos ${_LANG_Form_can_not_include} :!"}
EOF
		return 1
	fi
	args="$args -c $FORM_gecos"
fi
if [ -n "$FORM_home_dir" ]; then
	echo "$FORM_home_dir" | grep -q "^/"
	if [ $? -ne 0 ]; then
	cat <<EOF
{"status":1,"msg":"${_LANG_Form_home_must_use_root_for_beginning}!"}
EOF
	return 1
	fi
	if echo "$FORM_home_dir" | grep -q " "; then
		cat <<EOF
{"status":1,"msg":"${_LANG_Form_Path_can_not_with_spaces}!"}
EOF
		return 1
	fi
	echo "$FORM_home_dir" | ${MAIN_SBIN} regex_str ispath
	if [ $? -ne 0 ]; then
		cat <<EOF
{"status":1,"msg":"${_LANG_Form_Home_dir} ${_LANG_Form_must_be_a_path}!"}
EOF
		return 1
	fi
	args="$args -d $FORM_home_dir"
else
	args="$args -d / -M"
fi
if [ -n "$FORM_shell" ]; then
	if [ "$FORM_shell" != "/bin/nologin" ] && [ "$FORM_shell" != "/bin/false" ]; then
		if [ ! -x "$FORM_shell" ]; then
			cat <<EOF
{"status":1,"msg":"${_LANG_Form_Wrong_shell_submit}!"}
EOF
			return 1
		fi
	fi
	args="$args -s $FORM_shell"
else
	args="$args -s /bin/nologin"
fi
SUCCESS_add=0
result=$(useradd $args 2>&1 | tr '\n' '.')
[ $? -eq 0 ] && SUCCESS_add=$(expr $SUCCESS_add + 1)
if [ -n "$FORM_password" ]; then
	passwd $FORM_username <<EOF &>/dev/null
$FORM_password
$FORM_password
EOF
fi
[ $? -eq 0 ] && SUCCESS_add=`expr $SUCCESS_add + 1`
if [ $SUCCESS_add -eq 2 ]; then
	cat <<EOF
{"status":0,"msg":"${_LANG_Form_Successful}!"}
EOF
	return 0
else
	cat <<EOF
{"status":1,"msg": "$result!"}
EOF
	return 1
fi
}
get_user_detail() {
printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
result_str=$(shellgui '{"action":"get_user_detail","username":"'"$FORM_user"'"}')
gid=$(echo "$result_str" | jshon -e "user_detail" -e "gid")
echo "$result_str" | jshon -e "user_detail" -s "$(grep ":${gid}:$" /etc/group | cut -d ':' -f1)" -i "group" -p -j
}
do_deluserpass() {
printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
if [ -z "$FORM_username" ];then
	cat <<EOF
{"status":0,"msg":"${_LANG_Form_Username} ${_LANG_Form_Can_not_be_empty}!"}
EOF
return
fi
if [ "$FORM_username" = "root" ];then
	cat <<EOF
{"status":0,"msg":"${_LANG_Form_Can_not_del_root_password}!"}
EOF
return
fi
passwd -d $FORM_username >/dev/null 2>&1
if [ $? -eq 0 ]; then
	cat <<EOF
{"status":0,"msg":"${_LANG_Form_Successfully_remove_the_password}!"}
EOF
return
else
	cat <<EOF
{"status":0,"msg":"${_LANG_Form_Fails_remove_the_password}!"}
EOF
return
fi
}
do_useredit() {
if [ -z "$FORM_username" ]; then
	cat <<EOF
{"status":1,"msg":"${_LANG_Form_Username} ${_LANG_Form_can_not_be_empty}!"}
EOF
return 1
fi
cat /etc/passwd | awk -F ":" {'print $1'} | grep -v "^FORM_oldusername$" | grep -q "^$FORM_username$"
if [ $? -ne 0 ]; then
	cat <<EOF
{"status":1,"msg":"${_LANG_Form_Username} ${_LANG_Form_already_exists}!"}
EOF
	return 1
fi
if [ "$FORM_username" != "$FORM_oldusername" ]; then
	echo "$FORM_username" | ${MAIN_SBIN} regex_str islang_enalb
	if [ $? -ne 0 ]; then
		cat <<EOF
{"status":1,"msg":"${_LANG_Form_Username} ${_LANG_Form_must_be_in_Eng_or_Eng_with_number}!"}
EOF
		return 1
	fi
	if [ $(expr length "$FORM_username") -gt 16 ]; then
		cat <<EOF
{"status":1,"msg":"${_LANG_Form_Username} ${_LANG_Form_must_be_shorter_than_16_characters}!"}
EOF
		return 1
	fi
usermod -l $FORM_username $FORM_username >/dev/null 2>&1
	if [ $? -ne 0 ]; then
		cat <<EOF
{"status":1,"msg":"${_LANG_Form_An_unknown_error_happens}!"}
EOF
		return 1
	fi
fi
if [ -n "$FORM_uid" ]; then
	echo "$FORM_uid" | ${MAIN_SBIN} regex_str islang_alb
	if [ $? -ne 0 ]; then
		cat <<EOF
{"status":1,"msg":"uid ${_LANG_Form_must_be_number}!"}
EOF
		return 1
	fi
	if [ $FORM_uid -gt 65535 ]; then
		cat <<EOF
{"status":1,"msg":"uid ${_LANG_Form_can_not_beyond} 65535!"}
EOF
		return 1
	fi
usermod -u $FORM_uid $FORM_username >/dev/null 2>&1
	if [ $? -ne 0 ]; then
		cat <<EOF
{"status":1,"msg":"${_LANG_Form_An_unknown_error_happens}!"}
EOF
		return 1
	fi
fi
if [ -n "$FORM_password" ]; then
	if [ $(expr length "$FORM_password") -lt 6 ]; then
		cat <<EOF
{"status":1,"msg":"${_LANG_Form_Password} ${_LANG_Form_must_be_longer_than_6_characters}!"}
EOF
		return 1
	fi
passwd $FORM_username <<EOF >/dev/null 2>&1
$FORM_password
$FORM_password
EOF
	if [ $? -ne 0 ]; then
		cat <<EOF
{"status":1,"msg":"Passwd ${_LANG_Form_An_unknown_error_happens}!"}
EOF
		return 1
	fi
fi
if [ -n "$FORM_gecos" ]; then
	if echo "$FORM_gecos" | grep -q ":"; then
		cat <<EOF
{"status":1,"msg":"GECOS ${_LANG_Form_can_not_include}:!"}
EOF
		return 1
	fi
usermod -c $FORM_gecos $FORM_username >/dev/null 2>&1
	if [ $? -ne 0 ]; then
		cat <<EOF
{"status":1,"msg":"GECOS ${_LANG_Form_An_unknown_error_happens} :!"}
EOF
		return 1
	fi
fi
if [ -n "$FORM_home_dir" ]; then
	echo "$FORM_home_dir" | grep -q "^/"
	if [ $? -ne 0 ]; then
		cat <<EOF
{"status":1,"msg":"${_LANG_Form_home_must_use_root_for_beginning}!"}
EOF
		return 1
	fi
	if echo "$FORM_home_dir" | grep -q " "; then
		cat <<EOF
{"status":1,"msg":"${_LANG_Form_can_not_include} ${_LANG_Form_blank}!"}
EOF
		return 1
	fi
	echo "$FORM_home_dir" | ${MAIN_SBIN} regex_str ispath
	if [ $? -ne 0 ]; then
		cat <<EOF
{"status":1,"msg":"${_LANG_Form_must_be_a_path}!"}
EOF
		return 1
	fi
usermod -d $FORM_home_dir $FORM_username >/dev/null 2>&1
	if [ $? -ne 0 ]; then
		cat <<EOF
{"status":1,"msg":"home ${_LANG_Form_An_unknown_error_happens}!"}
EOF
		return 1
	fi
else
usermod -d / -M $FORM_username >/dev/null 2>&1
	if [ $? -ne 0 ]; then
		cat <<EOF
{"status":1,"msg":"home ${_LANG_Form_An_unknown_error_happens}!"}
EOF
		return 1
	fi
fi
if [ -n "$FORM_shell" ]; then
	if [ "$FORM_shell" != "/bin/nologin" ] && [ "$FORM_shell" != "/bin/false" ]; then
		if [ ! -x "$FORM_shell" ]; then
			cat <<EOF
{"status":1,"msg":"shell ${_LANG_Form_An_unknown_error_happens}!"}
EOF
			return 1
		fi
	fi
	usermod -s $FORM_shell $FORM_username >/dev/null 2>&1
	if [ $? -ne 0 ]; then
		cat <<EOF
{"status":1,"msg":"shell ${_LANG_Form_An_unknown_error_happens}!"}
EOF
		return 1
	fi
else
usermod -s /bin/nologin $FORM_username >/dev/null 2>&1
	if [ $? -ne 0 ]; then
		cat <<EOF
{"status":1,"msg":"shell ${_LANG_Form_An_unknown_error_happens}!"}
EOF
		return 1
	fi
fi
if [ -n "$FORM_group" ]; then
usermod -g $FORM_group $FORM_username >/dev/null 2>&1
	if [ $? -ne 0 ]; then
		cat <<EOF
{"status":1,"msg":"group ${_LANG_Form_An_unknown_error_happens}!"}
EOF
		return 1
	fi
fi
	cat <<EOF
{"status":0,"msg":"${_LANG_Form_Successful}!"}
EOF
return 0
}
do_deluser() {
printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
grep -q "^$FORM_username:" /etc/passwd
if [ $? -ne 0 ]; then
	cat <<EOF
{"status":1,"msg":"${_LANG_Form_Username_does_not_exist}!"}
EOF
return 1
fi
if [ "$FORM_home_n_files" = "1" ]; then
	result=$(userdel -rf $FORM_username | tr '\n' '.' 2>&1)
else
	result=$(userdel $FORM_username | tr '\n' '.' 2>&1)
fi
if [ $? -eq 0 ]; then
	cat <<EOF
{"status":0,"msg": "${_LANG_Form_Del_success}!"}
EOF
	return 0
else
	cat <<EOF
{"status":1,"msg":"${_LANG_Form_Del_fail}!"}
EOF
	return 1
fi
}
do_groupedit() {
if [ -z "$FORM_groupname" ]; then
	cat <<EOF
{"status":1,"msg":"${_LANG_Form_Group} ${_LANG_Form_Can_not_be_empty}!"}
EOF
	return 1
fi
if cat /etc/passwd | awk -F ":" {'print $1'} | grep -v "^$FORM_oldgroup$" | grep -q "^$FORM_groupname$"; then
	cat <<EOF
{"status":1,"msg":"${_LANG_Form_Group} ${_LANG_Form_already_exists}!"}
EOF
	return 1
fi
if [ "$FORM_oldgroup" != "$FORM_groupname" ]; then
	echo "$FORM_groupname" | ${MAIN_SBIN} regex_str islang_enalb
	if [ $? -ne 0 ]; then
		cat <<EOF
{"status":1,"msg":"${_LANG_Form_Group} ${_LANG_Form_must_be_in_Eng_or_Eng_with_number}!"}
EOF
		return 1
	fi
	if [ $(expr length "$FORM_groupname") -gt 16 ]; then
		cat <<EOF
{"status":1,"msg":"${_LANG_Form_Group} ${_LANG_Form_must_be_shorter_than_16_characters}!"}
EOF
		return 1
	fi
groupmod -n $FORM_groupname $FORM_oldgroup >/dev/null 2>&1
	if [ $? -ne 0 ]; then
		cat <<EOF
{"status":1,"msg":"${_LANG_Form_An_unknown_error_happens}!"}
EOF
		return 1
	fi
fi
if [ -n "$FORM_gid" ]; then
	echo "$FORM_gid" | ${MAIN_SBIN} regex_str islang_alb
	if [ $? -ne 0 ]; then
		cat <<EOF
{"status":1,"msg":"gid ${_LANG_Form_must_be_number}!"}
EOF
		return 1
	fi
	if [ $FORM_gid -gt 65535 ]; then
		cat <<EOF
{"status":1,"msg":"uid ${_LANG_Form_can_not_beyond} 65535!"}
EOF
		return 1
	fi
groupmod -g $FORM_gid $FORM_groupname >/dev/null 2>&1
	if [ $? -eq 0 ]; then
		cat <<EOF
{"status":1,"msg":"gid ${_LANG_Form_An_unknown_error_happens}!"}
EOF
		return 1
	fi
fi
new_group_str=`cat /etc/group | grep "^$FORM_groupname:"`
new_group_shadow=`cat /etc/gshadow | grep "^$FORM_groupname:"`
new_group_gid=`echo "$new_group_str" | awk -F ":" {'print $3'}`
new_group_passwd_encypt=`echo "$new_group_shadow" | awk -F ":" {'print $2'}`
	cat <<EOF
{"status":1,"msg":"${_LANG_Form_Successful}!"}
EOF
	return 0
}
do_delgroup() {
printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
grep -q "^$FORM_group:" /etc/group
if [ $? -ne 0 ]; then
	cat <<EOF
{"status":0,"msg":"${_LANG_Form_Group} ${_LANG_Form_no_exists}!"}
EOF
return
fi
result=`groupdel $FORM_group | tr '\n' '.' 2>&1`
if [ $? -eq 0 ]; then
	cat <<EOF
{"status":0,"msg":"${_LANG_Form_Successful}!"}
EOF
return
else
	cat <<EOF
{"status":1,"msg": "$result!"}
EOF
return
fi
}
main() {
shellgui '{"action":"check_session","session_type":"http-session","session":"'"$COOKIE_session"'"}' &>/dev/null
[ $? -ne 0 ] && printf "Location: /?app=login\r\n\r\n" && return 1
eval $(/usr/shellgui/progs/main.sbin l_p '_LANG_Form_' ${FORM_app} $COOKIE_lang)
case $FORM_action in
do_deluserpass)
do_deluserpass
;;
do_useredit)
do_useredit
;;
do_adduser)
do_adduser
;;
do_deluser)
do_deluser
;;
do_delgroup)
do_delgroup
;;
do_addgroup)
do_addgroup
;;
do_editgroup)
do_editgroup
;;
get_user_detail)
get_user_detail
;;
esac
}
