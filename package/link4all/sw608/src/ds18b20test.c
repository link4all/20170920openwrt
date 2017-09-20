#include <stdio.h>
#include <curses.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/ioctl.h>


int main(int argc, char **argv)
{
	int fd;
	unsigned int temp = 0;
	float t;
	/* 1.打开设备节点 */
	fd = open("/dev/ds18b20", O_RDWR | O_NONBLOCK);
	if (fd < 0)
	{
		printf("can't open!\n");
		return -1;
	}
	read(fd,&temp,sizeof(temp));
	t=temp*0.0625;
	printf("temp = %d,--->%f<---\n",temp,t);
	return 0;
}
