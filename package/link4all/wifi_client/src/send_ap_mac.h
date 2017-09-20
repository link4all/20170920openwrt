#ifndef __SEND_AP_MAC_H__
#define __SEND_AP_MAC_H__
#include "define.h"
#include "config.h"
void send_ap_mac_threading(void *ptr);

typedef struct {
	bool hasMAC;
	bool hasSignal;
	bool hasSSID;
	bool hasChannel;
	bool hasRSN;
	bool hasWPA;
	bool hasHT;	
}parse_field_st;

enum enum_ap_parse_status{
	AP_STATUS_BEGIN,
	AP_STATUS_MAC,
	AP_STATUS_FIELD_STRENGTH,
	AP_STATUS_SSID,
	AP_STATUS_CHANNEL,
	AP_STATUS_ENCRYPTION_TYPE,
	AP_STATUS_END,
	AP_STATUS_FINISH
};
#endif

/*
BSS c8:3a:35:5c:be:60(on wlan0)
signal: -24.00 dBm
SSID: HCWA test
DS Parameter set: channel 11
RSN ---> WAP2
HT capabilities:
HT operation:
WMM:	 * Parameter version 1
		 * BE: CW 15-1023, AIFSN 3
		 * BK: CW 15-1023, AIFSN 7
		 * VI: CW 7-15, AIFSN 2, TXOP 3008 usec
		 * VO: CW 3-7, AIFSN 2, TXOP 1504 usec

*/