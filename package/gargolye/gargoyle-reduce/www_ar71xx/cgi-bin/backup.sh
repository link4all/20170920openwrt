#!/usr/bin/haserl --upload-limit=16348 --upload-dir=/tmp/
<%
eval $( gargoyle_session_validator -c "$COOKIE_hash" -e "$COOKIE_exp" -a "$HTTP_USER_AGENT" -i "$REMOTE_ADDR" -r "/login1.asp" -t $(uci get gargoyle.global.session_timeout) -b "$COOKIE_browser_time"  )
echo "Content-Type: application/json"
echo ""

if [ "$FORM_backup" -eq 1 ];then
backup_locations='/etc/passwd /etc/shadow /etc/config /etc/rc.d /etc/TZ /etc/firewall.user /etc/ethers /etc/hosts /etc/webmon_ips /etc/crontabs /etc/dropbear /etc/samba/smbpasswd /tmp/data /usr/data '
existing_locations=""
for bl in $backup_locations ; do
	if [ -e "$bl" ] ; then
		existing_locations="$existing_locations $bl"
	fi
done
mkdir -p /tmp/backup  2>&1
rm -rf /tmp/backup/*  2>&1
cd /tmp/backup
tar cvzf backup.tar.gz $existing_locations >/dev/null 2>&1
echo "{"
echo "\"stat\":\"ok\""
echo "}"
fi


if [ "$FORM_restorefactory" -eq 1 ];then
firstboot -y && reboot >/dev/null 2>&1
echo "{"
echo "\"stat\":\"ok\""
echo "}"
fi

if [ -n "$FORM_backfiles"  ];then
mkdir -p /tmp/backup >/dev/null 2>&1
mv $FORM_backfiles /tmp/backup/backup.tar.gz >/dev/null 2>&1
tar xzvf /tmp/backup/backup.tar.gz -C / >/dev/null 2>&1
rm -rf rm -rf /tmp/backup/*  >/dev/null 2>&1
reboot  >/dev/null 2>&1
echo "{"
echo "\"stat\":\"ok\""
echo "}"
fi

%>
