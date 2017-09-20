//////////////////////////////////////////////////////////////////////////
// file name: Protocol.h
// Author:wyb
// date: 20160105

#ifndef   PROTOCOL_20160105_H
#define  PROTOCOL_20160105_H

#define         TEXT_EQUAL           '='
#define         TEXT_UDP                "UDP"
#define         TEXT_TCP                "TCP"

//=======================================================
//  发送到串口地址
enum{
    TYPE_ERROR = 0x00,
    TYPE_SEND_TO_DE  = 0x01,        //设备终端
    TYPE_SEND_TO_4G =  0x02,        //4G模块
    TYPE_SEND_TO_SOCKET = 0x03, //发送到SOCKET
};

//=======================================================
//
enum{        
        CC_SERVER_IP       = 0x00,
        CC_SERVER_CLOSE,
        CC_SENDIP_DATA ,
        CC_QUERY_STATUS,       
	    CC_WIFIPRO_EXIT,
		CC_GPS_GPRMC,
		CC_GPS_GPGGA,
        CC_CMD_END
};


unsigned  char  strcmpnc( unsigned char     *p1, unsigned char  *p2 );

unsigned  short     PLS_S0ParseData( unsigned char  *pSrc, unsigned char  *pDest, unsigned  short  nLen, unsigned char  *pType );
unsigned  short     PLS_ServerIP( unsigned char     *pSrc,  unsigned char   *pDest , unsigned char  *pType);
unsigned  short     PLS_SendIPData( unsigned char     *pSrc,  unsigned char   *pDest, unsigned char  *pTypee );
unsigned  short     PLS_QueryStatus( unsigned char     *pSrc,  unsigned char   *pDest , unsigned char  *pType);

unsigned  short     PLS_USBParseData( unsigned char  *pSrc, unsigned char  *pDest, unsigned  short  nLen, unsigned char  *pType );

#endif //PROTOCOL_20160105_H