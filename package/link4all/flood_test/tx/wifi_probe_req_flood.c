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
#include <pcap.h>


#include "make_packet.h"


int ret = -1;
//全局变量
int ato16(char t ,char c )
{
	int value = 0;
	int value1 = 0;
	switch(t)
	{

		case 'a':
			value = 10;
			break;

		case 'b':
			value = 11;
			break;
		case 'c':
			value = 12;
			break;
		case 'd':
			value = 13;
			break;
		case 'e':
			value = 14;
			break;
		case 'f':
			value = 15;
			break;

		default:
			break;
	}

	switch(c)
	{
		case 'a':
			value1 = 10;
			break;
		case 'b':
			value1 = 11;
			break;
		case 'c':
			value1 = 12;
			break;
		case 'd':
			value1 = 13;
			break;
		case 'e':
			value1 = 14;
			break;
		case 'f':
			value1 = 15;
			break;
		default:
			break;
	}
	if(value == 0)
	{
		value = t - 48;
		if(value1 == 0)
		{
			value1 = c -48;
			value = value*16+value1;
		}
		else
		{
			value=value*16+value1;
		}

	}
	else
	{
		if(value1 == 0)
		{
			value1 = c -48;
			value = value*16+value1;
		}
		else
		{
			value=value*16+value1;
		}
	}
	
	return value;
}
//如果send在等待协议传送数据时网络断开的话，调用send的进程会接收到一个SIGPIPE信号，进程对该信号的默认处理是进程终止。
void handle_sigpipe(int sig)
{
	printf("SIGPIPE!\n");
}

void* print_count_threading(void* arg)
{
	int starting_time = 1;
	int *count = (int*)arg;
	int last_count = 0;
	int cur_count = 0;
	while(1){
		cur_count = *count;
		printf("cur: %d packets/s  avg: %d packets/s ret === %d\n", cur_count-last_count, cur_count/starting_time++,ret);
		last_count = cur_count;
		sleep(1);
	}
}



int main(int argc, char **argv)
{
	//config_st config;	
	//load_config(config_file, g_config);	
	long long mac =188897262065273;
	char buf[13] = { 0 };
	int i = 0, j = 44;
	
	
	struct sigaction action;
	action.sa_handler = handle_sigpipe;
	sigemptyset(&action.sa_mask);
	action.sa_flags = 0;
	sigaction(SIGPIPE, &action, NULL);	

	printf("hello world!\n");
	pcap_open(argv[1]);
	
	//int sleep_time = atoi(argv[2]);
	
	unsigned char packet[655] = {'\0'};
	int len = 153;	
	
	generate_probe_beacon(packet, len);
	
	print_buffer(packet, len);
	//mac_addr(packet);

	int count = 0;
	
	pthread_t thread;
	int rc1=0;
	rc1 = pthread_create(&thread, NULL, print_count_threading, &count);
	if(rc1 != 0)
		printf("%s: %d\n",__func__, strerror(rc1));
	
	
	while(1){
		mac++;
		sprintf(buf, "%llx", mac);
		for(i=0;i<12;i=i+2)
		{
		// 0 1      2 3    4 5  
			packet[j] = ato16(buf[i],buf[i+1]);
			j++;
		}
		ret = pcap_send(packet, len);	
		count++;
		j= 44;
		usleep(10);
	}
    return 0;
}
