#include <stdio.h>        
#include <stdlib.h>        
#include <string.h> 
#include "send_ap_mac.h"
#include "common_utils.h"
#include "string_utils.h"




void send_ap_mac_threading(void *ptr)
{
	config_st *config = (config_st *)ptr;
	int socket_fd = socket_connect_create(config);		
	while(1){
		if(send_ap_mac_from_pipe(config, socket_fd) != 0){
			socket_fd = socket_connect_create(config);
		}
		sleep(config->sleep_second);
	}	
    close(socket_fd);
}


/*
	热点加密类型
	01	WEP
	02	WPA
	03	WPA2
	04	PSK
	99	其他
*/
void set_encrypt_type(parse_field_st *parse_field_st_ptr, ap_mac_st *message_body)
{
	if(parse_field_st_ptr->hasRSN){
		sprintf(message_body->encrypt_algorithm_type, "%s", "03");
	}else if(parse_field_st_ptr->hasWPA){
		sprintf(message_body->encrypt_algorithm_type, "%s", "02");
	}else if(!parse_field_st_ptr->hasHT){
		sprintf(message_body->encrypt_algorithm_type, "%s", "01");
	}else{
		sprintf(message_body->encrypt_algorithm_type, "%s", "99");
	}
	return;
}

int send_ap_mac_from_pipe(const config_st *config, int sockfd) 
{ 	
	int send_size = 0;
    FILE *p = popen(config->ap_mac_cmd, "r"); 
    if(p == NULL){ 
        printf("popen error! ap_mac_cmd:%s\n", config->ap_mac_cmd); 
        return 0; 
    }
	
	int message_header_size = sizeof(message_header_st);
	int message_body_size = sizeof(ap_mac_st);
	int buffer_size = message_header_size + message_body_size;
	char buffer[buffer_size];
	memset(buffer, 0, buffer_size);
	
	message_header_st *message_header  = (message_header_st *)buffer;
	ap_mac_st *message_body = (ap_mac_st *)(buffer + message_header_size);
	memcpy(message_header->router_mac, config->router_mac, 6);
	message_header->message_type = 2;
	message_header->data_length = message_body_size;	
	enum enum_ap_parse_status parse_status = AP_STATUS_MAC;	
	parse_field_st parse_field_st_obj;	
	char line[LINE_SIZE];
	char *str_bss = "BSS ";
	
    while (fgets(line, LINE_SIZE, p) != NULL)  
    {  
        //printf("%s", line);
		if(startsWith(line, str_bss) && (parse_status == AP_STATUS_ENCRYPTION_TYPE)){
			set_encrypt_type(&parse_field_st_obj, message_body);
			/*
			printf("%02x:%02x:%02x:%02x:%02x:%02x %s %s %s %s\n", message_body->mac[0], message_body->mac[1], message_body->mac[2], message_body->mac[3], message_body->mac[4], message_body->mac[5],
			message_body->ap_channel, 
			message_body->ap_field_strength,
			message_body->encrypt_algorithm_type,			
			message_body->ap_ssid);
			*/
			int i=0;
			char *message_body_encrypted = (char *)message_body;
			for(i=0; i<message_body_size; i++){
				message_body_encrypted[i] = ~(message_body_encrypted[i]);
			}			
			send_size = send(sockfd, buffer, buffer_size, 0);
			if(send_size <= 0){
				printf("SOCKET_ERROR send_size:%d\n", send_size);
				pclose(p);                     
				close(sockfd);
				return -1;
			}

			memset(message_body, 0, message_body_size);
			memset(&parse_field_st_obj, 0, sizeof(parse_field_st));			
			parse_status = AP_STATUS_MAC;
		}
		switch (parse_status) {
        case AP_STATUS_MAC:{
			if(!startsWith(line, str_bss)){
				continue;
			}
			mac_str_to_char_array(line+strlen(str_bss), message_body->mac);
			//print_mac(message_body->mac);
			parse_field_st_obj.hasMAC = true;
			parse_status = AP_STATUS_FIELD_STRENGTH;
			break;
		}
        case AP_STATUS_FIELD_STRENGTH:{
			char *str = "signal: ";
			char *line_str = left_trim(line);
			if(!startsWith(line_str, str)){
				continue;
			}
			memcpy(message_body->ap_field_strength, line_str+strlen(str), 6);
			//printf("[%s]\n", message_body->ap_field_strength);
			parse_field_st_obj.hasSignal = true;
			parse_status = AP_STATUS_SSID;
            break;
		}
        case AP_STATUS_SSID:{
			char *str = "SSID: ";
			char *line_str = left_trim(line);
			if(!startsWith(line_str, str)){
				continue;
			}
			char *ssid_str = line_str+strlen(str);
			int ssid_length = strlen(ssid_str);
			memcpy(message_body->ap_ssid, ssid_str, ssid_length);
			message_body->ap_ssid[ssid_length-1] = '\0';
			//printf("[%s][%d]\n", message_body->ap_ssid, ssid_length);
			parse_field_st_obj.hasSSID = true;
			parse_status = AP_STATUS_CHANNEL;
            break;
		}
        case AP_STATUS_CHANNEL:{
			char *str = "DS Parameter set: channel ";
			char *line_str = left_trim(line);
			if(!startsWith(line_str, str)){
				continue;
			}
			char *channel_str = line_str+strlen(str);
			int channel_length = strlen(channel_str);
			memcpy(message_body->ap_channel, channel_str, channel_length);
			message_body->ap_channel[channel_length-1] = '\0';	
			//printf("[%s][%d]\n", message_body->ap_channel, channel_length);
			parse_field_st_obj.hasChannel = true;
			parse_status = AP_STATUS_ENCRYPTION_TYPE;			
            break;        
		}
		case AP_STATUS_ENCRYPTION_TYPE:{
			char *line_str = left_trim(line);			
			if(startsWith(line_str, "RSN:")){
				parse_field_st_obj.hasRSN = true;
				continue;
			}
			if(startsWith(line_str, "HT ")){
				parse_field_st_obj.hasHT = true;
				continue;
			}
			if(startsWith(line_str, "WPA:")){
				parse_field_st_obj.hasWPA = true;
				continue;		
			}			
            break;
		}
        default:
            break;
        }

    }
	
	if(parse_status == AP_STATUS_ENCRYPTION_TYPE){
		set_encrypt_type(&parse_field_st_obj, message_body);
		/*
		printf("--> %02x:%02x:%02x:%02x:%02x:%02x %s %s %s %s\n", message_body->mac[0], message_body->mac[1], message_body->mac[2], message_body->mac[3], message_body->mac[4], message_body->mac[5],
		message_body->ap_channel, 
		message_body->ap_field_strength,
		message_body->encrypt_algorithm_type,			
		message_body->ap_ssid);
		*/
		int i=0;
		char *message_body_encrypted = (char *)message_body;
		for(i=0; i<message_body_size; i++){
			message_body_encrypted[i] = ~(message_body_encrypted[i]);
		}	
		send_size = send(sockfd, buffer, buffer_size, 0);
		if(send_size <= 0){
			printf("SOCKET_ERROR send_size:%d\n", send_size);
			pclose(p);                     
			close(sockfd);
			return -1;
		}
	}    
  
    pclose(p);                     
    return 0; 
}
