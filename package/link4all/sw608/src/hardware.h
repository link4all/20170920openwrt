typedef unsigned char BYTE;
typedef unsigned short WORD;
typedef unsigned int DWORD;

BYTE onewire_config(BYTE onewire_clk);
BYTE onewire_write_byte(BYTE regaddr, BYTE wr_data, BYTE *flag);
BYTE onewire_read_byte(BYTE regaddr, BYTE *rd_data, BYTE *flag);

BYTE EvenParity(BYTE opdata);
BYTE BitAnti(BYTE opdata, BYTE loc);
BYTE GetBits(BYTE opdata, BYTE loc, BYTE len);

void ISR_TIMER0(void);



char buf[256]; 

#define PIN (43)

void set_gpio_output(int dir);
void write_gpio(BYTE val);
BYTE read_gpio();
