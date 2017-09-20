#include "main.h"
#include "Comm.h"
#include "Thread.h"
#include <stdio.h>
#include <string.h>


//=======================================================
// 4G模块结构
STTTYCOMDATA       g_stTtyUSB0Data;

//=======================================================
// GPS数据结构
STTTYCOMDATA         g_stTtyUSB1Data;     

//=======================================================
//终端设备结构
STTTYCOMDATA       g_stTtyS0Data;     

//=======================================================
// UDP/TCP连接
STTTYCOMDATA        g_stSocketData;       

//=======================================================
// 综合参数
STWIFISTATUS         g_stWIFIStatus;

char					     g_strGPRMC[GPS_MAXBUF_LEN];			//GPRMC数据		
char						 g_strGPGGA[GPS_MAXBUF_LEN];			  //GPGGA数据

//=======================================================
//GPS命令数据
const 	char		 	*s_strGPSCMD[] = {
					"$GPRMC,",
					"$GPGGA,"
};

//=======================================================
//  初始化值
void   InitState( void ){
       
	//ttyUSB0 init
    g_stTtyUSB0Data.m_nEvent = 0;
    g_stTtyUSB0Data.m_nComPort = -1;
    g_stTtyUSB0Data.m_nBack = 0;
    g_stTtyUSB0Data.m_nFront = 0;
    memset( g_stTtyUSB0Data.m_nBuf, 0x00, MAXBUF_RECV );
	
	//ttyUSB1 init
	 g_stTtyUSB1Data.m_nEvent = 0;
    g_stTtyUSB1Data.m_nComPort = -1;
    g_stTtyUSB1Data.m_nBack = 0;
    g_stTtyUSB1Data.m_nFront = 0;
    memset( g_stTtyUSB1Data.m_nBuf, 0x00, MAXBUF_RECV );
	memset( g_strGPRMC, 0x00, GPS_MAXBUF_LEN );
	memset( g_strGPGGA, 0x00, GPS_MAXBUF_LEN);

	//ttyS0 init
    g_stTtyS0Data.m_nEvent = 0;
    g_stTtyS0Data.m_nComPort = -1;
    g_stTtyS0Data.m_nBack = 0;
    g_stTtyUSB0Data.m_nFront = 0;
    memset( g_stTtyS0Data.m_nBuf, 0x00, MAXBUF_RECV );

    //初始化互斥锁
    pthread_mutex_init(&g_stTtyUSB0Data.m_nMutex, NULL);  
    pthread_cond_init(&g_stTtyUSB0Data.m_nCond , NULL);  
	
	//初始化互斥锁
    pthread_mutex_init(&g_stTtyUSB1Data.m_nMutex, NULL);  
    pthread_cond_init(&g_stTtyUSB1Data.m_nCond , NULL);  

    //初始化条件变量
    pthread_mutex_init(&g_stTtyS0Data.m_nMutex, NULL);  
    pthread_cond_init(&g_stTtyS0Data.m_nCond , NULL);  
        
    // BIT0:  ttyUSB0   1/0   开启/关闭
    // BIT1:  ttyS0     1/0   开启/关闭
    // BIT2:  网络      1/0   Socket连接/Socket断开		
    // BIT3:  TCP/UDP   1/0   Socket工作/Socket不工作
	//BIT6:  ttyUSB1 1/0  开启／关闭
    g_stWIFIStatus.m_nFlag = 0;
    g_stWIFIStatus.m_nServerPort = 8868;
    strcpy( g_stWIFIStatus.m_nServerIP , "192.168.1.112");//"203.86.9.28");
    memset( g_stWIFIStatus.m_strServerDomain, 0x00, SERVERDOMAIN_LENGTH);
    
    g_stTtyUSB0Data.m_pThreadRecv = 0;
    g_stTtyUSB0Data.m_pThreadSend= 0;
    
    g_stTtyUSB1Data.m_pThreadRecv = 0;
    g_stTtyUSB1Data.m_pThreadSend= 0;
	
    g_stTtyS0Data.m_pThreadRecv = 0; 
    g_stTtyS0Data.m_pThreadSend= 0;
    
    g_stSocketData.m_pThreadRecv = 0; 
    g_stSocketData.m_pThreadSend= 0;
}
//=======================================================
//   释放对像
void  Destroy_memory( void ){

    //线程/互斥锁/初始化条件变量
    //ttySUB0
    if( g_stTtyUSB0Data.m_nComPort != -1 ){
        close_port( g_stTtyUSB0Data.m_nComPort ); 
    }
    pthread_mutex_destroy( &g_stTtyUSB0Data.m_nMutex);
    pthread_cond_destroy( &g_stTtyUSB0Data.m_nCond  ); 
	
	 //ttySUB1
    if( g_stTtyUSB1Data.m_nComPort != -1 ){
        close_port( g_stTtyUSB1Data.m_nComPort ); 
    }
    pthread_mutex_destroy( &g_stTtyUSB0Data.m_nMutex);
    pthread_cond_destroy( &g_stTtyUSB0Data.m_nCond  ); 

    //ttyS0
    if( g_stTtyS0Data.m_nComPort != -1 ){
        close_port( g_stTtyS0Data.m_nComPort ); 
    }
    pthread_mutex_destroy( &g_stTtyS0Data.m_nMutex);
    pthread_cond_destroy( &g_stTtyS0Data.m_nCond  ); 
    if( g_stWIFIStatus.m_hSocket != -1 ){
        close( g_stWIFIStatus.m_hSocket );
    }
}
//=======================================================
//
unsigned char     SaveTtyUSB0Data( unsigned char *pData,  unsigned  short  nLen ){
        
        unsigned char            nResult = 0;
        unsigned short           nCnt = 0;
        unsigned char            nTemp = 0;

       //printf("USB0:DataLen:%d %s\r\n", nLen, pData );
        pthread_mutex_lock( &g_stTtyUSB0Data.m_nMutex );
        for( nCnt = 0; nCnt < nLen; nCnt++  ){
			nTemp = pData[nCnt];
			g_stTtyUSB0Data.m_nBuf[g_stTtyUSB0Data.m_nFront] = nTemp;
			g_stTtyUSB0Data.m_nFront++;            
			if( g_stTtyUSB0Data.m_nFront >= MAXBUF_RECV ){
					g_stTtyUSB0Data.m_nFront = 0;
			}
        }
		AddUSB0Event();
        pthread_cond_signal(&g_stTtyUSB0Data.m_nCond);
        pthread_mutex_unlock(&g_stTtyUSB0Data.m_nMutex );
        return nResult;
}
///////////////////////////////////////////////////////////
//  读取指令集数据
int GetTtyUSB0Data(unsigned char *pBuf, unsigned short nDataLen) {

    unsigned char       nTemp = 0;
    unsigned char       bFlag = 0;
    unsigned short      nLen = 0;

    pthread_mutex_lock( &g_stTtyUSB0Data.m_nMutex );
    while( 1 ){          
            if( g_stTtyUSB0Data.m_nBack != g_stTtyUSB0Data.m_nFront ){ 
                   
                nTemp = g_stTtyUSB0Data.m_nBuf[g_stTtyUSB0Data.m_nBack];
                g_stTtyUSB0Data.m_nBack++;
                *(pBuf+nLen) = nTemp;
                nLen++;
                if( nLen >= nDataLen ){
                    bFlag = 1;
                    break;	
                }
                if( g_stTtyUSB0Data.m_nBack >= MAXBUF_RECV ){
                    g_stTtyUSB0Data.m_nBack = 0;
                }
            }
            else {
                bFlag = 1;
                break;
            }
    }
    pthread_mutex_unlock(&g_stTtyUSB0Data.m_nMutex );
    if( bFlag == 0 ){
        *pBuf = 0x00;
    }
    else{
        *(pBuf+nLen) = 0x00;
    }
    return nLen;
}
//=======================================================
//
unsigned char     SaveTtyUSB1Data( unsigned char *pData,  unsigned  short  nLen ){
        
    unsigned char            nResult = 0;
    unsigned short            nCnt = 0;
    unsigned char            nTemp = 0;
    static unsigned char  nPre = 0;

    //printf("USB1:DataLen:%d %s", nLen, pData );
    pthread_mutex_lock( &g_stTtyUSB1Data.m_nMutex );
    for( nCnt = 0; nCnt < nLen; nCnt++  ){

        nTemp = pData[nCnt];
        g_stTtyUSB1Data.m_nBuf[g_stTtyUSB1Data.m_nFront] = nTemp;
        g_stTtyUSB1Data.m_nFront++;
        if( (nTemp == 0x0A) && (nPre == 0x0D) ){
            AddUSB1Event();
            nResult = 1;
        }
        nPre = nTemp;
        if( g_stTtyUSB1Data.m_nFront >= MAXBUF_RECV ){
            g_stTtyUSB1Data.m_nFront = 0;
        }
    }
    if( nResult == 1 ){
        pthread_cond_signal( &g_stTtyUSB1Data.m_nCond );
    }
    pthread_mutex_unlock(&g_stTtyUSB1Data.m_nMutex );
    return nResult;
}
///////////////////////////////////////////////////////////
//  读取指令集数据
int GetTtyUSB1Data(unsigned char *pBuf, unsigned short nDataLen) {

    unsigned char       nPre = 0;
    unsigned char       nTemp = 0;
    unsigned char       bFlag = 0;
    unsigned short      nLen = 0;

    pthread_mutex_lock( &g_stTtyUSB1Data.m_nMutex );
    while( 1 ){          
        nPre = nTemp;  
        if( g_stTtyUSB1Data.m_nBack != g_stTtyUSB1Data.m_nFront ){ 
           
            nTemp = g_stTtyUSB1Data.m_nBuf[g_stTtyUSB1Data.m_nBack];
            g_stTtyUSB1Data.m_nBack++;	
            *(pBuf+nLen) = nTemp;
            nLen++;
            if( (nTemp == 0x0A) && (nPre == 0x0D) )	 {
                bFlag = 1;
                break;
            } 
            if( nLen >= nDataLen ){
                bFlag = 1;
                break;	
            }
            if( g_stTtyUSB1Data.m_nBack >= MAXBUF_RECV ){
                g_stTtyUSB1Data.m_nBack = 0;
            }   
        }
        else {
            bFlag = 0;
            break;
        }
    }
    pthread_mutex_unlock(&g_stTtyUSB1Data.m_nMutex );
    if( bFlag == 0 ){
        *pBuf = 0x00;
    }
    else{
        *(pBuf+nLen) = 0x00;
    }
    return nLen;
}
//=======================================================
//获取是哪一种数据格式
//返回类型
unsigned char  GPS_GetCmdType( unsigned char  *pMsg ){
	
		unsigned  char	nCnt = 0;
		unsigned  char   nLen = 0;
		
		for( nCnt = 0; nCnt < GPS_CMD_END; nCnt++ ){
				nLen = strlen( (char*) s_strGPSCMD[nCnt]);
				if( memcmp(pMsg, s_strGPSCMD[nCnt], nLen) == 0 ){
						break;
				}
		}
		return nCnt;
}
//=======================================================
//
unsigned char     SaveTtyS0Data( unsigned char *pData,  unsigned  short  nLen ){
        
    unsigned char            nResult = 0;
    unsigned short            nCnt = 0;
    unsigned char            nTemp = 0;
    static unsigned char  nPre = 0;

    //printf("S0:DataLen:%d %s", nLen, pData );
    pthread_mutex_lock( &g_stTtyS0Data.m_nMutex );
    for( nCnt = 0; nCnt < nLen; nCnt++  ){

        nTemp = pData[nCnt];
        //printf("%02X ", nTemp );
        g_stTtyS0Data.m_nBuf[g_stTtyS0Data.m_nFront] = nTemp;
        g_stTtyS0Data.m_nFront++;
        if( (nTemp == 0x0A) && (nPre == 0x0D) ){
            AddS0Event();
            nResult = 1;
        }
        nPre = nTemp;
        if( g_stTtyS0Data.m_nFront >= MAXBUF_RECV ){
            g_stTtyS0Data.m_nFront = 0;
        }
    }
    if( nResult == 1 ){
        pthread_cond_signal( &g_stTtyS0Data.m_nCond );
    }
    pthread_mutex_unlock(&g_stTtyS0Data.m_nMutex );
    return nResult;
}
///////////////////////////////////////////////////////////
//  读取指令集数据
int     GetTtyS0Data(unsigned char *pBuf, unsigned short nDataLen) {

    unsigned char       nPre = 0;
    unsigned char       nTemp = 0;
    unsigned char       bFlag = 0;
    unsigned short      nLen = 0;

    pthread_mutex_lock( &g_stTtyS0Data.m_nMutex );
    while( 1 ){          
        nPre = nTemp;  
        if( g_stTtyS0Data.m_nBack != g_stTtyS0Data.m_nFront ){ 
           
            nTemp = g_stTtyS0Data.m_nBuf[g_stTtyS0Data.m_nBack];
            g_stTtyS0Data.m_nBack++;	
            *(pBuf+nLen) = nTemp;
            nLen++;
            if( (nTemp == 0x0A) && (nPre == 0x0D) )	 {
                // 去掉0x0d,0x0a
                //nLen -= 2;
                bFlag = 1;
                break;
            } 
            if( nLen >= nDataLen ){
                bFlag = 1;
                break;	
            }
            if( g_stTtyS0Data.m_nBack >= MAXBUF_RECV ){
                g_stTtyS0Data.m_nBack = 0;
            }   
        }
        else {
            bFlag = 0;
            break;
        }
    }
    pthread_mutex_unlock(&g_stTtyS0Data.m_nMutex );
    if( bFlag == 0 ){
        *pBuf = 0x00;
    }
    else{
        *(pBuf+nLen) = 0x00;
    }
    return nLen;
}
//=======================================================
//  初始化串口
void             InitUSB0Port( void ){
      
    if( g_stTtyUSB0Data.m_nComPort  != -1 ){
        close_port( g_stTtyUSB0Data.m_nComPort ); 
    }
    g_stTtyUSB0Data.m_nComPort = open_port( C_PORT_TTYUSB0, C_USB0_BAUDRATE );
    if( g_stTtyUSB0Data.m_nComPort == -1 ){
        SetttyUSB0Close();
        printf("%s Fail\r\n",C_PORT_TTYUSB0 );
    }
    else{
         printf("%s Success\r\n",C_PORT_TTYUSB0);
         SetttyUSB0Open();
         InitThreadUSB0();
    }	
}
//=======================================================
//   ttyUSB1串口初始化
void 			InitUSB1Port( void ){
	
	// ttyUSB1串口初始化
	if( g_stTtyUSB1Data.m_nComPort  != -1 ){
        close_port( g_stTtyUSB1Data.m_nComPort ); 
    }
    g_stTtyUSB1Data.m_nComPort = open_port( C_PORT_TTYUSB1, C_USB1_BAUDRATE );
    if( g_stTtyUSB1Data.m_nComPort == -1 ){
        SetttyUSB1Close();
        printf("%s Fail\r\n",C_PORT_TTYUSB1 );
    }
    else{
         printf("%s Success\r\n",C_PORT_TTYUSB1);
         SetttyUSB1Open();
         InitThreadUSB1();
    }
}
//=======================================================
//  初始化串口
void             InitS0Port( void ){
    
    if( g_stTtyS0Data.m_nComPort != - 1 ){
        close_port( g_stTtyS0Data.m_nComPort );
    }
    g_stTtyS0Data.m_nComPort = open_port( C_PORT_TTYS0, C_S0_BAUDRATE );
    if( g_stTtyS0Data.m_nComPort == -1 ){
        SetttyS0Close();
        printf("%s Fail\r\n",C_PORT_TTYS0 );
    } 
    else{
        SetttyS0Open();
        printf("%s Success\r\n",C_PORT_TTYS0 );
        InitThreadS0();
    }
}
//=======================================================
// 初始化ttyUSB0线程
void    InitThreadUSB0( void ){
    
	printf("InitThreadUSB0\r\n");
    if( IsttyUSB0Status() ){        
         if( g_stTtyUSB0Data.m_pThreadRecv > 0 ){
             pthread_cancel( g_stTtyUSB0Data.m_pThreadRecv );
             g_stTtyUSB0Data.m_pThreadRecv = 0;
         }   
        if( pthread_create(&g_stTtyUSB0Data.m_pThreadRecv ,NULL,ThreadttyUSB0Recvice, &g_stTtyUSB0Data.m_nComPort ) != 0){
            printf("Thread Create USB0Recv Fail\r\n");
        }
		
         if( g_stTtyUSB0Data.m_pThreadSend > 0 ){			 
             pthread_cancel( g_stTtyUSB0Data.m_pThreadSend );
             g_stTtyUSB0Data.m_pThreadSend = 0;
         }
        if( pthread_create(&g_stTtyUSB0Data.m_pThreadSend ,NULL,ThreadttyUSB0Send, &g_stTtyUSB0Data.m_nComPort ) != 0){
            printf("Thread Create USB0Send Fail\r\n");
        }
    }
}
//=======================================================
// 初始化ttyUSB0线程
void    InitThreadUSB1( void ){
	
    printf("InitThreadUSB1\r\n");
    if( IsttyUSB1Status() ){        
         if( g_stTtyUSB1Data.m_pThreadRecv > 0 ){
             pthread_cancel( g_stTtyUSB1Data.m_pThreadRecv );
             g_stTtyUSB1Data.m_pThreadRecv = 0;
         }   
        if( pthread_create(&g_stTtyUSB1Data.m_pThreadRecv ,NULL,ThreadttyUSB1Recvice, &g_stTtyUSB1Data.m_nComPort ) != 0){
            printf("Thread Create USB1Recv Fail\r\n");
        }
		
         if( g_stTtyUSB1Data.m_pThreadSend > 0 ){
             pthread_cancel( g_stTtyUSB1Data.m_pThreadSend );
             g_stTtyUSB1Data.m_pThreadSend = 0;
         }
        if( pthread_create(&g_stTtyUSB1Data.m_pThreadSend ,NULL,ThreadttyUSB1Send, &g_stTtyUSB1Data.m_nComPort ) != 0){
            printf("Thread Create USB1Send Fail\r\n");
        }
    }
}
//=======================================================
// 初始化ttyS0线程
void    InitThreadS0( void ){
    
		printf("InitThreadS0\r\n");
        if( IsttyS0Status() ){  
             if( g_stTtyS0Data.m_pThreadRecv > 0 ){
                 pthread_cancel( g_stTtyS0Data.m_pThreadRecv );
                 g_stTtyS0Data.m_pThreadRecv = 0;
            }
            if( pthread_create(&g_stTtyS0Data.m_pThreadRecv ,NULL,ThreadttyS0Recvice, &g_stTtyS0Data.m_nComPort ) != 0){
                printf("Thread Create S0 Recv Fail\r\n");
            }
            if( g_stTtyS0Data.m_pThreadSend > 0 ){
                 pthread_cancel( g_stTtyS0Data.m_pThreadSend );
                 g_stTtyS0Data.m_pThreadSend = 0;
            }
            if( pthread_create(&g_stTtyS0Data.m_pThreadSend ,NULL,ThreadttyS0Send, &g_stTtyS0Data.m_nComPort ) != 0){
                printf("Thread Create  S0 Send Fail\r\n");
            }
        }
}
//=======================================================
//  线程初始化
void    InitThreadSocket( void ){
    
		printf("InitThreadSocket\r\n");
        if( IsTCPCommMode() ){
            if(  g_stSocketData.m_pThreadRecv > 0 ){
                 pthread_cancel( g_stSocketData.m_pThreadRecv );
                 g_stSocketData.m_pThreadRecv = 0;
            }
            if( pthread_create(&g_stSocketData.m_pThreadRecv ,NULL,ThreadTCPSocket, NULL ) != 0 ){
                printf("Socket TCP Thread Fail\r\n");
            }
        }
        else{
            if(  g_stSocketData.m_pThreadRecv > 0 ){
                pthread_cancel( g_stSocketData.m_pThreadRecv );
                g_stSocketData.m_pThreadRecv = 0;
            }
            if( pthread_create(&g_stSocketData.m_pThreadRecv ,NULL,ThreadUDPSocket, NULL ) != 0 ){
                printf("Socket UDP Thread Fail\r\n");
            }
        }
}
//=======================================================
//
int main(int argc, char **argv)
{
    unsigned char   nUSB0Cnt = 0;
    unsigned char   nUSB1Cnt = 0;
    unsigned char   nS0Cnt = 0;
	unsigned char   nChkGPSFlag = 0;
    
    InitState();           //初始化变'
    InitUSB0Port();     //初始化串口
    InitUSB1Port();     //初始化串口
    InitS0Port();        //初始化串口
    
    while( 1 ){        
        // 维护 ttyUSB0
        if( !IsttyUSB0Status() ){
                if( nUSB0Cnt++ >= CHK_TIME_SPACE ){
                    nUSB0Cnt = 0;
                    InitUSB0Port();
                }
        }
		else{
				nUSB0Cnt = 0;
		}
		// 维护 ttyUSB1
        if( !IsttyUSB1Status() ){
                if( nUSB1Cnt++ >= CHK_TIME_SPACE ){
                    nUSB1Cnt = 0;
                    InitUSB1Port();
                }
        }
		else{
				nUSB1Cnt = 0;
		}
        // 维护 ttyS0
        if( !IsttyS0Status() ){
                if( nS0Cnt++ >= CHK_TIME_SPACE  ){
                    nS0Cnt = 0;
                    InitS0Port();
                }
        } 
		else{
				nS0Cnt = 0;
		}
        // socket 维护
        if(  IsNeedSocketConnect()  ){
              ClrNeedSocketConnect();
              InitThreadSocket();
        }
		// 检测ttyUSB1口是否有数据输出,20秒检测一次
		if(  (nChkGPSFlag++ >= 20)  ){
				nChkGPSFlag = 0;				
				if( IsGPSDataFlag() ){
					ClrGPSDataFlag();
				}
		}
		// exit APP
		if( IsExitAPP() ){
			  break;
		}
        //printf("Main Thread Manage\r\n");
        sleep( 1 );
    }
    Destroy_memory();
    return 0;
}
