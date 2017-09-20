//////////////////////////////////////////////////////////////////////////
// file name: Thread.h
// Author:wyb
// date: 20160105

#ifndef  THREAD_20160105_H
#define THREAD_20160105_H

void    *ThreadttyUSB0Send( void  *lpVoid );
void    *ThreadttyUSB0Recvice( void  *lpVoid );

void    *ThreadttyUSB1Send( void  *lpVoid );
void    *ThreadttyUSB1Recvice( void  *lpVoid );

void    *ThreadttyS0Send( void  *lpVoid );
void    *ThreadttyS0Recvice( void  *lpVoid );

void    *ThreadUDPSocket( void  *lpVoid );
void    *ThreadTCPSocket( void  *lpVoid );

short       socket_senddata(  int      hSocket,  unsigned  char   *pData,  unsigned  short   nLen );
#endif //THREAD_20160105_H

