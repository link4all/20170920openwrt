#include <stdio.h>
#include <string.h>
#include <stdbool.h> 

#include "common_utils.h"

void print_mac(unsigned char *mac)
{
	printf("%02x:%02x:%02x:%02x:%02x:%02x\n", mac[0], mac[1], mac[2], mac[3], mac[4], mac[5]);
}

int mac_str_to_char_array(char *str, unsigned char *mac)
{
    int i;
	char *s = (char *) str;
    char *e;
    if ((mac == NULL) || (str == NULL)) {
        return -1;
    }
    for (i = 0; i < 6; ++i) {
        mac[i] = s ? strtoul(s, &e, 16) : 0;
        if (s)
            s = (*e) ? e + 1 : e;
    }
    return 0;
}