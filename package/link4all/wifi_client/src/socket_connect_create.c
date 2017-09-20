#include "socket_connect_create.h"



int socket_connect_create(config_st *config){
	int socket_fd = -1; 
	while((socket_fd = socket(AF_INET, SOCK_STREAM, 0)) < 0){
		printf("Create Socket Failed!\n");
		sleep(config->sleep_second);
	}
     
    struct sockaddr_in server_addr;
    bzero(&server_addr, sizeof(server_addr));
    server_addr.sin_family = AF_INET;
    if(inet_aton(config->server_ip, &server_addr.sin_addr) == 0){
        printf("Server IP Address Error!\n");
		close(socket_fd);
		exit(-1);
    }
    server_addr.sin_port = htons(config->server_port);
    socklen_t server_addr_length = sizeof(server_addr);
    
    while(connect(socket_fd, (struct sockaddr*)&server_addr, server_addr_length) < 0){
        printf("Can't Connect To %s!\n", config->server_ip);
        sleep(config->sleep_second);
    }
	
	return socket_fd;
}