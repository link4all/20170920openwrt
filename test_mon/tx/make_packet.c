#include <sys/socket.h>
#include <sys/ioctl.h>
#include <netinet/if_ether.h>
#include <net/if.h>
#include <linux/sockios.h>
#include <stdio.h>
#include <string.h>

#include "make_packet.h"
// #include <pcap/pcap.h>

int pcap_open(const char * nice)
{
	printf("open\n");
	//char *nice = "mon0";
    char errbuf[PCAP_ERRBUF_SIZE] = {'\0'};
	printf("open nice:%s\n", nice);
    m_lpHandle = pcap_open_live(nice, 65536, 1, 0, errbuf);
    if (m_lpHandle == NULL) {
		printf("open error m_lpHandle:%d\n", m_lpHandle);
        return -1;
    }
	printf("open ok m_lpHandle:%d\n", m_lpHandle);
	return 0;
}

int pcap_send(char *buf, int len)
{
	int i = pcap_sendpacket(m_lpHandle, (unsigned char *)buf, len);
	if(i!=0){
		printf("send:%d\n", i);
	}
	return i;
}


void print_buffer(char *buf, int len)
{
	int i=0;
	int j=0;
	for(i=0; i<len; i++){
		printf("%02x ", (unsigned char)buf[i]);
		j++;
		if(j==16){
			printf("\n");
			j=0;
		}
	}
	printf("\n");
}


void generate_probe_beacon(char *buf, int len)
{
	if(len<152){
		printf("generate_probe_req error!\n");
		return;
	}
	buf[0]=0x00;	buf[1]=0x00;	buf[2]=0x22;	buf[3]=0x00;	buf[4]=0x2f;	buf[5]=0x48;	buf[6]=0x00;	buf[7]=0x00;
	buf[8]=0xdd;	buf[9]=0x9f;	buf[10]=0x49;	buf[11]=0x00;	buf[12]=0x00;	buf[13]=0x00;	buf[14]=0x00;	buf[15]=0x00;
	
	buf[16]=0x10;	buf[17]=0x6c;	buf[18]=0x76;	buf[19]=0x09;	buf[20]=0xc0;	buf[21]=0x00;	buf[22]=0xc5;	buf[23]=0x00;
	buf[24]=0x00;	buf[25]=0x00;	buf[26]=0x00;	buf[27]=0x00;	buf[28]=0x00;	buf[29]=0x00;	buf[30]=0x00;	buf[31]=0x00; 
	
	buf[32]=0x00;	buf[33]=0x00;	buf[34]=0x80;	buf[35]=0x00;	buf[36]=0x00;	buf[37]=0x00;	buf[38]=0xff;	buf[39]=0xff; 
	buf[40]=0xff;	buf[41]=0xff;	buf[42]=0xff;	buf[43]=0xff;	buf[44]=0x0c;	buf[45]=0x12;	buf[46]=0x01;	buf[47]=0x00;
	
	buf[48]=0x39;	buf[49]=0x35;	buf[50]=0x0c;	buf[51]=0x12;	buf[52]=0x01;	buf[53]=0x00;	
	buf[54]=0x39;	buf[55]=0x35; 
	buf[56]=0x70;	buf[57]=0x23;	buf[58]=0x55;	buf[59]=0xb5;	buf[60]=0x9f;	buf[61]=0x6d;	buf[62]=0x51;	buf[63]=0x00;
	buf[64]=0x00;   buf[65]=0x00;	buf[66]=0x00;	buf[67]=0x64;	buf[68]=0x01;	buf[69]=0x14;	buf[70]=0x00;	buf[71]=0x09;
	
	buf[72]=0x74;   buf[73]=0x65;	buf[74]=0x73;	buf[75]=0x74;	buf[76]=0x5f;	buf[77]=0x73;	buf[78]=0x73;	buf[79]=0x69; 
	buf[80]=0x64;	buf[81]=0x01;	buf[82]=0x08;	buf[83]=0x82;	buf[84]=0x84;	buf[85]=0x0b;	buf[86]=0x16;	buf[87]=0x24; 
	
	buf[88]=0x30;	buf[89]=0x48;	buf[90]=0x6c;	buf[91]=0x03;	buf[92]=0x01;	buf[93]=0x01;	buf[94]=0x05;	buf[95]=0x04; 
	buf[96]=0x00;	buf[97]=0x03;	buf[98]=0x00;	buf[99]=0x00;	buf[100]=0x2a;	buf[101]=0x01;	buf[102]=0x04;	buf[103]=0x2f; 
	
	buf[104]=0x01;	buf[105]=0x04;	buf[106]=0x32;	buf[107]=0x04;	buf[108]=0x0c;	buf[109]=0x12;	buf[110]=0x18;	buf[111]=0x60;
	buf[112]=0xdd;	buf[113]=0x09;	buf[114]=0x00;	buf[115]=0x10;	buf[116]=0x18;	buf[117]=0x02;	buf[118]=0x02;	buf[119]=0xf0; 
	buf[120]=0x2c;	buf[121]=0x00;	buf[122]=0x00;	buf[123]=0xdd;	buf[124]=0x18;	buf[125]=0x00;	buf[126]=0x50;	buf[127]=0xf2;
	
	buf[128]=0x02;	buf[129]=0x01;	buf[130]=0x01;	buf[131]=0x00;	buf[132]=0x00;	buf[133]=0x03;	buf[134]=0xa4;	buf[135]=0x00; 
	buf[136]=0x00;	buf[137]=0x27;	buf[138]=0xa4;	buf[139]=0x00;	buf[140]=0x00;	buf[141]=0x42;	buf[142]=0x43;	buf[143]=0x5e; 
	
	buf[144]=0x00;	buf[145]=0x62;	buf[146]=0x32;	buf[147]=0x2f;	buf[148]=0x00;	buf[149]=0x19;	buf[150]=0x9f;	buf[151]=0x4b; 
	buf[152]=0x27;	
	
	return;
}

