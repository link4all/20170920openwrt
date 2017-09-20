#include "send_terminal_mac.h"

void send_mac_threading(void *ptr)
{
	config_st *config = (config_st *)ptr;
	int socket_fd = socket_connect_create(config);		
	while(1){
		if(send_mac_from_pipe(config, socket_fd) != 0){
			socket_fd = socket_connect_create(config);
		}
		sleep(config->sleep_second);
	}	
    close(socket_fd);
}

int send_mac_from_pipe(const config_st *config, int sockfd) 
{ 	
  	int send_size = 0;
    FILE *p = popen(config->mac_cmd, "r"); 
    if(p == NULL){ 
        printf("popen error! mac_cmd:%s\n", config->mac_cmd); 
        return 0; 
    }
	
    char buffer[BUFFER_SIZE] = {0};
	int message_header_size = sizeof(message_header_st);
	int message_body_size = BUFFER_SIZE - message_header_size;
	char *message_body = buffer + message_header_size;
	
	message_header_st *message_header  = (message_header_st *)buffer;
	memcpy(message_header->router_mac, config->router_mac, 6);
	message_header->message_type = 1;
	
	
	memset(message_body, 0, message_body_size);
    while (fgets(message_body, message_body_size, p) != NULL)  
    {  
		if(message_body[0] != '-'){
			continue;
		}
		int message_body_length = strlen(message_body);
		//printf("[%d]%s", message_body_length, message_body);
		//对消息体按位取反
		int i=0;
		for(i=0; i<message_body_length; i++){
			message_body[i] = ~(message_body[i]);
		}
		message_header->data_length = message_body_length;
		send_size = send(sockfd, buffer, message_header_size + message_header->data_length, 0);
		
		memset(message_body, 0, message_body_size);
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