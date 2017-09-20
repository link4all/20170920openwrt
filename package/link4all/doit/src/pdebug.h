#ifndef PDEBUG_DEFINATION_H
#define PDEBUG_DEFINATION_H

#ifdef DEBUG
#define PDEBUG(fmt, ...)	fprintf(stderr, fmt, ## __VA_ARGS__)
#define PDEBUG_ERRNO(cond)	do {			\
		if (cond) PDEBUG("\n");			\
		else PDEBUG(": %s\n", strerror(errno));	\
	} while (0)
#else
#define PDEBUG(fmt, ...)	(void)0
#define PDEBUG_ERRNO(cond)	(void)0
#endif

#endif
