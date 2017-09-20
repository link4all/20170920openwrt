#include <sys/socket.h>
#include <sys/ioctl.h>
#include <netinet/if_ether.h>
#include <net/if.h>
#include <linux/sockios.h>
#include <stdio.h>
#include <string.h>

#include "getmac.h"
/*
int main()
{
	u_char mac[32] = {0};
	char *device_name = "eth1";
	if(get_format_mac(device_name, mac) == 0){
		printf("%s:%s\n", device_name, mac);
	}
    return 0;
} 
*/
int get_format_mac(const char* device_name, u_char *addr)
{
	int stat; 
	u_char addr_buffer[6]; 
	stat = get_mac(device_name, addr_buffer);	
    if (stat == 0) {         
		sprintf(addr, "%02x:%02x:%02x:%02x:%02x:%02x",  addr_buffer[0],
														addr_buffer[1],
														addr_buffer[2],
														addr_buffer[3],
														addr_buffer[4],
														addr_buffer[5]);
		return 0;
    } 
    
	return -1;	
}

int get_mac(const char* device_name, u_char *addr)
{
	struct ifreq req;
	int err,i;
	int s=socket(AF_INET, SOCK_DGRAM, 0); //internet协议族的数据报类型套接口
	strcpy(req.ifr_name, device_name); //将设备名作为输入参数传入
	err=ioctl(s, SIOCGIFHWADDR, &req); //执行取MAC地址操作
	close(s);
	if(err != -1){
		memcpy(addr, req.ifr_hwaddr.sa_data, ETH_ALEN); //取输出的MAC地址
		return 0;
	}
	
	return -1;	
}