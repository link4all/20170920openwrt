#include "hardware.h"
#include <unistd.h>

#define RET_FALSE (0x1)
#define RET_TRUE  (0x0)

//for variable
unsigned char tmp; 
//WORD   count;
DWORD   i; 


DWORD SAMPLE_RATE=10;
   
//for one wire
static BYTE swb_cycle0 = 0x00;   //for timer0 reload value(timer cycle)
static BYTE swb_cycle1 = 1;   //for timer0    

#define SWB_IDLE (0x0)
#define SWB_SEND (0x1)
#define SWB_WAIT (0x2)
#define SWB_REV  (0x3)

//for ack
#define TRANSFER_PROCESS     (0x0)
#define TRANSFER_COMPLETE    (0x1)
#define TRANSFER_TIMEOUT     (0x2)

static WORD timer0cnt1=0;   //for rate
static BYTE samplecnt = 0;    //for sample
static BYTE swb_datacnt=0;  //for send/rev data cnt
static BYTE  swb_waitcnt = 0;  //for wait device ack
static DWORD timer0_senddata;   //
static BYTE timer0_sendcycle;
static DWORD timer0_revdata;
static BYTE timer0_revcycle;
volatile BYTE timer0_transflag = TRANSFER_PROCESS;  //0: processing; 1: transmit complete; 2: wait device timeout
volatile BYTE timer0_state = SWB_IDLE;

BYTE running = 1;
BYTE TR0 = 0;
BYTE ET0 = 0;

DWORD _lrol_(DWORD c,BYTE b){
	DWORD left=c<<b;
	DWORD right=c>>(sizeof(DWORD)-b);
	DWORD temp=left|right;
	return temp;
}

BYTE EvenParity(BYTE opdata)
{           
    BYTE temp;
    
    temp = opdata;
    temp ^= (temp>>4);
    temp ^= (temp>>2);
    temp ^= (temp>>1);
    
    return temp & 0x01;  //(temp^0x1)&0x1;  //                                 
}

BYTE GetBits(BYTE opdata, BYTE loc, BYTE len)
{
	return (opdata>>loc)&((1<<len)-1);
}

BYTE BitAnti(BYTE opdata, BYTE loc)
{
	BYTE temp;
	temp = (opdata>>loc)&0x1;
	return temp==0x1 ? 0x0:0x1;
}


BYTE onewire_config(BYTE onewire_clk)
{
    
    //swb_devaddr = dev_addr;  //default 0x1
    //timer_cycle = TIMER_CLK/SAMPLE_RATE/onewire_clk;
    //swb_cycle1 = (timer_cycle >> 8) + 1;
    //swb_cycle0 = 255 - (timer_cycle/swb_cycle0); 
    
    //swb_devaddr = dev_addr;  //default 0x1
    swb_cycle0 = 206;   //20k: ;  16k:206; 12k: ; 8k: 156;    4k: 56;  2k: 56;  1k: 56
    swb_cycle1 = onewire_clk; //1;    // 20k: ;  16k:1;   12k: ; 8k: 1;      4k: 1;   2k: 2;   1k: 4
//===================user select timer============
    //==set timer0
    //TMOD = 0x02;      //set timer0 mode 2,  8 bit counter with auto reload mode
    //TH0 = swb_cycle0;
    //TR0 = 0;   //disable timer0
    //ET0 = 0;   //disable timer0 interrupt
//==================================================
    return (RET_TRUE);
    
}   

BYTE onewire_read_byte(BYTE regaddr, BYTE *rd_data, BYTE *flag)
{
		DWORD wrdata;
		DWORD  rddata;
		BYTE parity, parity_rev, bitantitmp;
		
		//====for data recombination
		//send data: 18 bit
		//bit[17:15] = 3'b010;   //Leader Code 
		//bit[14]    = 1'b0;     //from host:0; from slave:1
		//bit[13:12] = 2'b01;    //device address, fixed 2'b01
		//bit[11]    = 1'b ;     //parity of reg_addr
		//bit[10]    = 1'b1;     //read operation:1 ;  write operation:0
		//bit[9]     = 1'b0;     //antilogic
		//bit[8:5]   = 4'b ;     //reg_addr[7:4]
		//bit[4]     = 1'b ;     //~reg_addr[4] 
		//bit[3:0]   = 4'b ;     //reg_addr[3:0]
		
		//receive data: 18 bit
		//bit[17:15] = 3'b010;   //Leader Code
		//bit[14]    = 1'b1;     //from host:0; from slave:1
		//bit[13:12] = 2'b01;    //device address, fixed 2'b01
		//bit[11]    = 1'b1 ;     //parity of regaddr(received from host)
		//bit[10]    = 1'b ;     //parity of reg data
		//bit[9]     = 1'b ;     //antilogic of bit[10]
		//bit[8:5]   = 4'b ;     //reg_data[7:4]
		//bit[4]     = 1'b ;     //~reg_data[4] 
		//bit[3:0]   = 4'b ;     //reg_data[3:0]
		
		//compute the parity of reg addr
		parity = EvenParity(regaddr);
		bitantitmp = BitAnti(regaddr, 4);
		//wrdata = (2<<15) | (0<<14) | (1<<12) | (parity<<11) | (1<<10) | (0<<9) | ((regaddr&0xF0)<<1) | (bitantitmp<<4) | (regaddr&0xF);
	  //wrdata = (wrdata << 14);
	  wrdata = (parity<<11) | ((regaddr&0xF0)<<1) | (bitantitmp<<4) | (regaddr&0xF);
	  wrdata = _lrol_(wrdata,14);
	  wrdata |= 0x45000000;
		printf("\n%X\n",wrdata);
	  //===wait transfer over
	  //timer0_state = SWB_IDLE;
	  while(timer0_state != SWB_IDLE)   //wait last transfer over
	  {
	  }
	  
		//===set transfer 
		timer0_senddata = wrdata; //0x45064000;//
		timer0_revdata = 0;
		timer0_sendcycle = 18;
		timer0_revcycle = 18;
		//===================user select onewire PIN============
		//set pd
		//OED |= 0x10;  //PD4 : output
		//PD4 = 1;  //default
		set_gpio_output(1);
		//======================================================
		//===================user select timer============
		//enable timer0
		TR0 = 1;
		ET0 = 1;
		//=================================================
		timer0_state = SWB_SEND;
		timer0_transflag = TRANSFER_PROCESS;
		//===wait over
		while(timer0_transflag == TRANSFER_PROCESS)
		{
			
		}
		
		//====for onewire data check
		if(timer0_transflag != TRANSFER_COMPLETE)   //transfer timeout
		{
			*flag = timer0_transflag;
			*rd_data = 0xFE;
			return (RET_FALSE);
		}
		//good parity check
		parity_rev = (timer0_revdata>>11) & 0x1;
		if(parity_rev != 1)
		//if(parity != parity_rev)
		{			 
		  *flag = timer0_transflag;
			*rd_data = 0xFC;
			return (RET_FALSE);
		}
		//rddata parity check
		rddata = (timer0_revdata&0xF) | ((timer0_revdata>>1)&0xF0);
		parity = EvenParity(rddata);
		parity_rev = (timer0_revdata>>10) & 0x1;
		if(parity != parity_rev)
		{			 
		  *flag = timer0_transflag;
			*rd_data = 0xFD;//0xFD;
			return (RET_FALSE);
		}
		//===get reg data
		*rd_data = rddata;
		*flag = timer0_transflag;
    return (RET_TRUE);
}

BYTE onewire_write_byte(BYTE regaddr, BYTE wr_data, BYTE *flag)
{		
		DWORD wrdata;
		BYTE parity, parity_rev, bitantitmp;
		
		//====for data recombination
		//send data: 27 bit
		//bit[26:24] = 3'b010;   //Leader Code 
		//bit[23]    = 1'b0;     //from host:0; from slave:1
		//bit[22:21] = 2'b01;    //device address, fixed 2'b01
		//bit[20]    = 1'b ;     //parity of reg_addr and data
		//bit[19]    = 1'b0;     //read operation:1 ;  write operation:0
		//bit[18]    = 1'b1;     //antilogic
		//bit[17:14] = 4'b ;     //reg_addr[7:4]
		//bit[13]    = 1'b ;     //~reg_addr[4] 
		//bit[12:9]  = 4'b ;     //reg_addr[3:0]
		//bit[8:5]   = 4'b ;     //data[7:4]
		//bit[4]     = 1'b ;     //~data[4] 
		//bit[3:0]   = 4'b ;     //data[3:0]	
		
		//receive data: 9 bit
		//bit[8:6]   = 3'b010;   //Leader Code
		//bit[5]     = 1'b1;     //from host:0; from slave:1
		//bit[4:3]   = 2'b01;    //device address, fixed 2'b01
		//bit[2]     = 1'b1 ;     //parity of regaddr and data(regadddr and data received from host)
		//bit[1]     = 1'b0;     //parity not used
		//bit[0]     = 1'b1;     //antilogic of bit[1]
		
	  //compute the parity of reg addr
		/*parity = EvenParity(regaddr ^ wr_data);
		bitantitmp = BitAnti(regaddr, 4);
		wrdata = (2<<24) | (0<<23) | (2<<21) | (parity<<20) | (0<<19) | (1<<18) | ((regaddr&0xF0)<<10) | (bitantitmp<<13) | ((regaddr&0x0F)<<9);
		bitantitmp = BitAnti(wr_data, 4);
		wrdata |= ((wr_data&0xF0)<<1) | (bitantitmp<<4) | ((wr_data&0x0F)<<0);	
		wrdata = _lrol_(wrdata,6);*/
		
		parity = EvenParity(regaddr ^ wr_data);
		bitantitmp = BitAnti(regaddr, 4);
		wrdata = parity<<2;
		wrdata =  _lrol_(wrdata,9);
		wrdata |= ((regaddr&0xF0)<<1) | (bitantitmp<<4) | ((regaddr&0x0F)<<0);
		wrdata =  _lrol_(wrdata,9);
		bitantitmp = BitAnti(wr_data, 4);
		wrdata |= ((wr_data&0xF0)<<1) | (bitantitmp<<4) | ((wr_data&0x0F)<<0);	
		wrdata = _lrol_(wrdata,5);
		wrdata |= 0x44800000;
		
		/*wrdata = (parity<<11) | ((regaddr&0xF0)<<1) | (bitantitmp<<4) | (regaddr&0xF);
	  wrdata = _lrol_(wrdata,14);
	  wrdata |= 0x45000000;*/
		    
	  //wait transfer over
		//timer0_state = SWB_IDLE;
	  while(timer0_state != SWB_IDLE)
	  {
	  }
		//
		timer0_senddata = wrdata;
		timer0_revdata = 0;
		timer0_sendcycle = 27;
		timer0_revcycle = 9;
		//===================user select onewire PIN============
		//set pd
		//OED |= 0x10;  //PD4 : output
		set_gpio_output(1);
		//PD4 = 1;  //default
		//======================================================
		//===================user select timer============
		//enable timer0
		TR0 = 1;
		ET0 = 1;
		//================================================
		timer0_state = SWB_SEND;
		timer0_transflag = TRANSFER_PROCESS;
		//===wait over
		while(timer0_transflag == TRANSFER_PROCESS)
		{
			
		}
		
		//====for onewire data check
		if(timer0_transflag != TRANSFER_COMPLETE)   //transfer timeout
		{
			*flag = timer0_transflag;
			return (RET_FALSE);
		}
		//good parity check
		parity_rev = (timer0_revdata>>2) & 0x1;
		if(parity_rev != 1)
		//if(parity != parity_rev)
		{			 
		  *flag = timer0_transflag;
			return (RET_FALSE);
		}
    return (RET_TRUE);
}

//void* doSomeThing(void *arg)
void ISR_TIMER0(void)
{
	if(!TR0)
		return;

   //for onewire rate / sample_rate count
	 timer0cnt1 += 1;
	// usleep(1);	 	  
	 if(timer0cnt1 >= swb_cycle1)
	 {
	 	  timer0cnt1 = 0;
	 }
	 else
	 {
	 	  return;
	 }
   
   //
	 if(timer0_state == SWB_SEND)
	 {
	 		//for sample rate count
	 		samplecnt++;
		//usleep(1);
	 	  if(samplecnt >=SAMPLE_RATE)
	 	  {
	 	  		samplecnt = 0;
	 	  		swb_datacnt++;
	 	  	  if(swb_datacnt > (timer0_sendcycle+0)) //send over
	 	  	  {
	 	  	  	  timer0_state = SWB_WAIT;
	 	  	  	  //===================user select onewire PIN============
	 	  	  	  //OED &= 0xEF;  //set PD4 : input
	 	  	  	  set_gpio_output(0);
	 	  	  	  //PD4 = 1;   //default high
	 	  	  	  //PA7 = 1;
	 	  	  	  //=======================================================
	 	  	  	  swb_datacnt = 0;
	 	  	  	  swb_waitcnt = 0;
	 	  	  }
	 	  	  else
	 	  	  {
	 	  	  	 timer0_senddata = _lrol_(timer0_senddata,1);   //PD4 for 
	 	  	  	 //===================user select onewire PIN============
	 	  	  	 //PD4 = timer0_senddata&0x1;   //PD4 for 
	 	  	  	 write_gpio(timer0_senddata&0x1);
	 	  	  	 //PA7 = ~PA7;
	 	  	  	 //======================================================
	 	  	  }
	 	  }
	 }
	 else if(timer0_state == SWB_WAIT)  //wait device ack,low level
	 {
	 	  swb_waitcnt++;
	 	  if(swb_waitcnt > (32*SAMPLE_RATE))   //32*5  wait timeout 
	 	  {
	 	  	  timer0_state = SWB_IDLE;
	 	  	  //===================user select timer============
	 	  	  TR0 = 0;  //disable timer0
	 	  	  ET0 = 0;  //disable timer0 interrupt
	 	  	  //================================================
	 	  	  timer0_transflag = TRANSFER_TIMEOUT;  //
	 	  	  timer0_revdata = 0xFFFF;
	 	  	  return;
	 	  }
	 	  //===================user select onewire PIN============
	 	  //if(PD4 == 0x0)   //low level 
	 	  //======================================================
	 	  if(read_gpio() == 0x0)
	 	  {
	 	  	  timer0_state = SWB_REV;
	 	  	  samplecnt = ((SAMPLE_RATE+1)>>1);
	 	  }
	 }
	 else if(timer0_state == SWB_REV)
	 {
	 	  samplecnt++;
	 	  if(samplecnt >=SAMPLE_RATE)
	 	  {
	 	  	  samplecnt = 0;
	 	  	  //clkcnt1 = 0;
	 	  		swb_datacnt++;
	 	  	  if(swb_datacnt > (timer0_revcycle+0)) //receive over
	 	  	  {
	 	  	  	   timer0_state = SWB_IDLE;
	 	  	  	   //===================user select timer============
	 	  	       TR0 = 0;  //disable timer0
	 	  	       ET0 = 0;  //disable timer0 interrupt
	 	  	       //================================================
	 	  	       timer0_transflag = TRANSFER_COMPLETE;  //
	 	  	       swb_datacnt = 0;
	 	  	  }
	 	  	  else
	 	  	  {
	 	  	     //===================user select onewire PIN============
	 	  	  	 timer0_revdata = (timer0_revdata<<1) | read_gpio();
	 	  	  	 //PA7 = ~PA7;
	 	  	  	 //======================================================
	 	  	  }
	 	  }
	 }
	 return;
}
