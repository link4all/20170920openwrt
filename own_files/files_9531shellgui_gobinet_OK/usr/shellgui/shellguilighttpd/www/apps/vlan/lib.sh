#!/bin/sh
get_vlan_info() {
eval $(swconfig dev $1 help 2>/dev/null | head -n 1 | tr ',' '\n' | sed -e 's/:[ ]/="/g' -e 's/$/"/g')
switch_dev_desc="${switch0}"
vlan_ports=$(echo "${ports}" | grep -Eo '^[0-9]*')
cpu_port=$(echo "${ports}" | grep -Eo '[0-9]*\)' | grep -Eo '[0-9]*')
support_vlans=${vlans}
}
main() {
shellgui '{"action":"check_session","session_type":"http-session","session":"'"$COOKIE_session"'"}' &>/dev/null
[ $? -ne 0 ] && printf "Location: /?app=login\r\n\r\n" && return 1
eval $(/usr/shellgui/progs/main.sbin l_p '_LANG_Form_' ${FORM_app} $COOKIE_lang)
if [ "${FORM_action}" = "set_vlan" ] &>/dev/null; then
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	cat <<EOF
{"status":0,"msg":"${_LANG_Form_Successfully_Modified}"}
EOF
	network_str=$(uci show -X network)
	config_str=$(env | grep -E '^FORM_data' | sed -e 's#^FORM_data\[##g' -e 's#\]\[#.#g' -e 's#]=#="#g' -e 's#$#"#g')
	vlan_devs=$(echo "$config_str" | cut -d '.' -f1 | sort -n | uniq)

	for vlan_dev in $vlan_devs; do
		echo "$network_str" | grep -E "\.device=.*${vlan_dev}" | cut -d '.' -f1-2 | while read cfg; do
			uci set ${cfg}=
		done
		vlans=$(echo "$config_str" | grep -E "^${vlan_dev}\." | cut -d '.' -f2 | sort -n | uniq)
		for vlan in ${vlans}; do
			eval $(echo "$config_str"  | grep -E "^${vlan_dev}\.${vlan}\.ports|^${vlan_dev}\.${vlan}\.vlan_id" | cut -d '.' -f3-)
			if [ -n "${ports}" ]; then
        uci batch <<EOF &>/dev/null
add network switch_vlan
set network.@switch_vlan[-1]=switch_vlan
set network.@switch_vlan[-1].device="${vlan_dev}"
set network.@switch_vlan[-1].vlan="${vlan_id}"
set network.@switch_vlan[-1].ports="${ports}"
EOF

			fi
		done
	done
	uci commit network
	return
elif [ "${FORM_action}" = "lan_port_status" ] &>/dev/null; then
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"

board=$(cat /tmp/sysinfo/board_name)
case "$board" in
gl-inet)
	PORTS="1";;
routerstation-pro)
	PORTS="4 3 2";;
tl-mr3220 | \
tl-mr3420 | \
tl-wr1043nd | \
tl-wr741nd | \
tl-wr841n-v7)
	PORTS="1 2 3 4";;
tl-mr3220-v2 | \
tl-mr3420-v2 | \
tl-wr741nd-v4 | \
tl-wr841n-v8)
	PORTS="2 3 4 1";;
archer-c5 | \
archer-c7 | \
tl-wdr4300)
	PORTS="2 3 4 5";;
dir-835-a1 | \
tl-wdr3500 | \
tl-wr841n-v9 | \
tl-wr1043nd-v2 | \
wndr4300)
        PORTS="4 3 2 1";;
armada-xp-linksys-mamba | \
wndr3700 | \
wrt160nl | \
wzr-hp-g300nh)
	PORTS="3 2 1 0";;
mpr-a2)
	PORTS="0";;
rut5xx)
	PORTS="3 2 1";;
px4885 | \
wt3020)
	PORTS="4";;
*)
	PORTS="";;
esac
RESULT="{}"
counter=0
for P in $PORTS; do
	counter=$((counter + 1))
	[ "$P" = "-1" ] && continue
	[ -n "$VLAN" ] && {
		PVID=$(swconfig dev ${FORM_switch:-switch0} port $P get pvid)
		[ "$PVID" != "$VLAN" ] && continue
	}
	LINK=$(swconfig dev ${FORM_switch:-switch0} port $P get link | cut -f2,3 -d" ")
	case "$LINK" in
		"link:down") STATUS="-";;
		"link:up speed:1000baseT") STATUS="1Gbps";;
		"link:up speed:100baseT") STATUS="100Mbps";;
		"link:up speed:10baseT") STATUS="10Mbps";;
		"1000") STATUS="1Gbps";;
		"100") STATUS="100Mbps";;
		"10") STATUS="10Mbps";;
		"0") STATUS="-";;
		"1") STATUS="conn";;
		*) STATUS="?";;
	esac
	case "$counter" in
		1) PORT="LAN1";;
		2) PORT="LAN2";;
		3) PORT="LAN3";;
		4) PORT="LAN4";;
	esac
	RESULT=$(echo "$RESULT" | jshon -n {} -i "${PORT}" -e "${PORT}" \
	-n ${counter} -i "Port" \
	-s "${PORT}" -i "Lan" \
	-s "${STATUS}" -i "Status" -p -j \
	)
done
echo "$RESULT"
	return
elif [ "${FORM_action}" = "port_status" ] &>/dev/null; then
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
printf '{'
swconfig dev ${FORM_switch:-switch0} show | awk 'BEGIN{ORS=""} 
/port:/ { split($2, tmp, ":" );
	port=tmp[2];
split($3, tmp, ":" );
	link=tmp[2];
	printf("\"%s\":{", port);
	printf("\"link\":\"%s\"", link);
	}; 
/speed:/ {
split($4, tmp, ":" );
	speed=tmp[2];
	printf(",\"speed\":\"%s\"", speed);
};
/-duplex/ {
split($5, tmp, "-" );
	duplex=tmp[1];
	printf(",\"duplex\":\"%s\"", duplex);
};
/port:/ { printf("},") };

' | sed 's/,$//'
echo '}'
	return
fi
}
