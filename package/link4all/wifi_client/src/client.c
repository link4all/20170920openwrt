#include <netinet/in.h>   
#include <sys/types.h>    
#include <sys/socket.h>    
#include <stdio.h>        
#include <stdlib.h>        
#include <string.h> 
#include <stdbool.h> 
#include <unistd.h>
#include <signal.h> 
#include <pthread.h>

#include "define.h"
#include "config.h"
#include "getmac.h"
#include "socket_connect_create.h"
#include "send_heart_beat.h"
#include "send_ap_mac.h"
#include "send_terminal_mac.h"

//如果send在等待协议传送数据时网络断开的话，调用send的进程会接收到一个SIGPIPE信号，进程对该信号的默认处理是进程终止。
void handle_sigpipe(int sig)
{
	printf("SIGPIPE!\n");
}

int main(int argc, char **argv)
{
	char * config_file = "client.conf";
	config_st config;	
	load_config(config_file, &config);
	int message_header_size = sizeof(message_header_st);
	printf("message_header_size:%d\n", message_header_size);
	char *device_name = "eth0";
	if(get_mac(device_name, config.router_mac) != 0){
        printf("get mac error! netcard name:%s\n", device_name); 
        return 0; 	
	}else{
		printf("%s: %02x:%02x:%02x:%02x:%02x:%02x\n", device_name, config.router_mac[0], config.router_mac[1], config.router_mac[2], config.router_mac[3], config.router_mac[4], config.router_mac[5]);
	}	
	
	struct sigaction action;
	action.sa_handler = handle_sigpipe;
	sigemptyset(&action.sa_mask);
	action.sa_flags = 0;
	sigaction(SIGPIPE, &action, NULL);	

	pthread_t send_heart_beat_thread;
	pthread_t send_mac_thread;
	pthread_t send_ap_mac_thread;

	// 线程创建成功，返回0, 失败返回失败号
	if (pthread_create(&send_heart_beat_thread, NULL, (void *)&send_heart_beat_threading, (void *)&config) != 0) {
		printf("线程 send_heart_beat_thread 创建失败\n");
	} else {
		printf("线程 send_heart_beat_thread 创建成功\n");
	}
	
	if (pthread_create(&send_mac_thread, NULL, (void *)&send_mac_threading, (void *)&config) != 0) {
		printf("线程 send_mac_thread 创建失败\n");
	} else {
		printf("线程 send_mac_thread 创建成功\n");
	}	
	
	if (pthread_create(&send_ap_mac_thread, NULL, (void *)&send_ap_mac_threading, (void *)&config) != 0) {
		printf("线程 send_ap_mac_thread 创建失败\n");
	} else {
		printf("线程 send_ap_mac_thread 创建成功\n");
	}
	
	void *send_heart_beat_thread_ret;
	void *send_mac_thread_ret;
	void *send_ap_mac_thread_ret;

	pthread_join(send_heart_beat_thread, &send_heart_beat_thread_ret);
	pthread_join(send_mac_thread, &send_mac_thread_ret);
	pthread_join(send_ap_mac_thread, &send_ap_mac_thread_ret);

	printf("send_heart_beat_thread exit with code %d\n", (int)send_heart_beat_thread_ret);
	printf("send_mac_thread exit with code %d\n", (int)send_mac_thread_ret);
	printf("send_ap_mac_thread exit with code %d\n", (int)send_ap_mac_thread_ret);
    return 0;
}





//printf("send_size:%d\n", send_size);		
//printf("data_length:%d\n", message_header->data_length);
//printf("message_type:%d\n", message_header->message_type);
/*
printf("router_mac:%02x:%02x:%02x:%02x:%02x:%02x\n", message_header->router_mac[0]
													, message_header->router_mac[1]
													, message_header->router_mac[2]
													, message_header->router_mac[3]
													, message_header->router_mac[4]
													, message_header->router_mac[5]);
													
*/
		
/*
int str_endwith(const char *str, const char *reg) 
{  
    int l1 = strlen(str), l2 = strlen(reg);  
    if (l1 < l2) return 0;  
    str += l1 - l2;  
    while (*str && *reg && *str == *reg) {  
        str ++;  
        reg ++;  
    }  
    if (!*str && !*reg) return 1;  
    return 0;  
}
*/