#include <iostream>
#include <stdio.h>
#include <sys/socket.h>
#include <unistd.h>
#include <sys/types.h>
#include <netdb.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <string.h>

#define PORT 3344

// 发送端
using namespace std;

int main(int argc, char *argv[])
{
	setvbuf(stdout, NULL, _IONBF, 0); 
	fflush(stdout); 

	int sock = -1;
	if ((sock = socket(AF_INET, SOCK_DGRAM, 0)) == -1) 
	{   
		cout<<"socket error"<<endl;	
		return false;
	}   
	
	const int opt = 1;
	//设置该套接字为广播类型，
	int nb = 0;
	nb = setsockopt(sock, SOL_SOCKET, SO_BROADCAST, (char *)&opt, sizeof(opt));
	if(nb == -1)
	{
		cout<<"set socket error..."<<endl;
		return false;
	}

	struct sockaddr_in addrto;
	bzero(&addrto, sizeof(struct sockaddr_in));
	addrto.sin_family=AF_INET;
	addrto.sin_addr.s_addr=htonl(INADDR_BROADCAST);
	addrto.sin_port=htons(PORT);
	int nlen=sizeof(addrto);
	
	char i=0;
	//while(1)
	for(i=0;i<3;i++)
	{
		sleep(1);
		//从广播地址发送消息
		//char smsg[] = {"play1"};
		//int ret=sendto(sock, smsg, strlen(smsg), 0, (sockaddr*)&addrto, nlen);
	int ret=sendto(sock, argv[1], strlen(argv[1]), 0, (sockaddr*)&addrto, nlen);
		if(ret<0)
		{
			cout<<"send error...."<<ret<<endl;
		}
		else
		{		
			printf("send %s ok\r\n",argv[1]);	
		}
	}

	return 0;
}

