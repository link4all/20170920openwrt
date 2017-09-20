//////////////////////////////////////////////////////////////////////////
// file name: Comm.h
// Author:wyb
// date: 20160104
#include <termios.h>
#include <unistd.h>

#ifndef  COMM_20160104_H
#define COMM_20160104_H

int          open_port( char   *strPort, speed_t  sBaudrate );
void        close_port( int  nPort);
void        init_tty(int fPort, speed_t  sBaudrate) ;

short       recv_data( int      fComPort,  unsigned  char   *pData,  unsigned  short   nMaxLen );
short       send_data( int      fComPort,  unsigned  char   *pData,  unsigned  short   nLen );

#endif //COMM_20160104_H