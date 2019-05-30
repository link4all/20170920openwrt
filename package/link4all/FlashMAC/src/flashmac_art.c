/*
 * flash MAC  
 * Copyright (C) 2014 WRTnode machine team.
 * This program is free software; you can redistribute it and/or modify
 *
 * Cross-compile with cross-gcc -I/path/to/cross-kernel/include
 */

#include <stdio.h>             
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>
#include <sys/ioctl.h>
#include <sys/types.h>
#include <unistd.h>
#include <stdint.h>
#define MEMERASE		_IOW('M', 2, struct erase_info_user)

struct erase_info_user {
		uint32_t start;
		uint32_t length;
};

char * find_partition(char *pname){
	FILE *fp;		//文件指针	
	pname=(unsigned char *)malloc(32)//存储字符串的数组
	int	line=0;		
	char file_str[1024];
	fp=fopen("/proc/mtd","r");//创建的文件
	if(fp==NULL)
	{
		printf("open error\n");
		return -1;
	}
	while(fgets(file_str,sizeof(file_str),fp))//逐行循环读取文件，直到文件结束 
	{
		line++;
		if(strstr(file_str,pname))  //检查字符串是否在该行中，如果在，则输出该行
		{
			printf("%s in %d :%s\n",find_str,line,file_str);
			// fclose(fp);
			// return 0;
		}
	}
	fclose(fp);//关闭文件，结束
	return ;

}
int main(int argc,char *argv[])
{
	int fd,sz,i,offset,offset0,offset1,offset2,offset3,offset4,offset5,k;
	int mac[6];
	sz = 0x10000;
	offset0 = 0x02;
	// offset1 = 0x28;
	// offset2 = 0x2E;
	// offset3 = 0xf4; //晶振
	// offset4 = 0x58;  //tx0 power
	// offset5 = 0x5E; //tx0 power
	unsigned char *buf;
	buf = (unsigned char *)malloc(sz);
fd = open("/dev/mtd2", O_RDWR | O_SYNC);
	if (fd < 0) {
		fprintf(stderr, "failed to open mtd2\n");
		free(buf);
		return -1;
	}
  	//read-----------
  	lseek(fd, 0, SEEK_SET);
	//backup
	if (read(fd, buf, sz) != sz) {
		fprintf(stderr, "failed to read %d bytes from mtd2\n",
				sz);
		free(buf);
		close(fd);
		return -1;
	}
	//erase
	struct erase_info_user ei;
	lseek(fd, 0, SEEK_SET);
	ei.start = 0;
	ei.length = sz;
	if (ioctl(fd, MEMERASE, &ei) < 0) {
		fprintf(stderr, "failed to erase mtd2\n");
		free(buf);
		close(fd);
		return -1;
	}

if (strcmp(argv[1],"x") == 0){
printf("Set crystal value\n");
int crystal;
crystal=strtol(argv[2], NULL, 16);
*(buf + (offset3)) = crystal;
	//write
	lseek(fd, 0, SEEK_SET);
 	if (write(fd, buf, sz) == -1) {
		fprintf(stderr, "failed to write mtd%d\n", i);
		free(buf);
		close(fd);
		return -1;
	}
	free(buf);
	close(fd);
}
else if (strcmp(argv[1],"p") == 0){
printf("Set power value\n");
int power[2];
power[0]=strtol(argv[2], NULL, 16);
power[1]=strtol(argv[3], NULL, 16);
*(buf + (offset4)) = power[0];
*(buf + (offset5)) = power[1];
	//write
	lseek(fd, 0, SEEK_SET);
 	if (write(fd, buf, sz) == -1) {
		fprintf(stderr, "failed to write mtd%d\n", i);
		free(buf);
		close(fd);
		return -1;
	}
	free(buf);
	close(fd);
}
else{
printf("Set mac value\n");
	for(i=0;i<6;i++){
		mac[i] = strtol(argv[i+1], NULL, 16);
	}
	if(mac[0]%4 !=0)
	{
		printf("ple input a effective MAC\n");
		return -1;
	}

	for(k=0;k<3;k++){
		if(k==0)
			offset=offset0;
		if(k==1){
			offset=offset1;
			mac[5] +=1;
		}
		if(k==2){
			offset=offset2;
			mac[5] -=1;
		}
		for(i=0;i<6;i++){
			*(buf + (offset) + i) = mac[i];
		}
	}

	//write
	lseek(fd, 0, SEEK_SET);
 	if (write(fd, buf, sz) == -1) {
		fprintf(stderr, "failed to write mtd%d\n", i);
		free(buf);
		close(fd);
		return -1;
	}
	free(buf);
	close(fd);
}
	return 0;
}
