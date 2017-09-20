//////////////////////////////////////////////////////////////////////////
// file name: Thread.h
// Author:wyb
// date: 20160105
#include <stdio.h>
#include <string.h>
#include "Thread.h"
#include "main.h"
#include "Protocol.h"
#include "Comm.h"

//==================================================
//  发送模块数据线程
void    *ThreadttyUSB0Send( void  *lpVoid ){

    unsigned char           nLen = 0;
    unsigned char           chBuf[255];

    //printf("ThreadttyUSB0Send\r\n");
    lpVoid = lpVoid;
    while( 1 ){
        if( g_stTtyUSB0Data.m_nComPort == - 1 ){ 
            break;
        } 
        pthread_mutex_lock( &g_stTtyUSB0Data.m_nMutex );
        pthread_cond_wait( &g_stTtyUSB0Data.m_nCond, &g_stTtyUSB0Data.m_nMutex );
        pthread_mutex_unlock(&g_stTtyUSB0Data.m_nMutex);
        // 收到4G模块完整数据
        while( GetUSB0Event() ){
            DecUSB0Event();
            nLen = GetTtyUSB0Data( chBuf, 255 );
            if( nLen > 0 ){
                // 解释数据发送数据
				if( send_data( g_stTtyS0Data.m_nComPort,  chBuf,  nLen ) == -1  ){
					     SetttyS0Close();
						 close_port(g_stTtyS0Data.m_nComPort);
						 g_stTtyS0Data.m_nComPort = -1;
				}
            }
        }
    }	
    //printf("ThreadttyUSB0Send end\r\n");
    g_stTtyUSB0Data.m_pThreadSend = 0;
    pthread_exit(NULL);
    return  (void*)0;
}
//=======================================================
//  接收模块数据线程
void    *ThreadttyUSB0Recvice( void  *lpVoid ){
        
    short                 nLen = 0;
    unsigned char  chBuf[255];

    //printf("ThreadttyUSB0Recvice\r\n");
   // printf("Recv USB0\r\n");
    lpVoid = lpVoid;
    memset( chBuf, 0x00, 255);        
    while( 1 ){
        if( g_stTtyUSB0Data.m_nComPort == - 1 ){
            break;
        }
        nLen = recv_data( g_stTtyUSB0Data.m_nComPort, chBuf,  255 );
        if( nLen > 0 ){
            chBuf[nLen] = 0x00;
            SaveTtyUSB0Data( chBuf, nLen );
        }
        else{
            if( nLen == -1 ){ 
				SetttyUSB0Close(); 
				if( g_stTtyUSB0Data.m_nComPort  != -1 ){
					close_port(g_stTtyUSB0Data.m_nComPort );
					g_stTtyUSB0Data.m_nComPort  = -1;
				}
                break;
            }
        }
    }
	// 发送 USB0线程退出
	pthread_cond_signal(&g_stTtyUSB0Data.m_nCond);
   //printf("ThreadttyUSB0Recvice end\r\n");
    g_stTtyUSB0Data.m_pThreadRecv = 0;
    pthread_exit(NULL);
    return  (void*)0;
}

//==================================================
//  发送模块数据线程
void    *ThreadttyUSB1Send( void  *lpVoid ){

	unsigned char 			nCmdType = GPS_CMD_END;
    unsigned char           nLen = 0;
    unsigned char           chBuf[255];

    //printf("ThreadttyUSB1Send\r\n");
    lpVoid = lpVoid;
    while( 1 ){
        if( g_stTtyUSB1Data.m_nComPort == - 1 ){ 
            break;
        } 
        pthread_mutex_lock( &g_stTtyUSB1Data.m_nMutex );
        pthread_cond_wait( &g_stTtyUSB1Data.m_nCond, &g_stTtyUSB1Data.m_nMutex );
        pthread_mutex_unlock(&g_stTtyUSB1Data.m_nMutex);
		
        // 收到4G模块完整数据
        while( GetUSB1Event() ){
            DecUSB1Event();
            nLen = GetTtyUSB1Data( chBuf, 255 );
            if( nLen > 0 ){
				nCmdType = GPS_GetCmdType( chBuf );
				switch( nCmdType){
				case GPS_GPRMC:
						 if( nLen >= GPS_MAXBUF_LEN ){
								nLen = GPS_MAXBUF_LEN-1;
						 }
						 memset( g_strGPRMC, 0x00, GPS_MAXBUF_LEN );
						 memcpy( g_strGPRMC, chBuf, nLen );
						 SetGPSDataFlag();
						 //printf("GPRMC:%s", chBuf );
						break;
				case  GPS_GPGGA:
						if( nLen >= GPS_MAXBUF_LEN ){
								nLen = GPS_MAXBUF_LEN-1;
						}
						memset( g_strGPGGA, 0x00, GPS_MAXBUF_LEN);
						memcpy( g_strGPGGA, chBuf, nLen );
						SetGPSDataFlag();
						// printf("GPGGA:%s", chBuf );
						break;
				}
            }
        }
    }
    //printf("ThreadttyUSB1Send end\r\n");
    g_stTtyUSB1Data.m_pThreadSend = 0;
    pthread_exit(NULL);
    return  (void*)0;
}
//=======================================================
//  接收模块数据线程
void    *ThreadttyUSB1Recvice( void  *lpVoid ){
        
    short                 nLen = 0;
    unsigned char  chBuf[255];

    //printf("ThreadttyUSB1Recvice\r\n");
    lpVoid = lpVoid;
    memset( chBuf, 0x00, 255);        
    while( 1 ){
        if( g_stTtyUSB1Data.m_nComPort == - 1 ){
            break;
        }
        nLen = recv_data( g_stTtyUSB1Data.m_nComPort, chBuf,  255 );
        if( nLen > 0 ){
            chBuf[nLen] = 0x00;
			//printf("USB1:%s", chBuf );
            SaveTtyUSB1Data( chBuf, nLen );
        }
        else{
            if( nLen == -1 ){ 
				SetttyUSB1Close(); 
				if( g_stTtyUSB1Data.m_nComPort != -1 ){
					close_port(g_stTtyUSB1Data.m_nComPort );
					g_stTtyUSB1Data.m_nComPort  = -1;
					break;				
				}
            }
        }
    }
	// 发送 USB1线程退出
	pthread_cond_signal( &g_stTtyUSB1Data.m_nCond );
    //printf("ThreadttyUSB1Recvice end\r\n");
    g_stTtyUSB1Data.m_pThreadRecv = 0;
    pthread_exit(NULL);
    return  (void*)0;
}
//=======================================================
//  接收终端数据线程
void    *ThreadttyS0Send( void  *lpVoid ){
        
    unsigned char  nType = TYPE_ERROR;
    unsigned short  nLen = 0;
    unsigned char   *pMsg = NULL;
    unsigned char  chBuf[255];
    
    //printf("ThreadttyS0Send\r\n");
    lpVoid = lpVoid;
    memset( chBuf, 0x00, 255 );
    while( 1 ){
        if( g_stTtyS0Data.m_nComPort == - 1 ){ 
            break;
        } 
        pthread_mutex_lock( &g_stTtyS0Data.m_nMutex ); 
        pthread_cond_wait( &g_stTtyS0Data.m_nCond, &g_stTtyS0Data.m_nMutex ); 
        pthread_mutex_unlock( &g_stTtyS0Data.m_nMutex );
         //printf("ThreadttyS0Send_event\n" );
        // 收到设备完整数据
        while( GetS0Event() ){            
            DecS0Event();
            
            nLen = GetTtyS0Data( (unsigned char*)chBuf, 255 );
            if( nLen > 0 ){
                //解释数据发送数据
				if(  memcmp( &chBuf[0],  TEXT_MT,  2 ) == 0 ){ 
                    // 解释内部指令
                    //去掉 x0a x0d
                   pMsg = &chBuf[2];
                   pMsg[nLen-4] = 0x00;
                    nLen = PLS_S0ParseData(pMsg, pMsg, nLen-4, &nType ) ;
                    if( nLen > 0 ){
                         switch( nType ){
                          case  TYPE_SEND_TO_DE: 
                                if( send_data( g_stTtyS0Data.m_nComPort, pMsg,  nLen ) == -1 ){
									  SetttyS0Close();
									  close_port(g_stTtyS0Data.m_nComPort );
									  g_stTtyS0Data.m_nComPort  = -1;
								}
                                break;
                           case TYPE_SEND_TO_SOCKET:
                                 if(  socket_senddata( g_stWIFIStatus.m_hSocket,  pMsg, nLen  ) > 0 ){									 
                                       strcpy( (char*)chBuf, "SEND OK\r\n");
                                 }
                                 else{
                                     strcpy( (char*)chBuf, "SEND FAIL\r\n");
                                 }
                                 nLen = strlen( (char*)chBuf );
                                 if( send_data( g_stTtyS0Data.m_nComPort, chBuf,  nLen ) == -1 ){
									  SetttyS0Close();
									  close_port(g_stTtyS0Data.m_nComPort );
									  g_stTtyS0Data.m_nComPort  = -1;
								 }
                                break;
                          }
                    }
                }
				else{
						if( send_data( g_stTtyUSB0Data.m_nComPort, chBuf,  nLen ) == -1 ){
							//close ttyUSB0 
							SetttyUSB0Close();
							close_port(g_stTtyUSB0Data.m_nComPort );
							g_stTtyUSB0Data.m_nComPort  = -1;
							//close ttyUSB1
							SetttyUSB1Close();
							close_port( g_stTtyUSB1Data.m_nComPort );
							g_stTtyUSB0Data.m_nComPort  = -1;
						}
				}
            }
         }
    }
   //printf("ThreadttyS0Send end\r\n");
    g_stTtyS0Data.m_pThreadSend = 0;
    pthread_exit(NULL);
    return  (void*)0;
}
//=======================================================
//  接收模块数据线程
void    *ThreadttyS0Recvice( void  *lpVoid ){
        
    short                       nLen = 0;
    unsigned char      chBuf[255];

    //printf("ThreadttyS0Recvice\r\n");
    lpVoid = lpVoid;
    memset( chBuf, 0x00, 255);
    while( 1 ){
        if( g_stTtyS0Data.m_nComPort == - 1 ){
            break;
        }
        nLen = recv_data( g_stTtyS0Data.m_nComPort, chBuf,  255 );
        if( nLen > 0 ){
            chBuf[nLen] = 0x00;            
            SaveTtyS0Data( chBuf, nLen );
        }
        else{
            if( nLen == -1 ){
				SetttyS0Close();
			  close_port(g_stTtyS0Data.m_nComPort );
			  g_stTtyS0Data.m_nComPort  = -1;
                break;
            }			
        }
    }
	pthread_cond_signal( &g_stTtyS0Data.m_nCond );
    //printf("ThreadttyS0Recvice end\r\n");
    g_stTtyS0Data.m_pThreadRecv = 0;
    pthread_exit(NULL);
    return  (void*)0;
}
//=======================================================
// 
void    *ThreadUDPSocket( void  *lpVoid ){
    int             nSize;
    int             nLen = 0;
    char          chBuf[255];
    char          chIPHead[10];
        
    lpVoid = lpVoid;
     if(g_stWIFIStatus.m_hSocket  != -1 ){
            close( g_stWIFIStatus.m_hSocket );
    }   
    bzero(&g_stWIFIStatus.m_oSockAddr,sizeof(g_stWIFIStatus.m_oSockAddr));  
    g_stWIFIStatus.m_oSockAddr.sin_family=AF_INET;  
    g_stWIFIStatus.m_oSockAddr.sin_addr.s_addr=htonl(INADDR_ANY);  
    g_stWIFIStatus.m_oSockAddr.sin_port=htons( g_stWIFIStatus.m_nServerPort );  
    nSize=sizeof(g_stWIFIStatus.m_oSockAddr);

    g_stWIFIStatus.m_hSocket= socket(AF_INET,SOCK_DGRAM,0);  
    if( bind( g_stWIFIStatus.m_hSocket, (struct sockaddr *)&g_stWIFIStatus.m_oSockAddr, sizeof(g_stWIFIStatus.m_oSockAddr) ) != -1 ){
        
         SetSocketConnectOK(); 
         strcpy( chBuf, "CONNECT OK\r\n");
         send_data( g_stTtyS0Data.m_nComPort,  (unsigned char*)chBuf, strlen(chBuf) ); 
         printf("Socket  UDP Success\r\n");    
         while(1) {
            nLen = recvfrom(  g_stWIFIStatus.m_hSocket,  chBuf, 255,0, (struct   sockaddr *)&g_stWIFIStatus.m_oSockAddr, &nSize); 
            if( nLen > 0 ){                
                    sprintf( chIPHead, "+IPD%d:", nLen);
                    send_data( g_stTtyS0Data.m_nComPort,  (unsigned char*)chIPHead, strlen(chIPHead) );
                    send_data( g_stTtyS0Data.m_nComPort,  (unsigned char*)chBuf, nLen );
                    send_data( g_stTtyS0Data.m_nComPort,  (unsigned char*)TEXT_LF_RN, 2 );
            }
            else{
                    break;
            }
        }
    }  
    printf( "socket_bind Error\r\n" );
    SetSocketConnectNG();
    close( g_stWIFIStatus.m_hSocket );
    g_stWIFIStatus.m_hSocket = -1;
    g_stSocketData.m_pThreadRecv = 0;
    strcpy( chBuf, "CONNECT FAIL\r\n");
    send_data( g_stTtyS0Data.m_nComPort,  (unsigned char*)chBuf, strlen(chBuf) );      
    pthread_exit(NULL);
    return  (void*)0;
}
//=======================================================
// 
void    *ThreadTCPSocket( void  *lpVoid ){    
    
    int             nLen = 0;
    char          chBuf[255]; 
    char          chIPHead[10];
    
    lpVoid = lpVoid;
    if(g_stWIFIStatus.m_hSocket  != -1 ){
            close( g_stWIFIStatus.m_hSocket );
    }
    g_stWIFIStatus.m_hSocket = socket(AF_INET,SOCK_STREAM,0); 
    if(  g_stWIFIStatus.m_hSocket  !=  -1 ){
        
            //设置服务器地址结构，准备连接到服务器  
            g_stWIFIStatus.m_oSockAddr.sin_family = AF_INET; 
            g_stWIFIStatus.m_oSockAddr.sin_port = htons(g_stWIFIStatus.m_nServerPort);  
            g_stWIFIStatus.m_oSockAddr.sin_addr.s_addr = htonl(INADDR_ANY);
            g_stWIFIStatus.m_oSockAddr.sin_addr.s_addr = inet_addr(g_stWIFIStatus.m_nServerIP);   
            printf("Socket  TCP Success\r\n");
            if(  connect(g_stWIFIStatus.m_hSocket,(struct   sockaddr *)&g_stWIFIStatus.m_oSockAddr,sizeof(g_stWIFIStatus.m_oSockAddr) ) != -1 ){
                
                    SetSocketConnectOK();
                    strcpy( chBuf, "CONNECT OK\r\n");
                    send_data( g_stTtyS0Data.m_nComPort,  (unsigned char*)chBuf, strlen(chBuf) );
                    while( 1 ){
                            nLen = read( g_stWIFIStatus.m_hSocket,chBuf, 255  );
                            if( nLen <= 0 ){
                                 break;
                            }
                            sprintf( chIPHead, "+IPD%d:", nLen);
                            send_data( g_stTtyS0Data.m_nComPort,  (unsigned char*)chIPHead, strlen(chIPHead) );
                            send_data( g_stTtyS0Data.m_nComPort,  (unsigned char*)chBuf, nLen );
                            send_data( g_stTtyS0Data.m_nComPort,  (unsigned char*)TEXT_LF_RN, 2 );
                    }
            }
    }
    SetSocketConnectNG();
    printf("Socket TCP error:");    
    close( g_stWIFIStatus.m_hSocket );
    g_stWIFIStatus.m_hSocket = -1;
    
    strcpy( chBuf, "CONNECT FAIL\r\n");
    send_data( g_stTtyS0Data.m_nComPort,  (unsigned char*)chBuf, strlen(chBuf) );           
    pthread_exit(NULL);
    
    return   (void*)0;
}
//=====================================================
//  发送数据
short       socket_senddata(  int      hSocket,  unsigned  char   *pData,  unsigned  short   nLen ){
    
    unsigned char                   nCount = 0;
    short                                   nTmpLen=0;
    short                                   nResult = 0;
    struct sockaddr_in            address; 
    
    if(  !IsSocketConnectOK() ){
            return  nResult;
    }
    while(  nTmpLen < nLen ){ 
        if( IsTCPCommMode() ){
            nResult = write( hSocket, pData+nTmpLen, nLen-nTmpLen );
        }
        else{  
            bzero(&address,sizeof(address));  
            address.sin_family=AF_INET;  
            address.sin_addr.s_addr=inet_addr(g_stWIFIStatus.m_nServerIP);   
            address.sin_port=htons( g_stWIFIStatus.m_nServerPort);
            nResult = sendto( hSocket, pData+nTmpLen, nLen-nTmpLen, 0,(struct   sockaddr *)&address, sizeof(address)  ); 
        }
        if( nResult <= 0  ){
            if( nResult == - 1 ){
                break;
            }
            if( nCount++ > 10 ){
                break;
            }
            // 10毫秒
            usleep( 10000 );
        }
        nTmpLen += nResult;
    }
    return  nTmpLen;
}