/*
 * Copyright (c) 1988, 1989, 1990, 1991, 1992, 1993, 1994, 1995, 1996, 1997, 2000
 *	The Regents of the University of California.  All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that: (1) source code distributions
 * retain the above copyright notice and this paragraph in its entirety, (2)
 * distributions including binary code include the above copyright notice and
 * this paragraph in its entirety in the documentation or other materials
 * provided with the distribution, and (3) all advertising materials mentioning
 * features or use of this software display the following acknowledgement:
 * ``This product includes software developed by the University of California,
 * Lawrence Berkeley Laboratory and its contributors.'' Neither the name of
 * the University nor the names of its contributors may be used to endorse
 * or promote products derived from this software without specific prior
 * written permission.
 * THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY EXPRESS OR IMPLIED
 * WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.
 */

#ifndef lint
static const char copyright[] =
    "@(#) Copyright (c) 1988, 1989, 1990, 1991, 1992, 1993, 1994, 1995, 1996, 1997, 2000\n\
The Regents of the University of California.  All rights reserved.\n";
#endif

#include <pcap.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>
#include <unistd.h>
#include <errno.h>
#include <pthread.h>
#define MAXIMUM_SNAPLEN		65535

static char *program_name;

/* Forwards */
static void usage(void) __attribute__((noreturn));
static void error(const char *, ...);
static void warning(const char *, ...);

extern int optind;
extern int opterr;
extern char *optarg;
int count=0;

void thread(void)
{
        int i;

         int starting_time = 1;
        int last_count = 0;
        while(1){
                printf("cur: %d packets/s  avg %d packets/s\n", count-last_count, count/starting_time++);
                last_count = count;
                sleep(1);
        }

}


void getPacket()
{
  count++;
}


int
main(int argc, char **argv)
{
	register int op;
	register char *cp, *device;
	int dorfmon, dopromisc, snaplen, useactivate, bufsize;
	char ebuf[256];
	pcap_t *pd;
	int status = 0;

	device = NULL;
	dorfmon = 0;
	dopromisc = 0;
	snaplen = 65535;
	bufsize = 0;
	useactivate = 0;
	pthread_t idd;
        int i,ret;
	int id = 0;
        ret=pthread_create(&idd,NULL,(void *) thread,NULL);

	printf("pcap_create \n");
	printf("argv[1] =====%s\n",argv[1]);
	pd = pcap_create(argv[1], ebuf);
	if (pd == NULL)
		printf("creat error \n");
	printf("pcap_set_snaplen \n");
	status = pcap_set_snaplen(pd, snaplen);
	if (status != 0)
		printf("pcap_set_snaplen  error\n");
	status = pcap_set_promisc(pd, 1);
	status = pcap_set_rfmon(pd, 1);
	printf("pcap_set_buffer_size \n");
	status = pcap_set_buffer_size(pd, 4*1024*1024);
	if (status != 0)
		printf("pcap_set_buffer_size error\n");
	//	}
	status = pcap_activate(pd);
	if (status < 0) {
		/*
		 * pcap_activate() failed.
		 */
		printf("pcap_activate NOT  OK \n!!");
	} else if (status > 0) {
		/*
		 * pcap_activate() succeeded, but it's warning us
		 * of a problem it had.
		 */
		printf("pcap_activate OK \n!!");
	}
	pcap_loop(pd, -1, getPacket, (u_char*)&id);
	printf("pcap_close \n");
	pcap_close(pd);
	exit(status < 0 ? 1 : 0);
}

static void
usage(void)
{
	(void)fprintf(stderr,
	    "Usage: %s [ -Ipa ] [ -i interface ] [ -s snaplen ] [ -B bufsize ]\n",
	    program_name);
	exit(1);
}

/* VARARGS */
static void
error(const char *fmt, ...)
{
	va_list ap;

	(void)fprintf(stderr, "%s: ", program_name);
	va_start(ap, fmt);
	(void)vfprintf(stderr, fmt, ap);
	va_end(ap);
	if (*fmt) {
		fmt += strlen(fmt);
		if (fmt[-1] != '\n')
			(void)fputc('\n', stderr);
	}
	exit(1);
	/* NOTREACHED */
}

/* VARARGS */
static void
warning(const char *fmt, ...)
{
	va_list ap;

	(void)fprintf(stderr, "%s: WARNING: ", program_name);
	va_start(ap, fmt);
	(void)vfprintf(stderr, fmt, ap);
	va_end(ap);
	if (*fmt) {
		fmt += strlen(fmt);
		if (fmt[-1] != '\n')
			(void)fputc('\n', stderr);
	}
}
