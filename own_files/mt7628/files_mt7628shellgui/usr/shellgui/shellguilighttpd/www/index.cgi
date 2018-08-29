#!/usr/bin/haserl
<?
[ -z "$COOKIE_lang" ] && export COOKIE_lang=zh-cn
if [ "$REQUEST_METHOD" = "GET" ]; then
	[ -z "${GET_app}" ] && export GET_app=home
	eval $(/usr/shellgui/progs/main.sbin l_p '_LANG_Form_' home $COOKIE_lang)
	haserl /usr/shellgui/shellguilighttpd/www/apps/${GET_app}/main.sh
elif [ "$REQUEST_METHOD" = "POST" ]; then
	[ -z "${POST_app}" ] && export POST_app=login
	eval $(/usr/shellgui/progs/main.sbin l_p '_LANG_Form_' home $COOKIE_lang)
	. /usr/shellgui/shellguilighttpd/www/apps/${POST_app}/lib.sh && main
fi
?>
