#include <iostream>
#include <stdio.h>
#include <sys/socket.h>
#include <unistd.h>
#include <sys/types.h>
#include <netdb.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <string.h>
#include <stdlib.h>
#include <string.h>

#define PORT 3344

// 接收端 http://blog.csdn.net/robertkun
using namespace std;

int main()
{
	setvbuf(stdout, NULL, _IONBF, 0); 
	fflush(stdout); 

	// 绑定地址
	struct sockaddr_in addrto;
	bzero(&addrto, sizeof(struct sockaddr_in));
	addrto.sin_family = AF_INET;
	addrto.sin_addr.s_addr = htonl(INADDR_ANY);
	addrto.sin_port = htons(PORT);
	
	// 广播地址
	struct sockaddr_in from;
	bzero(&from, sizeof(struct sockaddr_in));
	from.sin_family = AF_INET;
	from.sin_addr.s_addr = htonl(INADDR_ANY);
	from.sin_port = htons(PORT);
	
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

	if(bind(sock,(struct sockaddr *)&(addrto), sizeof(struct sockaddr_in)) == -1) 
	{   
		cout<<"bind error..."<<endl;
		return false;
	}

	int len = sizeof(sockaddr_in);
	char smsg[10] = {0};
	char k=0;
	while(1)
	{
		//从广播地址接受消息
		int ret=recvfrom(sock, smsg, 10, 0, (struct sockaddr*)&from,(socklen_t*)&len);
		if(ret<=0)
		{
			cout<<"read error...."<<sock<<endl;
		}
		else
		{		
			//printf("%s\t", smsg);	
			if (strstr(smsg,"play0"))
			{
			    system("killall -9 madplay");
			    sleep(1);
			    system("/etc/play/play.sh 0");
			    printf("0\n");
			}
			else if(strstr(smsg,"play15"))
			{
			    system("killall -9 madplay");
			    sleep(1);
			    system("/etc/play/play.sh F");
			    printf("F\n");
			}
			else if(strstr(smsg,"play14"))
			{
			    system("killall -9 madplay");
			    sleep(1);
			    system("/etc/play/play.sh E");
			    printf("E\n");
			}
			else if(strstr(smsg,"play13"))
			{
			    system("killall -9 madplay");
			    sleep(1);
			    system("/etc/play/play.sh D");
			    printf("D\n");
			}
			else if(strstr(smsg,"play12"))
			{
			    system("killall -9 madplay");
			    sleep(1);
			    system("/etc/play/play.sh C");
			    printf("C\n");
			}
			else if(strstr(smsg,"play11"))
			{
			    system("killall -9 madplay");
			    sleep(1);
			    system("/etc/play/play.sh C");
			    printf("B\n");
			}
			else if(strstr(smsg,"play10"))
			{
			    system("killall -9 madplay");
			    sleep(1);
			    system("/etc/play/play.sh A");
			    printf("A\n");
			}
			else if (strstr(smsg,"play9"))
			{
			    system("killall -9 madplay");
			    sleep(1);
			    system("/etc/play/play.sh 9");
			    printf("9\n");
			} 
			else if (strstr(smsg,"play8"))
			{
			    system("killall -9 madplay");
			    sleep(1);
			    system("/etc/play/play.sh 8");
			    printf("8\n");
			} 
			else if (strstr(smsg,"play7"))
			{
			    system("killall -9 madplay");
			    sleep(1);
			    system("/etc/play/play.sh 7");
			    printf("7\n");
			} 
			else if (strstr(smsg,"play6"))
			{
			    system("killall -9 madplay");
			    sleep(1);
			    system("/etc/play/play.sh 6");
			printf("6\n");
			} 
			else if (strstr(smsg,"play5"))
			{
			    system("killall -9 madplay");
			    sleep(1);
			    system("/etc/play/play.sh 5");
			printf("5\n");
			} 
			else if (strstr(smsg,"play4"))
			{
			    system("killall -9 madplay");
			    sleep(1);
			    system("/etc/play/play.sh 4");
			printf("4\n");
			} 
			else if (strstr(smsg,"play3"))
			{
			    system("killall -9 madplay");
			    sleep(1);
			    system("/etc/play/play.sh 3");
			printf("3\n");
			}  
			else if (strstr(smsg,"play2"))
			{
			    system("killall -9 madplay");
			    sleep(1);
			    system("/etc/play/play.sh 2");
			printf("2\n");
			} 
			else if (strstr(smsg,"play1"))
			{
			    system("killall -9 madplay");
			    sleep(1);
			    system("/etc/play/play.sh 1");
			printf("1\n");
			}
			else if (strstr(smsg,"stop"))
			{
			   //system("killall -9 madplay");
			    sleep(1);
			    system("/etc/play/stop.sh");
			printf("stop madplay\n");
			} 
			else if (strstr(smsg,"pause"))
			{
			   //system("killall -9 madplay");
			    sleep(1);
			    system("/etc/play/pause.sh");
			printf("pause madplay\n");
			} 
			else if (strstr(smsg,"continue"))
			{
			   //system("killall -9 madplay");
			    sleep(1);
			    system("/etc/play/continu.sh");
			printf("continue madplay\n");
			} 
			else
			{
			printf("nononono");
			}
		}

		sleep(1);
	}

	return 0;
}

