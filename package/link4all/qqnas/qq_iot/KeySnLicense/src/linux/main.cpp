#include "hashmd5.h"
#include "SSLKernelItem.h"

#include <stdio.h>
#include <string.h>
#include <fcntl.h>
#include <sys/types.h>
#include<stdlib.h>
#include <unistd.h>



 char* get_mac(){
	int fd;
	FILE *fd2;
	unsigned char *buf; 
	buf = (unsigned char *)malloc(6);
	char *buf2; 
	buf2 = (char *)malloc(16);
	fd = open("/dev/mtd2", O_RDWR | O_SYNC);
	if (fd < 0) {
		fprintf(stderr, "failed to open mtd2\n");
	}
  	//read-----------
  	lseek(fd, 4, SEEK_SET);
	//backup
	if (read(fd, buf,6 ) != 6) {
		fprintf(stderr, "failed to read 6 bytes from mtd2\n");
		close(fd);
	}
	printf("macid is:%02X%02X%02X%02X%02X%02X\n",buf[0],buf[1],buf[2],buf[3],buf[4],buf[5]);
	sprintf(buf2,"l4a-%02X%02X%02X%02X%02X%02X",buf[0],buf[1],buf[2],buf[3],buf[4],buf[5]);
	printf("%s\n",buf2);
	fd2 = fopen("/etc/qqiot/save/GUID_file.txt", "w+");
	if (fprintf(fd2,"%s",buf2)!=16) {
		fprintf(stderr, "failed to read 16 bytes from mtd2\n");
		}
	close(fd);
	fclose(fd2);
	free(buf);
	return buf2;
}


int main()
{
	char *buf;
	buf = ( char *)malloc(6);
	buf=get_mac();
	ECDSASignBufferBase16ToLicenceFile("/etc/qqiot/ec_key.pem", buf, strlen(buf), "/etc/qqiot/save/licence.sign.file.txt");
	// 根据公钥文件public.pem，验证guid.txt中的sn和license.txt是不是匹配
	int nRet = ECDSAVerifyBase16LicenceFile("/etc/qqiot/public.pem", "/etc/qqiot/save/GUID_file.txt", "/etc/qqiot/save/licence.sign.file.txt");
	if(nRet == 1)
	{
		printf("验证成功\n", nRet);
	}
	else 
	{
		printf("验证失败，错误码[%d]\n", nRet);
	}
	//remove("/etc/qqiot/ec_key.pem");
	return 0;
}
