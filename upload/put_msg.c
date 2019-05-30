#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <string.h>
#include <stdlib.h>
#include <time.h>


#include <arpa/inet.h>
#include <netdb.h>
#include <sys/types.h>
#include <netinet/in.h>
#include <sys/socket.h>



#define LEFTROTATE(x, c) (((x) << (c)) | ((x) >> (32 - (c))))
// These vars will contain the hash
uint32_t h0, h1, h2, h3;

void md5(uint8_t *initial_msg, size_t initial_len) {
    
    uint8_t *msg = NULL;
 
    uint32_t r[] = {7, 12, 17, 22, 7, 12, 17, 22, 7, 12, 17, 22, 7, 12, 17, 22,
                    5,  9, 14, 20, 5,  9, 14, 20, 5,  9, 14, 20, 5,  9, 14, 20,
                    4, 11, 16, 23, 4, 11, 16, 23, 4, 11, 16, 23, 4, 11, 16, 23,
                    6, 10, 15, 21, 6, 10, 15, 21, 6, 10, 15, 21, 6, 10, 15, 21};

    // Use binary integer part of the sines of integers (in radians) as constants// Initialize variables:
    uint32_t k[] = {
        0xd76aa478, 0xe8c7b756, 0x242070db, 0xc1bdceee,
        0xf57c0faf, 0x4787c62a, 0xa8304613, 0xfd469501,
        0x698098d8, 0x8b44f7af, 0xffff5bb1, 0x895cd7be,
        0x6b901122, 0xfd987193, 0xa679438e, 0x49b40821,
        0xf61e2562, 0xc040b340, 0x265e5a51, 0xe9b6c7aa,
        0xd62f105d, 0x02441453, 0xd8a1e681, 0xe7d3fbc8,
        0x21e1cde6, 0xc33707d6, 0xf4d50d87, 0x455a14ed,
        0xa9e3e905, 0xfcefa3f8, 0x676f02d9, 0x8d2a4c8a,
        0xfffa3942, 0x8771f681, 0x6d9d6122, 0xfde5380c,
        0xa4beea44, 0x4bdecfa9, 0xf6bb4b60, 0xbebfbc70,
        0x289b7ec6, 0xeaa127fa, 0xd4ef3085, 0x04881d05,
        0xd9d4d039, 0xe6db99e5, 0x1fa27cf8, 0xc4ac5665,
        0xf4292244, 0x432aff97, 0xab9423a7, 0xfc93a039,
        0x655b59c3, 0x8f0ccc92, 0xffeff47d, 0x85845dd1,
        0x6fa87e4f, 0xfe2ce6e0, 0xa3014314, 0x4e0811a1,
        0xf7537e82, 0xbd3af235, 0x2ad7d2bb, 0xeb86d391};
 
    h0 = 0x67452301;
    h1 = 0xefcdab89;
    h2 = 0x98badcfe;
    h3 = 0x10325476;
 
 
    int new_len;
    for(new_len = initial_len*8 + 1; new_len%512!=448; new_len++);
    new_len /= 8;
 
    msg = (uint8_t *)calloc(new_len + 64, 1); // also appends "0" bits 
                                   // (we alloc also 64 extra bytes...)
    memcpy(msg, initial_msg, initial_len);
    msg[initial_len] = 128; // write the "1" bit
 
    uint32_t bits_len = 8*initial_len; // note, we append the len
    memcpy(msg + new_len, &bits_len, 4);           // in bits at the end of the buffer
 
    // Process the message in successive 512-bit chunks:
    //for each 512-bit chunk of message:
    int offset;
    for(offset=0; offset<new_len; offset += (512/8)) {
 
        // break chunk into sixteen 32-bit words w[j], 0 ≤ j ≤ 15
        uint32_t *w = (uint32_t *) (msg + offset);
 

 
        // Initialize hash value for this chunk:
        uint32_t a = h0;
        uint32_t b = h1;
        uint32_t c = h2;
        uint32_t d = h3;
 
        // Main loop:
        uint32_t i;
        for(i = 0; i<64; i++) {

 
            uint32_t f, g;
 
             if (i < 16) {
                f = (b & c) | ((~b) & d);
                g = i;
            } else if (i < 32) {
                f = (d & b) | ((~d) & c);
                g = (5*i + 1) % 16;
            } else if (i < 48) {
                f = b ^ c ^ d;
                g = (3*i + 5) % 16;          
            } else {
                f = c ^ (b | (~d));
                g = (7*i) % 16;
            }
            uint32_t temp = d;
            d = c;
            c = b;
            b = b + LEFTROTATE((a + f + k[i] + w[g]), r[i]);
            a = temp;


 
        }
 
        // Add this chunk's hash to result so far:
 
        h0 += a;
        h1 += b;
        h2 += c;
        h3 += d;
 
    }
 
    // cleanup
    free(msg);
 
}
int md5_pack(unsigned char *packed_data)
{
	unsigned char *p1,*p2,*p3,*p4;
	int index = 0;
	p1=(unsigned char *)&h0;
	p2=(unsigned char *)&h1;
	p3=(unsigned char *)&h2;
	p4=(unsigned char *)&h3;
	
	//debug
	printf("md5 is : ");
	printf("%2.2x%2.2x%2.2x%2.2x", p1[0], p1[1], p1[2], p1[3]);	
	printf("%2.2x%2.2x%2.2x%2.2x", p2[0], p2[1], p2[2], p2[3]);
	printf("%2.2x%2.2x%2.2x%2.2x", p3[0], p3[1], p3[2], p3[3]);
	printf("%2.2x%2.2x%2.2x%2.2x", p4[0], p4[1], p4[2], p4[3]);
	printf("\r\n");

	while(index < 16)
	{
		if(index < 4)
		{
			*(packed_data+index) = p1[index];
		}
		else if(index < 8)
		{
			*(packed_data+index) = p2[index-4];
		}
		else if(index < 12)
		{
			*(packed_data+index) = p3[index-8];
		}
		else
		{
			*(packed_data+index) = p4[index-12];
		}
		index++;
	}
	return 0;
}

void Str2BCD(unsigned char* dst,char *src,unsigned char length)
{
	int i,j;
	unsigned char lo_nibble,hi_nibble;
	char c;
	if((dst==NULL)||(src==NULL))
	{
		return;
	}
	j=0;
	for(i =0; i < length; i++)
	{
		c = src[i];
		lo_nibble = src[i]&0x0f;
		hi_nibble = (src[i]>>4)&0x0f;

		if((hi_nibble >= 0x0) && (hi_nibble <= 0x09))
		{
			dst[j++]=hi_nibble+0x30;
		}
		else 
		{
			dst[j++]=hi_nibble+'A'-10;
		}

		if((lo_nibble >= 0x0) && (lo_nibble <= 0x09))
		{
			dst[j++]=lo_nibble+0x30;
		}
		else 
		{
			dst[j++]=lo_nibble+'A'-10;
		}
	}
}

//md5-test time->bcd +data 

int uCharToHex(unsigned char* src,unsigned char* dst,int MaxLen)
{
        int i,j;
        unsigned char high,low;

        if((src==NULL)||(dst==NULL))
                return -1;
        i=0;
        j=0;
        while(i<MaxLen)
        {
            //// high byte
                if((src[i]>=0)&&(src[i]<=9))
                {
                        high= src[i];
                }
                else if ((src[i]>=0x30)&&(src[i]<=0x39))
                {
                        high= src[i]-0x30;
                }
                else if((src[i]>='a')&&(src[i]<='f'))
                {
                        high= src[i]-'a'+10;
                }
                else if((src[i]>='A')&&(src[i]<='F'))
                {
                        high= src[i]-'A'+10;
                }

                i++; //// low byte
                if((src[i]>=0)&&(src[i]<=9))
                {
                        low= src[i];
                }
                else if ((src[i]>=0x30)&&(src[i]<=0x39))
                {
                        low= src[i]-0x30;
                }
                else if((src[i]>='a')&&(src[i]<='f'))
                {
                        low= src[i]-'a'+10;
                }
                else if((src[i]>='A')&&(src[i]<='F'))
                {
                        low= src[i]-'A'+10;
                }
                dst[j]=((high&0xF)<<4)+(low&0xF);

                //// next Byte
                j++;
                i++;
        }
        return j;
}



int int_to_hex(int num,unsigned char * hex_len)
{
	//char hex_len[2] = {'\0'};
	unsigned char char_len[4] = {'\0'};
	sprintf((char *)char_len, "%04x",num);
	uCharToHex(char_len, hex_len, 4);
	return (strlen((char *)(hex_len)));
}
int int_to_hex_2(int num,unsigned char * hex_len)
{
        //char hex_len[2] = {'\0'};
        unsigned char char_len[4] = {'\0'};
	int hex_num = 0;
	hex_num = num/10*16 + num%10;
        sprintf((char *)char_len, "%02x",hex_num);
        uCharToHex(char_len, hex_len, 2);
        return (strlen((char *)(hex_len)));
}
int get_rtx_data(int num, unsigned char * hex_len)
{
        //char hex_len[2] = {'\0'};
        unsigned char char_len[4] = {'\0'};
        sprintf((char *)char_len, "%08x",num);
        uCharToHex(char_len, hex_len, 8);
        return (strlen((char *)(hex_len)));
}

int get_time(unsigned char *packed_data)
{
	struct tm *t;
        time_t tt;
        time_t ts;

        struct tm tr = {0};
	int index = 0;
	int temp_date = 0;
	unsigned char temp[2] = {'\0'};
	
        time(&tt);
        t = localtime(&tt);

	int_to_hex_2((t->tm_year + 1900 - 2000), packed_data+index);

	printf("-----test ------ %x ---\r\n",packed_data[0]);

	printf("year is %d, %02x\r\n",(t->tm_year + 1900 - 2000), packed_data[index]);
	
	index++;
	//month
	int_to_hex_2((t->tm_mon + 1),packed_data+index);
	
	printf("mon is %d, %02x\r\n",(t->tm_mon + 1),(packed_data[index]));
	index++;
	//day
	int_to_hex_2(t->tm_mday, packed_data+index);
	index++;
	//hour
	int_to_hex_2(t->tm_hour, packed_data+index);
	index++;
	//min
	int_to_hex_2(t->tm_min, packed_data+index);
	index++;
	//sec
	int_to_hex_2(t->tm_sec, packed_data+index);
	index++;
	return index;

}

void Uptolow(unsigned char * upstr, int len)
{
	int index = 0;
	while(index < len)
	{
		if(upstr[index] > 64 && upstr[index] < 91)
		{
			upstr[index] += 32;
		}
		index++;
	}
  
}


int pack_data(unsigned char Flag1,unsigned char *device_id,unsigned char cmd1,unsigned char cmd2,unsigned char * data,unsigned char * bsd_data)
{
	int pack_len = 0;
	int index = 0;
	int data_len = (strlen((char *)(data)) /2);//TL+V
	int time_len = 6;
	unsigned char *SkySimDevKey =(unsigned char *)("E91440CE747F325289");
	unsigned char md5_value[512] = {'\0'};
	unsigned char md5_32[32] = {'\0'};
	unsigned char md5_result[16] = {'\0'};
	unsigned char md5_hex[512] = {'\0'};
	unsigned char packed_data[512] = {'\0'};
	//unsigned char *p;
	printf("data len is %d \r\n",data_len);
	

	time_len = get_time((packed_data+16));
	printf("check pakced_data time %02x \r\n",packed_data[16]);
	printf("time_len is %d \r\n",time_len);	
	pack_len = 2+8+2+2+time_len+data_len+16;
	//PKL
	printf("pakced_pkl %d\r\n",pack_len);
	int_to_hex(pack_len,packed_data);
	printf("packed_pkl is %02x, %02x\r\n",packed_data[0],packed_data[1]);
	index += 2;
	//FLAG
	*(packed_data+index) = Flag1;
	index++;
	*(packed_data + index) = 0x55;
	index++;
	//device id
	uCharToHex(device_id,(packed_data+index),16);
	index += 8;
	//CMD
	*(packed_data + index) = cmd1;
	index++;
	*(packed_data + index) = cmd2;
	index++;
	//udl
	int_to_hex((data_len+time_len),(packed_data+index));
	index+=2;
	//date
	index+=time_len;
	
	//data +TLV
	uCharToHex(data, (packed_data+index), data_len*2);

	index += data_len;
	
	//MD5
	printf("start md5--\r\n");

	memcpy((char *)(md5_hex), (char *)(packed_data+16),data_len+time_len);
	/*
	//MD5-DATA
	memcpy((char *)(md5_hex), (char *)(packed_data+22),((data_len)));
	printf("start md5--1\r\n");
	//MD5-TIME
	memcpy((char *)(md5_hex+data_len), (char *)(packed_data+16),((time_len)));
	printf("time check %02x,%02x,%02x\r\n",packed_data[16],packed_data[17],packed_data[18]);
	*/
	//----to BCD
	Str2BCD(md5_value, md5_hex,data_len+time_len);
	Uptolow(md5_value, (data_len+time_len)*2);
	//MD5-KEY
	memcpy(((char *)md5_value+((data_len+time_len)*2)),(char *)(SkySimDevKey),strlen(SkySimDevKey));
	printf("md5 value is %s \r\n", md5_value);
	printf("start md5--2\r\n");
	
	//md5
	md5(md5_value, (data_len+time_len)*2+strlen(SkySimDevKey));
	printf("md5_value--- is :%02x \r\n",md5_value[16]);
	printf("md5_value--- is :%02x \r\n",md5_value[17]);
	printf("md5_value--- is :%02x \r\n",md5_value[18]);
	md5_pack((packed_data+index));
	printf("md5 is %02x \r\n",(packed_data[index]));
	printf("md5 is %02x \r\n",(packed_data[index +1]));
	printf("md5 is %02x \r\n",(packed_data[index+2]));
	printf("md5 is %02x \r\n",(packed_data[index+3]));

	index += 16;
	//package -> bsd
	
	printf("packed _data is :%s \r\n",packed_data);
	
	Str2BCD(bsd_data, (char *)(packed_data),pack_len+2);
	
	return (pack_len+2)*2;
}
int get_value(long int* Rx, long int* Tx, char *buf)
{
	int index = 0;
	char temp[20] = {'\0'};
	int num_len = 0;
	int return_value = 0;
	printf("buf is %c\r\n",*buf);
	while(*(buf+index) != '\0')
	{
		if(*(buf+index) == 'R')
		{
			printf("find R\r\n");
			index += 8;
			while(('0'-1)<*(buf + index) && *(buf + index)<('9'+1))
			{
				temp[num_len] = buf[index];
				num_len++;
				index++;
			}
			*Rx = atol(temp);
			printf("Rx is %ld\r\n",*Rx);
			memset(temp,'\0',20);
			num_len = 0;
			return_value++;
			continue;
		}
		else if(*(buf+index) == 'T')
                {
                        index += 8;
                        while(('0'-1)<*(buf+index) && *(buf+index)<('9'+1))
                        {
                                temp[num_len] = *(buf + index);
                                num_len++;
                                index++;
                        }
			*Tx = atol(temp);
			printf("Tx is %ld\r\n",*Tx);
			memset(temp,'\0',20);
			num_len = 0;
			return_value++;
			continue;
                }
		printf("buf is %c\r\n",*(buf+index));
		index++;
	}
	return return_value;
}

int upload_data(unsigned char *packed_data, int data_len)
{
	int ret = 0;
	int sockfd,numbytes;
	unsigned char recv_data[512] = {'\0'};
    	struct sockaddr_in their_addr;
   	 printf("break!");
    	while((sockfd = socket(AF_INET,SOCK_STREAM,0)) == -1);
    	printf("socket creat success\n");
    	their_addr.sin_family = AF_INET;
    	their_addr.sin_port = htons(28100);
//	their_addr.sin_addr.s_addr=inet_addr("192.168.1.220");   
 	their_addr.sin_addr.s_addr=inet_addr("180.169.48.172");
    	bzero(&(their_addr.sin_zero), 8);
    	while(connect(sockfd,(struct sockaddr*)&their_addr,sizeof(struct sockaddr)) == -1);
	printf("connect success\r\n");
	ret = send(sockfd, packed_data, data_len, 0);
	if(ret < 0)
	{
		printf("send error\r\n");
		close(sockfd);
		return -1;
	}
	ret = recv(sockfd, recv_data, 512,0);
	if(ret < 0)
	{
		printf("recv error\r\n");
		close(sockfd);
		return -2;
	}
	else
	{
		printf("recv_len is %d -- recv_data is %02x %02x \r\n",ret,recv_data[2],recv_data[3]);
	}
	close(sockfd);
	return 0;
}	



int main()
{
	int fd = -1;
	char read_buf[256] = {0};
	int ret = -1;
	fd = open("//root//upload",O_RDWR);
	long int Rx = 0;
	long int Tx = 0;
	int judge = 0;
	//test
	int i = 0;
	int j = 0;
	//pack
	unsigned char flag1 = 0xd0;
	unsigned char *device_id = (unsigned char *)("1122330044556677");
	unsigned char cmd1 = 0xa1;
	unsigned char cmd2 = 0xa1;
	unsigned char data[12] = {"DD030004"};
	unsigned char packed_data[512] = {'\0'};

	if(-1 == fd)
	{
		printf("file open failed\r\n");
		return -1;	
	}
	ret = read(fd,read_buf,sizeof(read_buf));
	printf("ret is %d \r\n",ret);
	if(ret < 0)
	{
		printf("file read error\r\n");
		close(fd);
		return -2;
	}
	printf("buf is :");
	while(read_buf[judge] != '\0')
	{
		printf("%c",read_buf[judge]);
		judge++;
	}
	printf("\r\nend\r\n");
	ret = get_value(&Rx,&Tx,read_buf);
	if(ret != 2)
	{
		printf("get value error---%d\r\n",ret);
		close(fd);
		return -3;
	}
	close(fd);
	sprintf(data+8,"%08x",Rx+Tx);
	printf("data is %s \r\n",data );
	j = pack_data(flag1,device_id,cmd1,cmd2, data, packed_data);
	printf("j = %d\r\n",j);
	printf("packed_data is : %s\r\n",packed_data);	
	printf("md5: %s\r\n",(packed_data));
	printf(" end \r\n");
	//upload data
	Uptolow(packed_data,j);
	ret = upload_data(packed_data, j);
	if(ret < 0)
	{
		printf("upload error\r\n");
	}
	return 0;
}

