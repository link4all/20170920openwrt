#ifndef __MAKE_PACKET_H__
#define __MAKE_PACKET_H__

// #include "include/pcap/pcap.h"
#include <pcap/pcap.h>
// #include <pcap.h>

static pcap_t *m_lpHandle;
int pcap_open(const char * nice);
int pcap_send(char *buf, int len);

void generate_probe_req(char *buf, int len);
void print_buffer(char *buf, int len);
#endif
