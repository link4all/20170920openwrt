#include <stdio.h>
#include <stdlib.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/select.h>
#include <fcntl.h>
#include <netinet/ip.h>
#include <netinet/in.h>
#include <string.h>
#include <errno.h>
#include <sys/time.h>
#include <signal.h>

#define SELECT_TIMEOUT 5
#define BUFF_SIZE 1024
#define CONFIG_FILE "/etc/config/pt.conf"
#define PT_SERVER	"/etc/config/pt_server.conf"
#define MAXSOCK	1024

static unsigned char auchCRCHi[] = { 
	0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0, 0x80, 0x41, 
	0x01, 0xC0, 0x80, 0x41, 0x00, 0xC1, 0x81, 0x40, 
	0x01, 0xC0, 0x80, 0x41, 0x00, 0xC1, 0x81, 0x40, 
	0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0, 0x80, 0x41, 
	0x01, 0xC0, 0x80, 0x41, 0x00, 0xC1, 0x81, 0x40, 
	0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0, 0x80, 0x41, 
	0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0, 0x80, 0x41, 
	0x01, 0xC0, 0x80, 0x41, 0x00, 0xC1, 0x81, 0x40, 
	0x01, 0xC0, 0x80, 0x41, 0x00, 0xC1, 0x81, 0x40, 
	0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0, 0x80, 0x41, 
	0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0, 0x80, 0x41, 
	0x01, 0xC0, 0x80, 0x41, 0x00, 0xC1, 0x81, 0x40, 
	0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0, 0x80, 0x41, 
	0x01, 0xC0, 0x80, 0x41, 0x00, 0xC1, 0x81, 0x40, 
	0x01, 0xC0, 0x80, 0x41, 0x00, 0xC1, 0x81, 0x40, 
	0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0, 0x80, 0x41, 
	0x01, 0xC0, 0x80, 0x41, 0x00, 0xC1, 0x81, 0x40, 
	0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0, 0x80, 0x41, 
	0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0, 0x80, 0x41, 
	0x01, 0xC0, 0x80, 0x41, 0x00, 0xC1, 0x81, 0x40, 
	0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0, 0x80, 0x41, 
	0x01, 0xC0, 0x80, 0x41, 0x00, 0xC1, 0x81, 0x40, 
	0x01, 0xC0, 0x80, 0x41, 0x00, 0xC1, 0x81, 0x40, 
	0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0, 0x80, 0x41, 
	0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0, 0x80, 0x41, 
	0x01, 0xC0, 0x80, 0x41, 0x00, 0xC1, 0x81, 0x40, 
	0x01, 0xC0, 0x80, 0x41, 0x00, 0xC1, 0x81, 0x40, 
	0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0, 0x80, 0x41, 
	0x01, 0xC0, 0x80, 0x41, 0x00, 0xC1, 0x81, 0x40, 
	0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0, 0x80, 0x41, 
	0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0, 0x80, 0x41, 
	0x01, 0xC0, 0x80, 0x41, 0x00, 0xC1, 0x81, 0x40 
} ;
//**** CRC低位字节值表
static unsigned char auchCRCLo[] = {
	0x00, 0xC0, 0xC1, 0x01, 0xC3, 0x03, 0x02, 0xC2,
	0xC6, 0x06, 0x07, 0xC7, 0x05, 0xC5, 0xC4, 0x04,  
	0xCC, 0x0C, 0x0D, 0xCD, 0x0F, 0xCF, 0xCE, 0x0E, 
	0x0A, 0xCA, 0xCB, 0x0B, 0xC9, 0x09, 0x08, 0xC8, 
	0xD8, 0x18, 0x19, 0xD9, 0x1B, 0xDB, 0xDA, 0x1A, 
	0x1E, 0xDE, 0xDF, 0x1F, 0xDD, 0x1D, 0x1C, 0xDC, 
	0x14, 0xD4, 0xD5, 0x15, 0xD7, 0x17, 0x16, 0xD6, 
	0xD2, 0x12, 0x13, 0xD3, 0x11, 0xD1, 0xD0, 0x10, 
	0xF0, 0x30, 0x31, 0xF1, 0x33, 0xF3, 0xF2, 0x32, 
	0x36, 0xF6, 0xF7, 0x37, 0xF5, 0x35, 0x34, 0xF4, 
	0x3C, 0xFC, 0xFD, 0x3D, 0xFF, 0x3F, 0x3E, 0xFE, 
	0xFA, 0x3A, 0x3B, 0xFB, 0x39, 0xF9, 0xF8, 0x38, 
	0x28, 0xE8, 0xE9, 0x29, 0xEB, 0x2B, 0x2A, 0xEA, 
	0xEE, 0x2E, 0x2F, 0xEF, 0x2D, 0xED, 0xEC, 0x2C, 
	0xE4, 0x24, 0x25, 0xE5, 0x27, 0xE7, 0xE6, 0x26, 
	0x22, 0xE2, 0xE3, 0x23, 0xE1, 0x21, 0x20, 0xE0, 
	0xA0, 0x60, 0x61, 0xA1, 0x63, 0xA3, 0xA2, 0x62, 
	0x66, 0xA6, 0xA7, 0x67, 0xA5, 0x65, 0x64, 0xA4, 
	0x6C, 0xAC, 0xAD, 0x6D, 0xAF, 0x6F, 0x6E, 0xAE, 
	0xAA, 0x6A, 0x6B, 0xAB, 0x69, 0xA9, 0xA8, 0x68, 
	0x78, 0xB8, 0xB9, 0x79, 0xBB, 0x7B, 0x7A, 0xBA, 
	0xBE, 0x7E, 0x7F, 0xBF, 0x7D, 0xBD, 0xBC, 0x7C, 
	0xB4, 0x74, 0x75, 0xB5, 0x77, 0xB7, 0xB6, 0x76, 
	0x72, 0xB2, 0xB3, 0x73, 0xB1, 0x71, 0x70, 0xB0, 
	0x50, 0x90, 0x91, 0x51, 0x93, 0x53, 0x52, 0x92, 
	0x96, 0x56, 0x57, 0x97, 0x55, 0x95, 0x94, 0x54, 
	0x9C, 0x5C, 0x5D, 0x9D, 0x5F, 0x9F, 0x9E, 0x5E, 
	0x5A, 0x9A, 0x9B, 0x5B, 0x99, 0x59, 0x58, 0x98, 
	0x88, 0x48, 0x49, 0x89, 0x4B, 0x8B, 0x8A, 0x4A, 
	0x4E, 0x8E, 0x8F, 0x4F, 0x8D, 0x4D, 0x4C, 0x8C, 
	0x44, 0x84, 0x85, 0x45, 0x87, 0x47, 0x46, 0x86, 
	0x82, 0x42, 0x43, 0x83, 0x41, 0x81, 0x80, 0x40
};

char* BetweenTwoChar(char*, char*, char*);
char* SplitString(char*, char*, int);
char* SplitStringReturn(char*, char*, int, char**);
char* strtok_ex(char *, const char *, char **);
void SwitchToChar(char*,unsigned char);
char *read_car(char *);



int init_sock(int);
int svr_bind(int, unsigned short);
int svr_init(unsigned short);
int svr_listen(int fd);
int cli_init(char *,unsigned short);
int cli_conn_server(int, char *, unsigned short);
void set_sock_nonblock(int);
void process_conn_handle(int, int);
void hearbeat_thread(void *);
int say_hello(int);
void close_socket(int);
int server_accept(int);
int socket_recv(int,int);
int send_data(int, char *);
unsigned short crc16(unsigned char *, unsigned short);
char *pack_msg(int, char *);

void set_sock_nonblock(int sock){
    int flags;
    flags = fcntl(sock, F_GETFL, 0);
        if (flags < 0) {
            printf("fcntl error:%s\n",strerror(errno));
            exit(EXIT_FAILURE);
        }
        if(fcntl(sock, F_SETFL, flags | O_NONBLOCK) < 0){
            printf("fcntl error:%s\n",strerror(errno));
            exit(EXIT_FAILURE);
        }
}


static char pid[256],auth[256],psn[256],dev[256];

int main(int argc, char *argv[]){
    char ip[32];
    char s_port[32],port[32];
	int sc,ss;

	FILE *file;
	char buf[1024] = {0};
	signal(SIGPIPE, SIG_IGN);
	
	if(!(file = fopen(CONFIG_FILE,"r"))){

		perror("open config file error!");
		exit(EXIT_FAILURE);

	}
	memset(&pid,0,sizeof(pid));
	memset(&auth,0,sizeof(auth));
	memset(&psn,0,sizeof(psn));
	memset(&dev,0,sizeof(dev));

	while (fgets(buf, sizeof(buf) -1,file) != NULL){
		sscanf(buf,"%s %s %s %s",pid,auth,psn,dev);
	}
	fclose(file);
	memset(&buf,0,sizeof(buf));

	if(!(file = fopen(PT_SERVER,"r"))){

		perror("open server config file error!");
		exit(EXIT_FAILURE);

	}

	memset(&port,0,sizeof(port));
	memset(&s_port,0,sizeof(s_port));
	memset(&ip,0,sizeof(ip));

	while(fgets(buf,sizeof(buf)-1,file) != NULL){
		sscanf(buf,"%s %s %s",ip,port,s_port);
	}
	fclose(file);
	memset(&buf,0,sizeof(buf));

	ss = svr_init(atoi(s_port));
	sc = cli_init(ip, atoi(port));
	process_conn_handle(ss, sc);
	printf("process exit\n");
	return 0;
}

int svr_init(unsigned short port){
    int fd,sc;
    struct sockaddr_in client_addr;
    fd = init_sock(SOCK_STREAM);
	set_sock_nonblock(fd);
    svr_bind(fd, port);
    svr_listen(fd);
    return fd;
}

int init_sock(int type){
    int fd;
    fd = socket(PF_INET, type, IPPROTO_TCP);
    if (fd < 0){
		perror("Socket create error !");
		exit(EXIT_FAILURE);
    }
    printf("Socket Create OK\n");
    return fd;
}

int svr_bind(int fd, unsigned short port){
    struct sockaddr_in s;
    bzero(&s, sizeof(struct sockaddr_in));
    s.sin_family = AF_INET;
    s.sin_port = htons(port);
    s.sin_addr.s_addr = htonl(INADDR_ANY);
    if ((bind(fd, (struct sockaddr *)&s, sizeof(s))) < 0){
			perror("Bind Server error !");
			close_socket(fd);
			exit(EXIT_FAILURE);
    }
    printf("Bind Server ok\n");
    return 0;
}

int svr_listen(int fd){

    if((listen(fd, 20)) < 0){
		perror("Listen Server error !");
		close_socket(fd);
		exit(EXIT_FAILURE);
    }
    printf("listen server ok\n");
    return 0;
}

int cli_init(char *ip, unsigned short port){
    int fd;
	printf("Client init\n");
    fd = init_sock(SOCK_STREAM);
	cli_conn_server(fd, ip, port); 
    return fd;
}

int cli_conn_server(int fd, char *ip, unsigned short port){
    struct sockaddr_in s;
    bzero(&s, sizeof(struct sockaddr));
    s.sin_family = AF_INET;
    s.sin_port = htons(port);
    s.sin_addr.s_addr = inet_addr(ip);
    printf("Conecting Server...ip:%s port:%d\n", ip, port);


    if((connect(fd, (struct sockaddr*)&s, sizeof(struct sockaddr))) == -1){
		perror("Connecting Server error !");
		if(errno == ECONNREFUSED){
			printf("try again\n");

		}
		close_socket(fd);
        return -1;
    }
    printf("Connect Server ok\n");
    return fd;
}

void process_conn_handle(int s_fd, int cli_fd){

	pthread_t hearbeat_t;

	say_hello(cli_fd);

	if(0 != (pthread_create(&hearbeat_t,NULL,&hearbeat_thread,(void*)&cli_fd))){
		perror("Create hearbeat thread error");	
		exit(EXIT_FAILURE);
	};

	
	int maxfd = 0; // 最大的socket,select 函数第一个使用

	int i = 0;

	/*
	 * 建立客户端连接池
	 */

	int client[MAXSOCK];// select 最大支持1024个socket连接
   //将所有的客户端连接池初始化，将每个成员都设置0-1，表示无效
	
	for(; i < MAXSOCK;i++)
	{
		client[i] = -1;
	}

	maxfd = s_fd;   //程序刚开始执行时，只有服务端socket,所以服务端socket最大
	
	//定义一个事件数据结构
	
	fd_set allset;

	while(1)
	{
		//初始化一个fd_set对象
		FD_ZERO(&allset);
		//将服务器socket放入事件数组allset中（服务端socket需要特殊处理，所以没有放入socket池中)
		
		FD_SET(s_fd,&allset);
		FD_SET(cli_fd,&allset);

		//先假设最大的socket就是服务器socket；
		maxfd = s_fd;
		//遍历socket池，找出值最大的socket
		for (i = 0; i < MAXSOCK; i++)
		{
			if (client[i] != -1)
			{

				//将socket池中的所有socket都添加到事件数组allset中
				FD_SET(client[i],&allset);
				if(client[i] > maxfd){
					maxfd = client[i];//maxfd 永远是最大的socket
				}
			}
		}

		//开始等待socket发生读事件
		
		int rc = select(maxfd+1,&allset,NULL,NULL,NULL);
		        /*
				 *  select函数返回之后，allset数组的数据产生变化，现在allset数组里的数据是发生事件的socket
				 *  select和epoll不同，select每次返回后，
				 *	会清空select池中的所有socket，所有的socket等select返回后就被清除了
				 *  所以必须由程序建立一个socket池，每次都将socket池中的socket加入到select池中
				 *	select不会为程序保存socket信息，这与epoll最大的不同，
				 *  epoll添加到events中的socket，如果不是程序员清除，epoll永远保留这些socket
			     */
		if (rc < 0)
		{
			// select函数出错，跳出循环
			perror("Select failed !");
			break;
		}

		//判断是否是服务器socket接收到数据,有客户连接
		
		if (FD_ISSET(s_fd,&allset))
		{

			//accept
			int client_st = server_accept(s_fd);
			if (client_st < 0)
			{
				//直接跳出select循环
				perror("accept error");
				break;
			}

			//客户端连接成功 设置户端非阻塞
			
			set_sock_nonblock(client_st);

			//将客户端socket加入socket池中
			for(i = 0;i < MAXSOCK;i++)
			{
				if(client[i] == -1)
				{
					client[i] = client_st;
					break;
				}
			}

			if(i == MAXSOCK)
			{
				//socket池已满，关闭客户端连接
				printf("Socket pool full\n");
				close_socket(client_st);
			}
		}

		if (FD_ISSET(cli_fd,&allset))
		{
			set_sock_nonblock(cli_fd);
				for(i = 0;i < MAXSOCK;i++){
					if(client[i] == -1){
						client[i] = cli_fd;
						break;
					}
				}
			if(i == MAXSOCK){
				printf("Socket pool full\n");
				close_socket(cli_fd);
			}
		}

		//处理客户端的socket
		
		for (i = 0;i < MAXSOCK;i++)
		{
			if (client[i] == -1)
			{
				//无效socket直接退出
				continue;
			}
			//判断是否是这个socket有事件发生
			if (FD_ISSET(client[i],&allset))
			{
				//接收消息
				if (socket_recv(client[i],cli_fd)< 0)
				{
					//如果接收消息出错，关闭客户端连接socket
					if(errno == ECONNRESET){
						printf("Disconnect\n");
						close_socket(client[i]);
					//从socket池中将这个socket清除
						client[i] = -1;
					}
				}
				rc--;
			}
			//说明所有消息的socket已经处理完成
			if (rc <0)
			{
				//备注：双循环break只能跳出最近的一重循环
				break;
			}
		}
	}

	//close server socket
	close_socket(s_fd);
}

int send_data(int fd, char *buf){
	int ret;

	if(strncmp(buf,"*113883#",8) == 0){
		printf("say hello\n");
		ret = send(fd, buf,strlen(buf),MSG_DONTWAIT);
		if(ret == -1){
			perror("say hello error");
			return -1;
		}
		return ret;
	}

	printf("send data to server:%s\n",buf);

	ret = send(fd, buf, strlen(buf),MSG_DONTWAIT);

	if(ret <= 0){
		perror("send data error!");
	}
	return ret;
}

void hearbeat_thread(void *args){
	int fd = *((int *)args);
	printf("hearbeat thread start\n");
	while(1){
		write(fd,"$",1);
		sleep(50);
	}
	printf("hearbeat terminated\n");
}


int say_hello(int fd){
	char *str = (char *)malloc(sizeof(char));
	int ret;

	sprintf(str,"*%s#%s#%s*",pid,auth,psn);
	
	send_data(fd, str);

	sleep(3);
}

void close_socket(int fd){
	close(fd);
}

int server_accept(int fd){
	char buf[1024] = {0};
	int ret;
	unsigned short port;
	struct sockaddr_in client_addr;
	socklen_t addrlen = sizeof(client_addr);
	ret = accept(fd, (struct sockaddr *)&client_addr, &addrlen);
	inet_ntop(AF_INET, &client_addr.sin_addr, buf,sizeof(buf));
	port = ntohs(client_addr.sin_port);
	printf("New connect frome IP:%s Port:%d\n",buf,port);
	return ret;
}

int socket_recv(int fd,int cli_fd){
	char buf[1024] = {0};
	char buf2[1024] = {0};
	int retval = 0;
	retval = recv(fd,buf,sizeof(buf),MSG_DONTWAIT);
	if(retval == -1|| retval == 0){
		return retval;	
	}

	if (strncmp(buf,"*",1) == 0){
		printf("remote server request data:%s\n",buf);
		return retval;
	}

	if (strncmp(buf,"$",1) == 0){
		printf("remote server request hearbeat data\n");
		return retval;
	}
	
	//strncpy(buf2,buf+3,15);	
	memcpy(&buf2,&buf,strlen(buf)-2);
	//char *buf3 = pack_msg(55,buf2);	
	char *buf3 = read_car(buf2);
	retval = send_data(cli_fd, buf3);
	return retval;
}

char *pack_msg(int cmd,char *buf){

	char str[1024] = {0};
	char tmp[1024] = {0};
	sprintf(tmp,"%d%s000000000000[%s]",cmd,dev,buf);
	printf("crc string:%s\n",tmp);
	unsigned short crc = crc16((unsigned char *)(tmp),strlen(tmp));

	char Dest[5];
	SwitchToChar(Dest,(crc>>8)&0xFF);
	SwitchToChar(Dest+2,crc&0xFF);
	Dest[4]=0;

	sprintf(str,"*%s%s#",tmp,Dest);	
	return str;

}

char * read_car(char *car){
	return pack_msg(55,car);	
}
	

unsigned short crc16(unsigned char *puchMsg/* 要进行CRC校验的消息 */, unsigned short usDataLen/* 消息中字节数 */)
{
	unsigned char uchCRCHi = 0xFF ; /* 高CRC字节初始化 */ 
	unsigned char uchCRCLo = 0xFF ; /* 低CRC 字节初始化 */ 
	unsigned uIndex ; /* CRC循环中的索引 */ 
	while (usDataLen--) /* 传输消息缓冲区 */ 
	{ 
		uIndex = uchCRCHi ^ *puchMsg++ ; /* 计算CRC */ 
		uchCRCHi = uchCRCLo ^ auchCRCHi[uIndex] ; 
		uchCRCLo = auchCRCLo[uIndex] ; 
	} 
	return (uchCRCHi << 8 | uchCRCLo) ; 
}
/*两个字符串直接的数据的截取*/
char* BetweenTwoChar(char* content,char* start,char* end)
{
	char* ptr;  
	char* ptr_ret;
	char* findEnd;
	//条件判断是否，防止传入数据本身就是错误
	if(NULL==content){
		return NULL;
	}
					
	content = strchr(content,*start);

	if(NULL==content){
		return NULL;
	}
	//第一次查询start前面的字符，如果start不存在，则会显示全部字符串
	ptr = strtok(content, start); 
					
	findEnd = strchr(ptr,*end);

	if(NULL==findEnd){//没有找到结尾的符号
		return NULL;
	}
					
	ptr_ret = strtok(ptr, end); //end字符前面的所有字符的遍历--ptr_ret肯定不会为空，可以不用判断
	ptr = strtok(NULL, end);

	if(NULL==ptr){//说明end字符不存在，则直接return 空
	return NULL;
	}
																											  
	return ptr_ret;
}

//参数content是指的是待分割的字符串，split是分割的字符串的条件，n指的是截取的第几个字符串
////这个函数会有一个缺陷就是，会把原来的空间函数破坏掉，他们的原理是强制把分割符合清0

char* SplitString(char* content,char* split,int pos)
{
	char* ptr;
	int i = 1;
	ptr = strtok(content,split);

	if(1==pos){
	return ptr;
	}

	while (ptr != NULL) {  
	i++;
	ptr = strtok(NULL, split); 
	char* findChr = strchr(ptr,*split);
			if(NULL==findChr){
				return NULL;
			}
			if(i==pos){
		return ptr;
		}
	}

	return NULL;
}

/*分割字符串，会把分割剩余的字符串通过returnPtr，传递到上层调用函数，连续分割的时候，效率最高*/
char* SplitStringReturn(char* content,char* split,int pos,char** returnPtr)
{
	char* ptr;
	int i = 1;
				
	ptr = strtok_ex(content,split,&content);
	if(1==pos){

		*returnPtr = content;
		return ptr;
	}
	while (ptr != NULL) {  
		i++;
		ptr = strtok_ex(content, split,&content); 
		if(i==pos){
			*returnPtr = content;
			return ptr;
		}
	}

	return NULL;
}

char* strtok_ex(char * _Str, const char * _Delim, char ** _Context)
{
	char* temp;
	if(NULL==_Str){
		return NULL;
	}
	temp = strstr(_Str,_Delim);
					
	if(NULL==temp){
		*_Context = 0;
	return _Str;
	}
	*_Context = temp+1;
	*temp = 0;
	return _Str;
}

void SwitchToChar(char* str,unsigned char data)
{
	if(data/16>=10){
	*str = 'A'+data/16-10;
	}else{
	*str = '0'+data/16;
	}

		if(data%16>=10){
				*(str+1) = 'A'+data%16-10;
		}else{
			*(str+1) = '0'+data%16;
		}
}


