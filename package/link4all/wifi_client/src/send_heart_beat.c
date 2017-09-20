#include <stdio.h>        
#include <stdlib.h>        
#include <string.h> 
#include "send_heart_beat.h"



void send_heart_beat_threading(void *ptr)
{
	config_st *config = (config_st *)ptr;
	int socket_fd = socket_connect_create(config);
	int send_size = 0;
	char buffer[BUFFER_SIZE] = {0};
	int message_header_size = sizeof(message_header_st);	
	message_header_st *message_header  = (message_header_st *)buffer;	
	memcpy(message_header->router_mac, config->router_mac, 6);
	message_header->message_type = 0;
	message_header->data_length = 0;
		
	while(1){
		send_size = send(socket_fd, buffer, message_header_size, 0);
		if(send_size <= 0){
			printf("SOCKET_ERROR send_size:%d\n", send_size);
			close(socket_fd);
			socket_fd = socket_connect_create(config);
			continue;
		}

		sleep(config->heart_beat_second);
	}
	
	close(socket_fd);	
}
