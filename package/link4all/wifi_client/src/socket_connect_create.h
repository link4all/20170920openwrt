#ifndef __SOCKET_CONNECT_CREATE_H__
#define __SOCKET_CONNECT_CREATE_H__
#include <stdio.h>        
#include <stdlib.h>        
#include <string.h> 
#include <netinet/in.h>   
#include <sys/types.h>    
#include <sys/socket.h>    

#include "define.h"
#include "config.h"

int socket_connect_create(config_st *config);

#endif