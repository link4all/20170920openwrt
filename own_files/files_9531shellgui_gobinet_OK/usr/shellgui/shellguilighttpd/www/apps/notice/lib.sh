#!/bin/sh
MAIN_SBIN='/usr/shellgui/progs/main.sbin'
main() {
shellgui '{"action":"check_session","session_type":"http-session","session":"'"$COOKIE_session"'"}' &>/dev/null
[ $? -ne 0 ] && printf "Location: /?app=login\r\n\r\n" && return 1
eval $(/usr/shellgui/progs/main.sbin l_p '_LANG_Form_' ${FORM_app} $COOKIE_lang)
if [ "${FORM_action}" = "notice_count" ] &>/dev/null; then
	result=$(shellgui '{"action":"notice_count","per_page_records":'$FORM_per_page_records'}')

	if [ -z "$result" ]; then
		printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
		cat <<EOF
{"status":0,"pages":0,"per_page_records":0}
EOF
	return
	else
		printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
		echo "$result"
		return
	fi
elif [ "${FORM_action}" = "notice_get_page" ] &>/dev/null; then
	result=$(shellgui '{"action":"notice_get_page","per_page_records":'$FORM_per_page_records',"page":'$FORM_page'}')
	if [ -z "$result" ]; then
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	cat <<EOF
{"result":[]}
EOF
	return
	else
	eval $(/usr/shellgui/progs/main.sbin l_p_n $COOKIE_lang)
	for num in $(seq 0 $(expr $(echo "$result" | jshon -e "result" -l) - 1)); do
		desc=$(echo "$result" | jshon -e "result" -e ${num} -e "Desc" -u)
		echo "$desc" | grep -q ' ' || desc=$(eval echo '$'$desc)
		
		variable=$(echo "$result" | jshon -e "result" -e ${num} -e "Variable")
		if [ "$variable" != "null" ]; then
		eval $(echo "$variable" | grep "\:" | sed 's#\,$##g' | awk '{split($1,key,"\":" ); printf substr(key[1],2); printf "="; for (i=2 ;i<=NF;i++) printf $i " "; printf "\n"}')
		desc=$(eval echo $(echo "${desc}" | sed 's#{#${#g'))
		fi
		result=$(echo "$result" | jshon -e "result" -e ${num} \
		-s "${desc}" -i "Desc" \
		-d "Detail" -d "Variable" \
		-p -p -j)
	done
		printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
		echo "$result"
		return
	fi
elif [ "${FORM_action}" = "notice_get_a_notice" ] &>/dev/null; then
	result=$(shellgui '{"action":"notice_get_a_notice","id":'$FORM_ids'}')
	eval $(/usr/shellgui/progs/main.sbin l_p_n $COOKIE_lang)

		desc=$(echo "$result" | jshon -e "result" -e 0 -e "Desc" -u)
		echo "$desc" | grep -q ' ' || desc=$(eval echo '$'$desc)
		detail=$(echo "$result" | jshon -e "result" -e 0 -e "Detail" -u)
		echo "$detail" | grep -q ' ' || detail=$(eval echo '$'$detail)
		
		variable=$(echo "$result" | jshon -e "result" -e 0 -e "Variable")
		if [ "$variable" != "null" ]; then
		eval $(echo "$variable" | grep "\:" | sed 's#\,$##g' | awk '{split($1,key,"\":" ); printf substr(key[1],2); printf "="; for (i=2 ;i<=NF;i++) printf $i " "; printf "\n"}')
		desc=$(eval echo $(echo "${desc}" | sed 's#{#${#g'))
		detail=$(eval echo $(echo "${detail}" | sed -e 's#[\]##g' -e 's#{#${#g' -e 's#<#\\<#g' -e 's#>#\\>#g'))
		fi

		printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	cat <<EOF
{"Desc":"${desc}","Detail":"${detail}"}
EOF
		return
elif [ "${FORM_action}" = "doemail_main_setting" ] &>/dev/null; then
printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
for key in SMTP_AUTH_PASS USE_TLS SMTP_PORT MY_NAME TIMEOUT SMTP_AUTH_USER subject sig SMTP_AUTH SMTP_SERVER MY_EMAIL
do
var=$(eval echo '$FORM_'"${key}")
if [ -z "$var" ]; then
	cat <<EOF
{"status":1,"msg":"$key ${_LANG_Form_can_not_be_empty}"}
EOF
return
fi
done

for key in $(grep -v "#" /usr/shellgui/shellguilighttpd/www/apps/notice/email/email.conf | sed -e '/^SIGNATURE_FILE/d' -e 's#[ ]*= [ ]*#=#g' | cut -d '=' -f1); do
sed -i "/${key}/d" /usr/shellgui/shellguilighttpd/www/apps/notice/email/email.conf
done

echo "SMTP_AUTH_PASS = '${FORM_SMTP_AUTH_PASS}'" >>/usr/shellgui/shellguilighttpd/www/apps/notice/email/email.conf
echo "SMTP_PORT = '${FORM_SMTP_PORT}'" >>/usr/shellgui/shellguilighttpd/www/apps/notice/email/email.conf
echo "USE_TLS = '${FORM_USE_TLS}'" >>/usr/shellgui/shellguilighttpd/www/apps/notice/email/email.conf
echo "MY_NAME = '${FORM_MY_NAME}'" >>/usr/shellgui/shellguilighttpd/www/apps/notice/email/email.conf
echo "SMTP_AUTH_USER = '${FORM_SMTP_AUTH_USER}'" >>/usr/shellgui/shellguilighttpd/www/apps/notice/email/email.conf
echo "SMTP_AUTH = '${FORM_SMTP_AUTH}'" >>/usr/shellgui/shellguilighttpd/www/apps/notice/email/email.conf
echo "SMTP_SERVER = '${FORM_SMTP_SERVER}'" >>/usr/shellgui/shellguilighttpd/www/apps/notice/email/email.conf
echo "MY_EMAIL = '${FORM_MY_EMAIL}'" >>/usr/shellgui/shellguilighttpd/www/apps/notice/email/email.conf

echo "$FORM_sig" | tr -s "\n" > /usr/shellgui/shellguilighttpd/www/apps/notice/email/email.sig

sed -i -e '/^\-x /d' -e '/^\-s /d' /usr/shellgui/shellguilighttpd/www/apps/notice/email/email_extra.conf

echo "-x ${FORM_TIMEOUT}" >>/usr/shellgui/shellguilighttpd/www/apps/notice/email/email_extra.conf
echo "-s ${FORM_subject}" >>/usr/shellgui/shellguilighttpd/www/apps/notice/email/email_extra.conf
shellgui '{"action":"notice_unmark_uniqueid","Uniqueid":"Email_need_set"}' &>/dev/null

	cat <<EOF
{"status":0,"msg":"${_LANG_Form_Modify_success}!"}
EOF
	return
elif [ "${FORM_action}" = "email_extra_setting" ] &>/dev/null; then
sed -i -e '/^\-\-cc /d' -e '/^\-\-bcc /d' /usr/shellgui/shellguilighttpd/www/apps/notice/email/email_extra.conf
for cc in $(echo "$FORM_CC" | tr ';' ' '); do
echo "--cc ${cc}" >>/usr/shellgui/shellguilighttpd/www/apps/notice/email/email_extra.conf
done
for bcc in $(echo "$FORM_BCC" | tr ';' ' '); do
echo "--bcc ${bcc}" >>/usr/shellgui/shellguilighttpd/www/apps/notice/email/email_extra.conf
done
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	cat <<EOF
{"status":0,"msg":"${_LANG_Form_Modify_success}!"}
EOF
	return
elif [ "${FORM_action}" = "email_test" ] &>/dev/null; then
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
[ -n "${FORM_Addressee}" ] && echo "${FORM_Addressee}" | ${MAIN_SBIN} regex_str isemail
	if [ $? -ne 0 ]; then
	cat <<EOF
{"status":1,"msg":"${_LANG_Form_Miss_E_Mail_Addressee}"}
EOF
	return
	fi
	if [ -z "${FORM_email_test_content}" ]; then
	cat <<EOF
{"status":1,"msg":"${_LANG_Form_Email_content} ${_LANG_Form_Content_can_not_empty}"}
EOF
	return
	fi
echo "${FORM_email_test_content}" | email \
$(grep -vE '^#|--[b]cc ' /usr/shellgui/shellguilighttpd/www/apps/notice/email/email_extra.conf | tr '\n' ' ') \
"${FORM_Addressee}"

	cat <<EOF
{"status":0,"msg":"${_LANG_Form_Test_Mail_sented_to} $FORM_Addressee"}
EOF
	return
fi
}