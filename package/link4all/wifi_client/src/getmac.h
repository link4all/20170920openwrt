#ifndef __GETMAC_H__
#define __GETMAC_H__
int get_mac(const char* netcard_name, u_char *addr);
int get_format_mac(const char* netcard_name, u_char *addr);
#endif
