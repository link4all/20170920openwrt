//////////////////////////////////////////////////////////////////////////
// file name: main.h
// Author:wyb
// date: 20160104
#include <pthread.h>  
#include <unistd.h>  
#include <sys/socket.h>  
#include <netinet/in.h>  
#include <arpa/inet.h>  


#ifndef     MAIN_20160104_H
#define       MAIN_20160104_H

#define     TEXT_AT                              "AT"
#define     TEXT_QUESTION               "?"
#define     TEXT_LF_RN                       "\r\n"
#define     TEXT_MT                             "MT"

// 模块串口
#define     C_PORT_TTYUSB0                "/dev/ttyUSB0"
#define     C_USB0_BAUDRATE              B115200

//GPS模块端口
#define		C_PORT_TTYUSB1				 "/dev/ttyUSB1"
#define		C_USB1_BAUDRATE			  B115200

//终端设备串口
#define     C_PORT_TTYS0                     "/dev/ttyS0"
#define     C_S0_BAUDRATE                  B9600

#define     MAXBUF_RECV                        512
#define     SERVERDOMAIN_LENGTH     29
#define     SERVERIP_LENGTH                 15      
#define    GPS_MAXBUF_LEN					90

#define     CHK_TIME_SPACE                  20      //20秒
///////////////////////////////////////////////////////////////////
//
enum{
      SW_TTYUSB0_FLAG = 0x01,        //ttyUSB0
      SW_TTYS0_FLAG = 0x02,              //ttyS0
      SW_SOCKET_FLAG = 0x04,           //socket状态
      SW_NEED_SOCKETCONNECT = 0x08,  //1/0 连接/不连接
      SW_GPRS_TCP     = 0x10,                 //1/0  TCP/UDP模式
	  SW_EXIT_APP      = 0x20,				//退出APP
	  SW_TTYUSB1_FLAG = 0x40,			 //GPS ttyUSB1
	  SW_GPS_STATUS = 0x80,				//GPS数据状态
};
//=======================================================
//GPS 类型
enum{
		GPS_GPRMC = 0,			//GPRMC数据
		GPS_GPGGA,					//GPGGA数据
		GPS_CMD_END				//
};

#ifndef  __STTTYCOMDATA
#define  __STTTYCOMDATA
typedef struct  _STTTYCOMDATA{
    
    unsigned char m_nEvent;
    int                  m_nComPort;                //串口ID
    int                  m_nFront; 
    int                  m_nBack;    
    
    pthread_t        m_pThreadRecv;
    pthread_t        m_pThreadSend;                   
    pthread_mutex_t      m_nMutex; 
    pthread_cond_t       m_nCond;
    int                  m_nBuf[MAXBUF_RECV];
}STTTYCOMDATA,*PSTTTYCOMDATA;
#endif //__STTTYUSB0DATA

#ifndef  __STWIFISTATUS
#define  __STWIFISTATUS
typedef struct  _STWIFISTATUS{
    
     // BIT0:  ttyUSB0   1/0   开启/关闭
     // BIT1:  ttyS0     1/0   开启/关闭
     // BIT2:  网络      1/0   Socket连接/Socket断开     
     // BIT3:  TCP/UDP      1/0   Socket工作/Socket不工作
     unsigned char     m_nFlag;               
     // socket ip
     int                        m_nServerPort;                                          //SOCKET 端口号    
     int                        m_hSocket;              
     struct   sockaddr_in     m_oSockAddr;
     char                     m_strServerDomain[SERVERDOMAIN_LENGTH+1];   //域名
     char                     m_nServerIP[SERVERIP_LENGTH+1];          //SOCKET IP地址
    
}STWIFISTATUS,*PSTWIFISTATUS;
#endif //__STWIFISTATUS

extern	char							g_strGPRMC[GPS_MAXBUF_LEN];			//GPRMC数据		
extern    char								g_strGPGGA[GPS_MAXBUF_LEN];			  //GPGGA数据
extern    const char				  *s_strGPSCMD[];		//GPS命令数据
extern   STTTYCOMDATA         g_stTtyUSB0Data;     // 4G模块结构
extern   STTTYCOMDATA         g_stTtyUSB1Data;     //GPS数据结构
extern   STTTYCOMDATA         g_stTtyS0Data;          // 终端设备结构
extern   STTTYCOMDATA         g_stSocketData;        // UDP/TCP连接
extern   STWIFISTATUS             g_stWIFIStatus;         // WIFI状态结构  

// ttyUSB0数据标志位
#define     AddUSB0Event()      (g_stTtyUSB0Data.m_nEvent++)
#define     DecUSB0Event()      (g_stTtyUSB0Data.m_nEvent--)
#define     GetUSB0Event()      (g_stTtyUSB0Data.m_nEvent)

// ttyS0数据标志位
#define     AddS0Event()         (g_stTtyS0Data.m_nEvent++)
#define     DecS0Event()        (g_stTtyS0Data.m_nEvent--)
#define     GetS0Event()         (g_stTtyS0Data.m_nEvent)

// GPS数据标志位
#define     AddUSB1Event()         (g_stTtyUSB1Data.m_nEvent++)
#define     DecUSB1Event()        (g_stTtyUSB1Data.m_nEvent--)
#define     GetUSB1Event()         (g_stTtyUSB1Data.m_nEvent)


// ttyUSB0串口是否打开
#define     SetttyUSB0Open()     (g_stWIFIStatus.m_nFlag |= SW_TTYUSB0_FLAG)
#define     SetttyUSB0Close()     (g_stWIFIStatus.m_nFlag &= ~SW_TTYUSB0_FLAG)
#define     IsttyUSB0Status()      (g_stWIFIStatus.m_nFlag & SW_TTYUSB0_FLAG)

// ttyUSB1串口是否打开
#define     SetttyUSB1Open()     	  (g_stWIFIStatus.m_nFlag |= SW_TTYUSB1_FLAG)
#define     SetttyUSB1Close()    	  (g_stWIFIStatus.m_nFlag &= ~SW_TTYUSB1_FLAG)
#define     IsttyUSB1Status()    	     (g_stWIFIStatus.m_nFlag & SW_TTYUSB1_FLAG)

// ttyS0串口是否打开
#define     SetttyS0Open()          (g_stWIFIStatus.m_nFlag |= SW_TTYS0_FLAG)
#define     SetttyS0Close()          (g_stWIFIStatus.m_nFlag &= ~SW_TTYS0_FLAG)
#define     IsttyS0Status()          (g_stWIFIStatus.m_nFlag & SW_TTYS0_FLAG)

//     SOCKET状态
#define     SetSocketConnectOK()     (g_stWIFIStatus.m_nFlag |= SW_SOCKET_FLAG)
#define     SetSocketConnectNG()     (g_stWIFIStatus.m_nFlag &= ~SW_SOCKET_FLAG)
#define     IsSocketConnectOK()     (g_stWIFIStatus.m_nFlag & SW_SOCKET_FLAG)

// SOCKET是否连接标志
#define     SetNeedSocketConnect()     (g_stWIFIStatus.m_nFlag |= SW_NEED_SOCKETCONNECT )
#define     ClrNeedSocketConnect()     (g_stWIFIStatus.m_nFlag &= ~SW_NEED_SOCKETCONNECT )
#define     IsNeedSocketConnect()     (g_stWIFIStatus.m_nFlag & SW_NEED_SOCKETCONNECT )

// TCP/UDP连接方式
#define      IsTCPCommMode()          (g_stWIFIStatus.m_nFlag & SW_GPRS_TCP)
#define      SetTCPCommMode()     (g_stWIFIStatus.m_nFlag |= SW_GPRS_TCP)
#define      SetUDPCommMode()     (g_stWIFIStatus.m_nFlag &= ~SW_GPRS_TCP)

#define		IsExitAPP()							 (g_stWIFIStatus.m_nFlag & SW_EXIT_APP)
#define       SetExitAPP()					   (g_stWIFIStatus.m_nFlag |= SW_EXIT_APP)
#define      ClrExitAPP()   				   (g_stWIFIStatus.m_nFlag &= ~SW_EXIT_APP)

#define		IsGPSDataFlag()			 (g_stWIFIStatus.m_nFlag & SW_GPS_STATUS)
#define		SetGPSDataFlag()			  (g_stWIFIStatus.m_nFlag |= SW_GPS_STATUS)
#define		ClrGPSDataFlag()			 (g_stWIFIStatus.m_nFlag &= ~SW_GPS_STATUS)


void              InitState( void );
void              InitPort( void );

void             InitUSB0Port( void );
void             InitThreadUSB0( void );

void             InitUSB1Port( void );
void             InitThreadUSB1( void );
unsigned char  GPS_GetCmdType( unsigned char  *pMsg );

void             InitS0Port( void );
void             InitThreadS0( void );

void            InitThreadSocket( void );

void              Destroy_memory( void );
unsigned char     SaveTtyUSB0Data( unsigned char *pData,  unsigned  short  nLen );
int               GetTtyUSB0Data(unsigned char *pBuf, unsigned short nDataLen);

unsigned char     SaveTtyUSB1Data( unsigned char *pData,  unsigned  short  nLen );
int               GetTtyUSB1Data(unsigned char *pBuf, unsigned short nDataLen);

unsigned char     SaveTtyS0Data( unsigned char *pData,  unsigned  short  nLen );
int               GetTtyS0Data(unsigned char *pBuf, unsigned short nDataLen);

#endif //MAIN_20160104_H
