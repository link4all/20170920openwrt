//////////////////////////////////////////////////////////////////////////
// file name: Comm
// Author:wyb
// date: 20160104

#include <stdio.h>
#include <fcntl.h>  
#include <sys/types.h> 
#include <sys/select.h> 
#include <netdb.h> 
#include <string.h> 
#include <errno.h> 
#include <unistd.h>  

#include "Comm.h"

//=====================================================
// 关闭串口
void     close_port( int  nPort){
    
	close( nPort );
}
//=====================================================
// 打开串口
// strPort: 串口名
// speed: 波特率
// 返回值:  0:成功   -1:失败
int        open_port( char   *strPort, speed_t  sBaudrate ){
    
    int        fd = -1;  
    
    fd = open(strPort,O_RDWR|O_NOCTTY| O_NDELAY| O_NDELAY);//以非阻塞模式打开串口
    if (fd == -1) {
		return fd;
    }
    else{
         fcntl(fd, F_SETFL, 0);         //非阻塞状态时使用  
         init_tty(fd, sBaudrate);   
    }   
    return  fd;
}
//=====================================================
//设置窗口参数:9600速率 =B9600
void init_tty(int fPort, speed_t  sBaudrate) 
{     
    //声明设置串口的结构体 
    struct termios option;

    //先清空该结构体
    bzero( &option, sizeof(option));
    //    cfmakeraw()设置终端属性，就是设置termios结构中的各个参数。
    cfmakeraw(&option);
    //设置波特率 
    cfsetispeed(&option, sBaudrate); 
    cfsetospeed(&option, sBaudrate); 
    //CLOCAL和CREAD分别用于本地连接和接受使能，因此，首先要通过位掩码的方式激活这两个选项。
    option.c_cflag |= CLOCAL | CREAD;
    //通过掩码设置数据位为8位
    option.c_cflag &= ~CSIZE;
    option.c_cflag |= CS8; 
    //设置无奇偶校验
    option.c_cflag &= ~PARENB; 
    //一位停止位 
    option.c_cflag &= ~CSTOPB; 
    tcflush(fPort,TCIFLUSH); 
    // 可设置接收字符和等待时间，无特殊要求可以将其设置为0 
    option.c_cc[VTIME] = 20;   //超时2秒
    option.c_cc[VMIN] = 0; //最小接收字符数 
    // 用于清空输入/输出缓冲区 
    tcflush (fPort, TCIOFLUSH); 
    //完成配置后，可以使用以下函数激活串口设置 
    if(tcsetattr(fPort,TCSANOW,&option) ){ 
		//printf("Setting the serial1 failed!\n");
        perror("serial:");
    }
}
//=====================================================
//   接收数据
short      recv_data( int      fComPort,  unsigned  char   *pData,  unsigned  short   nMaxLen ){
    
	short        nResultLen = 0;
	
	nResultLen = read( fComPort, pData,  nMaxLen );
	return  nResultLen;
}
//=====================================================
//  发送数据
short       send_data( int      fComPort,  unsigned  char   *pData,  unsigned  short   nLen ){
    
    unsigned char  nCount = 0;
    short          nTmpLen=0;
    short          nResult = 0;

    while(  nResult < nLen ){                
        nResult = write( fComPort, pData+nTmpLen, nLen-nTmpLen );
        if( nResult <= 0  ){
            if( nResult == - 1 ){
				printf("Comm Send Eror\r\n");
                break;
            }
            if( nCount++ > 10 ){
				printf("Send Time Out\r\n");
                break;
            }
            // 10毫秒
            usleep( 10000 );
        }
        nTmpLen += nResult;
    }
    return  nResult;
}