#!/bin/sh

[ -n "$INCLUDE_ONLY" ] || {
	NOT_INCLUDED=1
	INCLUDE_ONLY=1

	. ../netifd-proto.sh
	. ./ppp.sh
	init_proto "$@"
}

proto_3g_init_config() {
	no_device=1
	available=1
	ppp_generic_init_config
	proto_config_add_string "device:device"
	proto_config_add_string "apn"
	proto_config_add_string "service"
	proto_config_add_string "pincode"
	proto_config_add_string "dialnumber"
}

init_4g(){
device_at=`uci get 4g.modem.device`
#4g info dump：
a=$(gcom -d ${device_at} -s /etc/gcom/getstrength.gcom  |grep  "," |cut -d: -f2|cut -d, -f1)
rssi_percent=$(printf "%d%%\n" $((a*100/31)))
sim_status=$(gcom -d ${device_at} -s /etc/gcom/getsimstatus.gcom )
model=$(gcom -d ${device_at} -s /etc/gcom/getcardinfo.gcom |head -n3|tail -n1|tr -d '\r')
rev=$(gcom -d ${device_at} -s /etc/gcom/getcardinfo.gcom |grep -i rev |cut -d: -f2-|tr -d '\r')
imei=$(gcom -d ${device_at} -s /etc/gcom/getimei.gcom)
imsi=$(gcom -d ${device_at} -s /etc/gcom/getimsi.gcom)
iccid=$(gcom -d ${device_at} -s /etc/gcom/iccid_forge.gcom|cut -d: -f2)
roam=$(gcom -d ${device_at} -s /etc/gcom/checkregister.gcom )
lac=$(gcom -d ${device_at} -s /etc/gcom/getlaccellid.gcom )
reg_net=$(gcom -d ${device_at} -s /etc/gcom/getregisterednetwork.gcom |cut -d: -f2- )

uci set 4g.modem.device="${device_at}"
uci set 4g.modem.rssi="$rssi_percent"
uci set 4g.modem.sim_status="$sim_status"
uci set 4g.modem.model="$model"
uci set 4g.modem.rev="$rev"
uci set 4g.modem.imei="$imei"
uci set 4g.modem.imsi="$imsi"
uci set 4g.modem.iccid="$iccid"
uci set 4g.modem.roam="$roam"
uci set 4g.modem.lac="$lac"
uci set 4g.modem.reg_net="$reg_net"
uci commit 4g
}

proto_3g_setup() {

#init_4g
  
	local interface="$1"
	local chat

	json_get_var device device
	json_get_var apn apn
	json_get_var service service
	json_get_var pincode pincode
	json_get_var dialnumber dialnumber

	[ -n "$dat_device" ] && device=$dat_device
	[ -e "$device" ] || {
		proto_set_available "$interface" 0
		return 1
	}

	case "$service" in
		cdma|evdo)
			chat="/etc/chatscripts/evdo.chat"
		;;
		*)
			chat="/etc/chatscripts/3g.chat"
			cardinfo=$(gcom -d "$device" -s /etc/gcom/getcardinfo.gcom)
			if echo "$cardinfo" | grep -q Novatel; then
				case "$service" in
					umts_only) CODE=2;;
					gprs_only) CODE=1;;
					*) CODE=0;;
				esac
				export MODE="AT\$NWRAT=${CODE},2"
			elif echo "$cardinfo" | grep -q Option; then
				case "$service" in
					umts_only) CODE=1;;
					gprs_only) CODE=0;;
					*) CODE=3;;
				esac
				export MODE="AT_OPSYS=${CODE}"
			elif echo "$cardinfo" | grep -q "Sierra Wireless"; then
				SIERRA=1
			elif echo "$cardinfo" | grep -qi huawei; then
				case "$service" in
					umts_only) CODE="14,2";;
					gprs_only) CODE="13,1";;
					*) CODE="2,2";;
				esac
				export MODE="AT^SYSCFG=${CODE},3FFFFFFF,2,4"
			fi

			if [ -n "$pincode" ]; then
				PINCODE="$pincode" gcom -d "$device" -s /etc/gcom/setpin.gcom || {
					proto_notify_error "$interface" PIN_FAILED
					proto_block_restart "$interface"
					return 1
				}
			fi
			[ -n "$MODE" ] && gcom -d "$device" -s /etc/gcom/setmode.gcom

			# wait for carrier to avoid firmware stability bugs
			[ -n "$SIERRA" ] && {
				gcom -d "$device" -s /etc/gcom/getcarrier.gcom || return 1
			}

			if [ -z "$dialnumber" ]; then
				dialnumber="*99***1#"
			fi

		;;
	esac

	connect="${apn:+USE_APN=$apn }DIALNUMBER=$dialnumber /usr/sbin/chat -t5 -v -E -f $chat"
	ppp_generic_setup "$interface" \
		noaccomp \
		nopcomp \
		novj \
		nobsdcomp \
		noauth \
		lock \
		crtscts \
		115200 "$device"
	return 0
}

proto_3g_teardown() {
	proto_kill_command "$interface"
}

[ -z "NOT_INCLUDED" ] || add_protocol 3g

