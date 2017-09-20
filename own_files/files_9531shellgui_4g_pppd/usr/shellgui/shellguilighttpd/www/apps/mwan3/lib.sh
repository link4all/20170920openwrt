#!/bin/sh
main() {
shellgui '{"action":"check_session","session_type":"http-session","session":"'"$COOKIE_session"'"}' &>/dev/null
[ $? -ne 0 ] && printf "Location: /?app=login\r\n\r\n" && return 1
if [ "${FORM_action}" = "enable_mwan3" ] &>/dev/null; then
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	if [ ${FORM_enabled:-0} -gt 0 ]; then
	uci set mwan3.default.enabled=1
	cat <<EOF
{"status":0,"msg":"enable mwan3 成功!"}
EOF
	else
	uci set mwan3.default.enabled=0
	cat <<EOF
{"status":0,"msg":"disable mwan3 成功!"}
EOF
	fi
	uci commit mwan3
	return
elif [ "${FORM_action}" = "enable_wan" ] &>/dev/null; then
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	if [ ${FORM_enabled:-0} -gt 0 ]; then
	uci set mwan3.${FORM_wan}.enabled=1
	cat <<EOF
{"status":0,"msg":"enable wan 成功!"}
EOF
	else
	uci set mwan3.${FORM_wan}.enabled=0
	cat <<EOF
{"status":0,"msg":"disable wan 成功!"}
EOF
	fi
	uci commit mwan3
	return
elif [ "${FORM_action}" = "edit_wan_metric" ] &>/dev/null; then
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	uci set network.$FORM_wan.metric=$FORM_metric
	uci commit network
	cat <<EOF
{"status":0,"msg":"edit_wan_metric wan 成功!"}
EOF
	return
elif [ "${FORM_action}" = "do_edit_wan" ] &>/dev/null; then
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	old_enabled=$(uci get mwan3.$FORM_wan.enabled)
	uci batch <<EOF
set mwan3.$FORM_wan=
set mwan3.$FORM_wan=interface
set mwan3.$FORM_wan.count="$FORM_count"
set mwan3.$FORM_wan.timeout="$FORM_timeout"
set mwan3.$FORM_wan.interval="$FORM_interval"
set mwan3.$FORM_wan.reliability="$FORM_reliability"
set mwan3.$FORM_wan.down="$FORM_down"
set mwan3.$FORM_wan.up="$FORM_up"
EOF
for ip in $(echo "$FORM_track_ip" | tr ',' ' '); do
uci add_list mwan3.$FORM_wan.track_ip="${ip}"
done
uci set mwan3.$FORM_wan.enabled=$old_enabled
	uci commit mwan3
	cat <<EOF
{"status":0,"msg":"do_edit_wan wan 成功!"}
EOF
	return
elif [ "${FORM_action}" = "do_edit_member" ] &>/dev/null; then
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	uci batch <<EOF
set mwan3.$FORM_member=
set mwan3.$FORM_member=member
set mwan3.$FORM_member.interface="$FORM_wan"
set mwan3.$FORM_member.metric="$FORM_metric"
set mwan3.$FORM_member.weight="$FORM_weight"
EOF
	uci commit mwan3
	cat <<EOF
{"status":0,"msg":"do_edit_member wan 成功!"}
EOF
	return
elif [ "${FORM_action}" = "do_edit_policy" ] &>/dev/null; then
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
uci set mwan3.$FORM_policy=
uci set mwan3.$FORM_policy=policy
for member in $(env | grep -E '^FORM_member_.*=1' | cut -d '=' -f1 | sed 's#^FORM_member_##g'); do
	uci add_list mwan3.$FORM_policy.use_member="${member}"
done
	uci set mwan3.$FORM_policy.last_resort="${FORM_last_resort}"
	uci commit mwan3
	cat <<EOF
{"status":0,"msg":"do_edit_policy wan 成功!"}
EOF
	return
elif [ "${FORM_action}" = "do_edit_rule" ] &>/dev/null; then
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	uci batch <<EOF
set mwan3.$FORM_rule=
set mwan3.$FORM_rule=rule
set mwan3.$FORM_rule.src_ip="$FORM_src_ip"
set mwan3.$FORM_rule.src_port="$FORM_src_port"
set mwan3.$FORM_rule.dest_ip="$FORM_dest_ip"
set mwan3.$FORM_rule.dest_port="$FORM_dest_port"
set mwan3.$FORM_rule.proto="$FORM_proto"
set mwan3.$FORM_rule.sticky="$FORM_sticky"
set mwan3.$FORM_rule.timeout="$FORM_timeout"
set mwan3.$FORM_rule.ipset="$FORM_ipset"
set mwan3.$FORM_rule.use_policy="$FORM_use_policy"
EOF

	uci commit mwan3
	cat <<EOF
{"status":0,"msg":"do_edit_rule wan 成功!"}
EOF
	return
elif [ "${FORM_action}" = "rm_wan" ] &>/dev/null; then
	mwan3_str=$(uci show -X mwan3)
	members=$(echo "$mwan3_str" | grep '=member' | cut -d '=' -f1 | cut -d '.' -f2)
	policys=$(echo "$mwan3_str" | grep '=policy' | cut -d '=' -f1 | cut -d '.' -f2)
	rules=$(echo "$mwan3_str" | grep '=rule' | cut -d '=' -f1 | cut -d '.' -f2)
	uci set mwan3.$FORM_wan=
	for member in $members; do
		eval $(echo "$mwan3_str" | grep -E "mwan3\.${member}\.interface=" | cut -d '.' -f3-)
		if [ "$interface" = "$FORM_wan" ]; then
			uci set mwan3.${member}=
			for policy in $policys; do
				eval $(echo "$mwan3_str" | grep -E "mwan3\.${policy}\.use_member=" | cut -d '.' -f3- | sed "s#' '# #g")
				if echo "$use_member" | grep -q ' '; then
					for a_use_member in $use_member; do
						if [ "${a_use_member}" = "${member}" ]; then
							uci del_list mwan3.${policy}.use_member="${a_use_member}"
						fi
					done
				else
					uci set mwan3.${policy}=
				fi
				for rule in $rules; do
					eval $(echo "$mwan3_str" | grep -E "mwan3\.${rule}\.use_policy=" | cut -d '.' -f3-)
					if [ "${use_policy}" = "${policy}" ]; then
						uci set mwan3.${rule}=
					fi
				done
			done
		fi
	done
	uci commit mwan3
	cat <<EOF
{"status":0,"msg":"rm_wan $wan_config 成功!"}
EOF
	return
elif [ "${FORM_action}" = "rm_member" ] &>/dev/null; then
	mwan3_str=$(uci show -X mwan3)
	policys=$(echo "$mwan3_str" | grep '=policy' | cut -d '=' -f1 | cut -d '.' -f2)
	rules=$(echo "$mwan3_str" | grep '=rule' | cut -d '=' -f1 | cut -d '.' -f2)
	member=$FORM_member
	uci set mwan3.${member}=
	for policy in $policys; do
		eval $(echo "$mwan3_str" | grep -E "mwan3\.${policy}\.use_member=" | cut -d '.' -f3- | sed "s#' '# #g")
		if echo "$use_member" | grep -q ' '; then
			for a_use_member in $use_member; do
				if [ "${a_use_member}" = "${member}" ]; then
					uci del_list mwan3.${policy}.use_member="${a_use_member}"
				fi
			done
		else
			uci set mwan3.${policy}=
		fi
		for rule in $rules; do
			eval $(echo "$mwan3_str" | grep -E "mwan3\.${rule}\.use_policy=" | cut -d '.' -f3-)
			if [ "${use_policy}" = "${policy}" ]; then
				uci set mwan3.${rule}=
			fi
		done
	done
	uci commit mwan3
	cat <<EOF
{"status":0,"msg":"rm_member wan 成功!"}
EOF
	return
elif [ "${FORM_action}" = "rm_policy" ] &>/dev/null; then
	mwan3_str=$(uci show -X mwan3)
	rules=$(echo "$mwan3_str" | grep '=rule' | cut -d '=' -f1 | cut -d '.' -f2)
	policy=$FORM_policy
	uci set mwan3.${policy}=
	for rule in $rules; do
		eval $(echo "$mwan3_str" | grep -E "mwan3\.${rule}\.use_policy=" | cut -d '.' -f3-)
		if [ "${use_policy}" = "${policy}" ]; then
			uci set mwan3.${rule}=
		fi
	done
	uci commit mwan3
	cat <<EOF
{"status":0,"msg":"rm_policy wan 成功!"}
EOF
	return
elif [ "${FORM_action}" = "rm_rule" ] &>/dev/null; then
	uci set mwan3.${FORM_rule}=
	uci commit mwan3
	cat <<EOF
{"status":0,"msg":"rm_rule wan 成功!"}
EOF
	return
fi
}

todo() {
uci -p /var/state get network.wan.metric

uci -p /var/state get mwan3.wan.track_ip | wc -w

uci -p /var/state get network.wan == interface


				# local protocol = ut.trim(sys.exec("uci -p /var/state get mwan3." .. section[".name"] .. ".proto"))

				
}
