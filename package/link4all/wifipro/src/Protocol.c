//////////////////////////////////////////////////////////////////////////
// file name: Protocol.h
// Author:wyb
// date: 20160105
#include "main.h"
#include  "Protocol.h"
#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <ctype.h>
#include "Comm.h"

const   char    *s_strAbbrCmd[] = {    
                                                    "+CIPSTART",                 //连接服务器
                                                    "+CIPCLOSE",                      //关闭SOCKET
                                                    "+CIPSEND",                 //发送SEND数据
                                                    "+QSTATUS",                 //查询状态
													"+WIFIPRO",				  //退出程序
													"+GPRMC",				  //GPRMC数据
													"+GPGGA",					 //GPGGA数据
};

/////////////////////////////////////////////////////////////
//   字符串比较(不分大小写)
unsigned  char  strcmpnc( unsigned char     *p1, unsigned char  *p2 ){
        
        unsigned    char        nResult = 1;
        
        if( strlen( (char*)p1) != strlen((char*)p2)  ){
                nResult = 0;
        }
        else{
                while( *p1 ){
                        if( tolower(*p1) != tolower(*p2) ){
                              nResult = 0;
                              break;
                        }
                        p1++;
                        p2++;
                }
        }
        return     nResult;
}
/////////////////////////////////////////////////////////////
// 
unsigned char PLS_GetCommandType( unsigned char  *pBuf, unsigned short   nLen ){

    unsigned char      nCnt  = 0;    
    unsigned char      nPos = 0;
    unsigned char      nTmpLen = 0;
    unsigned char     *pTmp 	  = NULL;
    unsigned char	 *pKeyword = NULL;
    unsigned char     *pMsg = NULL;
    
    // 去掉头部: MT+   MT%  MT^
    // pTmp指向数据
    // pKeyword指向关键词
    pMsg = pBuf;    
    pTmp = (unsigned char*)strchr( (char*)pMsg, TEXT_EQUAL );
    if( pTmp != NULL ){
          *pTmp = 0x00;
          pTmp++;
          nPos++;
    }
    nTmpLen = strlen( (char*)pMsg );
    //printf("cmd:%d %s\n", nTmpLen, pMsg );
    if( nTmpLen <= 0 ){
          return  CC_CMD_END;
    }
    pKeyword = pMsg;
    
    // 命令码比较 and
    // 简单命令码比较
    for( nCnt = 0; nCnt < CC_CMD_END; nCnt++ ){        
        if( strcmpnc((unsigned char*)s_strAbbrCmd[nCnt], pKeyword ) ){
            //printf("Key:%s  Key:%s\n", s_strAbbrCmd[nCnt], pKeyword);
            break;
        }
    }
    if( nCnt < CC_CMD_END ){
            memcpy( pBuf, pTmp,  nLen - nTmpLen-nPos );
            pBuf[nLen - nTmpLen-nPos] = 0x00;
           // printf("SRC:%s  \n",pBuf);
    }
	return nCnt;
}
//=====================================================
//   4G模块数据解释
unsigned  short  PLS_S0ParseData( unsigned char  *pSrc, unsigned char  *pDest, unsigned  short  nLen, unsigned char  *pType ){

    unsigned char      nCmdType = 0;
    unsigned short    nResultLen = 0;
        
    *pType = TYPE_SEND_TO_DE;    
    nCmdType = PLS_GetCommandType( pSrc, nLen );
    switch( nCmdType ){
    case CC_SERVER_IP:
        nResultLen = PLS_ServerIP( pSrc, pDest , pType);
        break;
    case CC_SERVER_CLOSE:        
        strcpy( (char*)pDest, "OK\r\n");
        nResultLen = strlen(  (char*)pDest);
        if( g_stWIFIStatus.m_hSocket != -1 ){
           // printf( "close ok\n");
            close( g_stWIFIStatus.m_hSocket );
            SetSocketConnectNG();
            g_stWIFIStatus.m_hSocket = -1;
        }
        break;
    case CC_SENDIP_DATA:
        nResultLen = PLS_SendIPData( pSrc, pDest , pType);
        //printf("par:%d\n", nResultLen );
        break;
    case CC_QUERY_STATUS:
        nResultLen = PLS_QueryStatus( pSrc, pDest , pType);
        break;
	case CC_WIFIPRO_EXIT:	
		send_data( g_stTtyS0Data.m_nComPort, (unsigned char*)"OK\r\n",  4 );
		SetExitAPP();
		break;
	case	CC_GPS_GPRMC:
		 if( IsGPSDataFlag() ){
					nResultLen = strlen( (char*)g_strGPRMC );
					strcpy( (char*)pDest,  (char*)g_strGPRMC );
		 }
		 else{
					strcpy( (char*)pDest, "ERROR\r\n");
					nResultLen = strlen((char*) pDest );
		 }
		 break;
	case	CC_GPS_GPGGA:
		 if( IsGPSDataFlag() ){
			 nResultLen = strlen( (char*)g_strGPGGA );
			 strcpy( (char*)pDest,  (char*)g_strGPGGA );
		 }
		 else{
			  strcpy( (char*)pDest, "ERROR\r\n");
			 nResultLen = strlen( (char*)pDest );
		 }
		break;
    }
    return   nResultLen;
}
//=====================================================
//   设置服务器IP地址 AT+CIPSTART ="TCP","192.168.1.112",8868
unsigned  short     PLS_ServerIP( unsigned char     *pSrc,  unsigned char   *pDest , unsigned char  *pType){
    
    unsigned   char     nCnt = 0;
    unsigned    short    nLen;
    unsigned    char    *pTmp = NULL;
    unsigned    char    *pch = NULL;
    
    //printf("%s\n", pSrc );
    while( 1 ){
        pTmp = (unsigned char*)strchr( (char*)pSrc, ',');
        if( pTmp == NULL ){
                if( nCnt == 2 ){
                     g_stWIFIStatus.m_nServerPort =  atoi( (char*)pSrc );
                     SetNeedSocketConnect();
                }
            break;
        }
        if(  0 == nCnt ){
                pSrc++;
              if( memcmp(pSrc, TEXT_TCP, 3 ) == 0 ){
                    SetTCPCommMode();
              }
              else if( memcmp(pSrc, TEXT_UDP, 3) == 0 ){
                  SetUDPCommMode();
              }
        }
        else if( 1 == nCnt ){
              pSrc++;
              pch = (unsigned char*)strchr( (char*)pSrc, '"');
              if( pch != NULL ){
                    *pch = 0x00;
                    memset( g_stWIFIStatus.m_nServerIP, 0x00, SERVERIP_LENGTH +1);
                    strncpy( (char*)g_stWIFIStatus.m_nServerIP, (char*)pSrc, SERVERIP_LENGTH);
              }
        }        
        pSrc = pTmp+1;
        nCnt++;
    }
    *pType = TYPE_SEND_TO_DE;
    if( nCnt >= 2 ){
            strcpy( (char*)pDest, "OK\r\n");
    }
    else{
            strcpy( (char*)pDest, "ERROR\r\n");
    }
    nLen = strlen( (char*)pDest );
    return  nLen;
}
//=====================================================
//   发送数据到服务器AT+IPSEND=10,123456
unsigned  short     PLS_SendIPData( unsigned char     *pSrc,  unsigned char   *pDest, unsigned char  *pType ){

    unsigned    short       nLen;
    unsigned   char       *pch = NULL;
    
    pch = (unsigned char*)strchr( (char*)pSrc, ',');
    if( (pch != NULL) && IsSocketConnectOK() ){
            *pch = 0x00;
            nLen =  atoi( (char*)pSrc );
            pSrc = pch+1;
            memcpy( pDest, pSrc, nLen );
            pDest[nLen] = 0x00;
            *pType = TYPE_SEND_TO_SOCKET;
    }
    else{
          strcpy( (char*)pDest, "ERROR");
          nLen = strlen( (char*)pDest );
         *pType = TYPE_SEND_TO_DE;
          //printf("error send:%s\n",pDest );
    }
    return  nLen;
}
//=====================================================
//  查询状态
unsigned  short     PLS_QueryStatus( unsigned char     *pSrc,  unsigned char   *pDest , unsigned char  *pType){
   
    unsigned    short    nLen = 0;
    
    
    return  nLen;
}