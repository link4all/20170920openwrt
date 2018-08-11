#!/usr/bin/haserl
<%
eval $( gargoyle_session_validator -c "$COOKIE_hash" -e "$COOKIE_exp" -a "$HTTP_USER_AGENT" -i "$REMOTE_ADDR" -r "/login1.asp" -t $(uci get gargoyle.global.session_timeout) -b "$COOKIE_browser_time"  )
echo "Content-Type: application/json"
echo ""
iwlist $1 scanning | awk '
BEGIN {
  count = 0;
  BSSID = "N/A";
  CHANNEL = "N/A";
  SSID = "N/A";
  SIG = "N/A";
  ENC = "N/A";
  W2 = "N/A";
  W1 = "N/A";
  WPA = 0;
  WPA2 = 0;
  printf("{");
}
function record(bs, ch, s, sg, e, w2, w1){
  id = "";
  bssid = "";
  c = "";
  sig = "";
  sig_result = "";
  enc = "";
  type = "none";
  split(bs,a,": ");
  bssid = a[2];
  split(ch,cc,":");
  c = cc[2];
  split(s,a,":");
  id = a[2];
  split(sg,a,"level=");
  split(a[2],s," ");
  sig = s[1];

  if(sig <= -100) {
	sig_result = 0;
  } else if (sig >= -50) {
	sig_result = 100;
  } else {
	sig_result = 2 * (sig + 100);
  }

  split(e,a,":");
  enc = a[2];
  if (enc == "on"){
	type = "WEP";
	ccmp = 0;
	tkip = 0;
	psk2 = 0;
	psk1 = 0;
	split(w2,a,":");
	if(a[2]){
	  split(a[2], r, " ");
	  if(r[1] == "CCMP")
		ccmp = 1;
	  if(r[1] == "TKIP")
		tkip = 1;
	  if(r[2] == "CCMP")
		ccmp = 1;
	  if(r[2] == "TKIP")
		tkip = 1;
	  psk2 = a[2];
	}
	split(w1,a,":");
	if(a[2]){
	  split(a[2], r, " ");
	  if(r[1] == "CCMP")
		ccmp = 1;
	  if(r[1] == "TKIP")
		tkip = 1;
	  if(r[2] == "CCMP")
		ccmp = 1;
	  if(r[2] == "TKIP")
		tkip = 1;
	  psk1 = a[2];
	}
	if (psk1 != 0 && psk2 != 0){
	  type = "mixed-psk";
	  if(tkip)
		type =(type"+tkip");
	  if(ccmp)
		type =(type"+ccmp");
	}else if(psk1 == 0 && psk2 != 0){
	  type = "psk2";
	  if(tkip)
		type =(type"+tkip");
	  if(ccmp)
		type =(type"+ccmp");
	}else if(psk1 != 0 && psk2 == 0){
	  type = "psk";
	  if(tkip)
		type =(type"+tkip");
	  if(ccmp)
		type =(type"+ccmp");
	}
  }
  count++;
  if(count>1) print ","
  printf("%s:{\"sig\":%s,\"sig_p\":%s,\"enc\":\"%s\", \"channel\": %s, \"bssid\": \"%s\"}", id, sig, sig_result, type, c, tolower(bssid));
}
{
  match($0, /Cell ([0-9]+) - Address:/);
  if(RLENGTH != -1){
	if(SSID != "N/A"){
	  record(BSSID, CHANNEL, SSID, SIG, ENC, W2, W1);
	}
	CHANNEL = "N/A";
	SSID = "N/A";
	SIG = "N/A";
	ENC = "N/A";
	W2 = "N/A";
	W1 = "N/A";
	WPA = 0;
	WPA2 = 0;
  }
}
{
  match($0, /- Address: (.+)/);
  if(RLENGTH != -1)
	BSSID=$0;
}
{
  match($0, /Channel:(.+)/);
  if(RLENGTH != -1)
	CHANNEL=$0;
}
{
  match($0, /ESSID:"(.+)"/);
  if(RLENGTH != -1)
	SSID=$0;
}
{
  match($0, /Quality(.+)/);
  if(RLENGTH != -1)
	SIG=$0;
}
{
  match($0, /Encryption key:(.+)/);
  if(RLENGTH != -1)
	ENC=$0;
}
{
  match($0, /IE: IEEE 802.11i\/WPA2 Version 1/);
  if(RLENGTH != -1){
	WPA2=1;
  }
  match($0, /IE: WPA Version 1/);
  if(RLENGTH != -1){
	WPA=1;
  }
}
{
  match($0, /Pairwise Ciphers(.+)/);
  if(RLENGTH != -1){
	if(WPA2==1){
	  W2=$0;
	}
	if(WPA==1){
	  W1=$0;
	}
  }
}

{
  match($0, /Authentication Suites \(1\) : PSK/);
  if(RLENGTH != -1 && WPA2==1){
	WPA2=0;
  }
  if(RLENGTH != -1 && WPA==1){
	WPA=0;
  }
}
END{
  if(SSID != "N/A"){
	record(BSSID, CHANNEL, SSID, SIG, ENC, W2, W1);
  }
  printf("}");
}
'
%>
