#ifndef __DEFINE_H__
#define __DEFINE_H__

#include <stdbool.h> 

#define BUFFER_SIZE 1024
#define LINE_SIZE 256


#pragma pack(1)
typedef struct {
	unsigned char router_mac[6];
	short message_type;
	int data_length;
}message_header_st;

typedef struct {
	unsigned char mac[6];                    //热点MAC地址             必填    由17位字符组成，所有的字符大写，每两个字符用半角“-”，类似00-E0-4C-3B-7D-2F
    char ap_ssid[64];                        //热点SSID                     热点的SSID
    char ap_channel[8];	                     //热点频道 字符型	2	    必填	   热点的工作频道
    char encrypt_algorithm_type[8];          //热点加密类型  字符型 2	必填
    char ap_field_strength[8];               //热点场强                必填    采集到的终端设备信号强度数据	
}ap_mac_st;
#pragma pack()

typedef struct {
	char mac_cmd[128];
	char ap_mac_cmd[128];
	char server_ip[64];
	unsigned char router_mac[6];
	unsigned short server_port;		
	int sleep_second;
	int heart_beat_second;
	int debug;	
}config_st;

#endif
