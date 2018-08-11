#!/usr/bin/haserl  --upload-limit=16348 --upload-dir=/tmp/
<%
eval $( gargoyle_session_validator -c "$COOKIE_hash" -e "$COOKIE_exp" -a "$HTTP_USER_AGENT" -i "$REMOTE_ADDR" -r "/login1.asp" -t $(uci get gargoyle.global.session_timeout) -b "$COOKIE_browser_time"  )
echo "Content-Type: application/json"
echo ""

if [ "$FORM_setclient" = "1" ];then
  if [ "$FORM_enable_client" = "1" ];then
    uci set openvpn.sample_client.enabled='1'
    uci set openvpn.sample_client.remote="$FORM_client_remote"
    uci set openvpn.sample_client.proto="$FORM_proto"
    uci set openvpn.sample_client.comp_lzo="$FORM_comp_lzo"
    if [ -n "$FORM_client_ca"  ];then
    mv $FORM_client_ca /lib/uci/upload/cbid.openvpn.sample_client.ca >/dev/null 2>&1
    fi
    if [ -n "$FORM_client_cert"  ];then
    mv $FORM_client_cert /lib/uci/upload/cbid.openvpn.sample_client.cert >/dev/null 2>&1
    fi
    if [ -n "$FORM_client_key"  ];then
    mv $FORM_client_key /lib/uci/upload/cbid.openvpn.sample_client.key >/dev/null 2>&1
    fi
  else
    uci set openvpn.sample_client.enabled='0'
  fi

fi

if [ "$FORM_setserver" = "1" ];then
  if [ "$FORM_enable_server" = "1" ];then
    uci set openvpn.sample_server.enabled='1'
    uci set openvpn.sample_server.server="$FORM_ip_server"
    uci set openvpn.sample_server.port="$FORM_port"
    uci set openvpn.sample_server.proto="$FORM_proto"
    uci set openvpn.sample_server.comp_lzo="$FORM_comp_lzo"
  else
    uci set openvpn.sample_server.enabled='0'
  fi
fi


echo "{"
echo "\"stat\":\"ok\""
echo "}"
uci commit openvpn
/etc/init.d/openvpn restart 2>&1 >/dev/null


%>
