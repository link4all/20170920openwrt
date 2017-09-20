#include <stdio.h>
#include<stdlib.h>
#include <getopt.h>
#include <errno.h>
#include <fcntl.h>
#include <termios.h>
#include <string.h>



#define LOGI printf
#define LOGE printf
#define LOGD printf

#define MAX_AT_RESPONSE (8 * 1024)
#define AT_RSP_TIMEOUT -2
#define AT_SEND_ERROR -1
#define AT_RSP_ERROR -3

static char s_ATBuffer[MAX_AT_RESPONSE+1];
static char *s_ATBufferCur = s_ATBuffer;
static const char * s_device_path = NULL;
static const char * s_net_device_path = NULL;
static int s_readCount = 0;
int fd = -1;
char out_put[1024];




static void usage(char *s)
{
	fprintf(stderr, "usage: %s [-s <at port>] [-n net card device]\n", s);
	exit(-1);
}

static char * findNextEOL(char *cur)
{
    if (cur[0] == '>' && cur[1] == ' ' && cur[2] == '\0') {
        /* SMS prompt character...not \r terminated */
        return cur+2;
    }

    // Find next newline
    while (*cur != '\0' && *cur != '\r' && *cur != '\n') cur++;

    return *cur == '\0' ? NULL : cur;
}

static const char *readline()
{
    ssize_t count;

    char *p_read = NULL;
    char *p_eol = NULL;
    char *ret;

    /* this is a little odd. I use *s_ATBufferCur == 0 to
     * mean "buffer consumed completely". If it points to a character, than
     * the buffer continues until a \0
     */
    if (*s_ATBufferCur == '\0') {
        /* empty buffer */
        s_ATBufferCur = s_ATBuffer;
        *s_ATBufferCur = '\0';
        p_read = s_ATBuffer;
    } else {   /* *s_ATBufferCur != '\0' */
        /* there's data in the buffer from the last read */

        // skip over leading newlines
        while (*s_ATBufferCur == '\r' || *s_ATBufferCur == '\n')
            s_ATBufferCur++;

        p_eol = findNextEOL(s_ATBufferCur);

        if (p_eol == NULL) {
            /* a partial line. move it up and prepare to read more */
            size_t len;

            len = strlen(s_ATBufferCur);

            memmove(s_ATBuffer, s_ATBufferCur, len + 1);
            p_read = s_ATBuffer + len;
            s_ATBufferCur = s_ATBuffer;
        }
        /* Otherwise, (p_eol !- NULL) there is a complete line  */
        /* that will be returned the while () loop below        */
    }

    while (p_eol == NULL) {
        if (0 == MAX_AT_RESPONSE - (p_read - s_ATBuffer)) {
            LOGE("ERROR: Input line exceeded buffer\n");
            /* ditch buffer and start over again */
            s_ATBufferCur = s_ATBuffer;
            *s_ATBufferCur = '\0';
            p_read = s_ATBuffer;
        }

        do {
            count = read(fd, p_read,
                            MAX_AT_RESPONSE - (p_read - s_ATBuffer));
        } while (count < 0 && errno == EINTR);

        if (count > 0) {
            s_readCount += count;

            p_read[count] = '\0';

            // skip over leading newlines
            while (*s_ATBufferCur == '\r' || *s_ATBufferCur == '\n')
                s_ATBufferCur++;

            p_eol = findNextEOL(s_ATBufferCur);
            p_read += count;
        } else if (count <= 0) {
            /* read error encountered or EOF reached */
            if(count == 0) {
                LOGD("atchannel: EOF reached");
            } else {
                LOGD("atchannel: read error %s", strerror(errno));
            }
            return NULL;
        }
    }

    /* a full line in the buffer. Place a \0 over the \r and return */

    ret = s_ATBufferCur;
    *p_eol = '\0';
    s_ATBufferCur = p_eol + 1; /* this will always be <= p_read,    */
                              /* and there will be a \0 at *p_read */

    LOGD("AT< %s\n", ret);
    return ret;
}

static int writeline (const char *s)
{
    size_t cur = 0;
    size_t len = strlen(s);
    ssize_t written;

    if (fd< 0) {
        return -1;
    }

    LOGD("AT> %s\n", s);

    /* the main string */
    while (cur < len) {
        do {
            written = write (fd, s + cur, len - cur);
        } while (written < 0 && errno == EINTR);

        if (written < 0) {
            return -1;
        }

        cur += written;
    }

    /* the \r  */

    do {
        written = write (fd, "\r" , 1);
    } while ((written < 0 && errno == EINTR) || (written == 0));

    if (written < 0) {
        return -1;
    }

    return 0;
}

int strStartsWith(const char *line, const char *prefix)
{
    for ( ; *line != '\0' && *prefix != '\0' ; line++, prefix++) {
        if (*line != *prefix) {
            return 0;
        }
    }

    return *prefix == '\0';
}

int write_wait_read(const char *s, const char *r, char * output)
{
    char * line;
    int count = 0;
    int ret;
	
    ret = writeline(s);
        if(ret <0) return AT_SEND_ERROR;
	
    for(;;)
    {
        line = readline();
	 if(strStartsWith(line, r)){
            strcpy(output, line);
	     break;
	 }
	 /*else if(strStartsWith(line, "+CME ERROR")){
	     return AT_RSP_ERROR;
	 }	*/	 
	 else
	 {
	     count++;
	     sleep(1);
	 }
		
    }

    return 0;
}

/**
 * Starts tokenizing an AT response string
 * returns -1 if this is not a valid response string, 0 on success.
 * updates *p_cur with current position
 */
int at_tok_start(char **p_cur)
{
    if (*p_cur == NULL) {
        return -1;
    }

    // skip prefix
    // consume "^[^:]:"

    *p_cur = strchr(*p_cur, ':');

    if (*p_cur == NULL) {
        return -1;
    }

    (*p_cur)++;

    return 0;
}

static void skipWhiteSpace(char **p_cur)
{
    if (*p_cur == NULL) return;

    while (**p_cur != '\0' && isspace(**p_cur)) {
        (*p_cur)++;
    }
}

static void skipNextComma(char **p_cur)
{
    if (*p_cur == NULL) return;

    while (**p_cur != '\0' && **p_cur != ',') {
        (*p_cur)++;
    }

    if (**p_cur == ',') {
        (*p_cur)++;
    }
}

static char * nextTok(char **p_cur)
{
    char *ret = NULL;

    skipWhiteSpace(p_cur);

    if (*p_cur == NULL) {
        ret = NULL;
    } else if (**p_cur == '"') {
        (*p_cur)++;
        ret = strsep(p_cur, "\"");
        skipNextComma(p_cur);
    } else {
        ret = strsep(p_cur, ",");
    }

    return ret;
}


/**
 * Parses the next integer in the AT response line and places it in *p_out
 * returns 0 on success and -1 on fail
 * updates *p_cur
 * "base" is the same as the base param in strtol
 */

static int at_tok_nextint_base(char **p_cur, int *p_out, int base, int  uns)
{
    char *ret;

    if (*p_cur == NULL) {
        return -1;
    }

    ret = nextTok(p_cur);

    if (ret == NULL) {
        return -1;
    } else {
        long l;
        char *end;

        if (uns)
            l = strtoul(ret, &end, base);
        else
            l = strtol(ret, &end, base);

        *p_out = (int)l;

        if (end == ret) {
            return -1;
        }
    }

    return 0;
}

/**
 * Parses the next base 10 integer in the AT response line
 * and places it in *p_out
 * returns 0 on success and -1 on fail
 * updates *p_cur
 */
int at_tok_nextint(char **p_cur, int *p_out)
{
    return at_tok_nextint_base(p_cur, p_out, 10, 0);
}

/**
 * Parses the next base 16 integer in the AT response line
 * and places it in *p_out
 * returns 0 on success and -1 on fail
 * updates *p_cur
 */
int at_tok_nexthexint(char **p_cur, int *p_out)
{
    return at_tok_nextint_base(p_cur, p_out, 16, 1);
}


int ParseRegistrationState(char * line)
{
    int err;
    int srv_status, srv_domain;
    char * responseStr[4];
    const char *cmd;
    const char *prefix;
    char *p;
    int commas;
    int skip;
    int count = 3;
    err = at_tok_start(&line);
    if (err < 0) goto error;
	
    err = at_tok_nextint(&line, &srv_status);
    if (err < 0) goto error;
    err = at_tok_nextint(&line, &srv_domain);
    if (err < 0) goto error;
	
    if((srv_status == 2)&&((srv_domain == 2)||(srv_domain == 4)))
    {
        return 1;
    }
    else
    {

        return 0;
    }
	
error:
    return -1;
}

int main (int argc, char **argv)
{
	int ret;
	int opt;
        char * cmd = NULL;
	
	while ( -1 != (opt = getopt(argc, argv, "s:n:"))) {
		switch (opt) {
			case 's':
				s_device_path = optarg;
				LOGI("==>s_device_path = %s\n", s_device_path);
				break;

			case 'n':
				s_net_device_path = optarg;
				LOGI("==>s_net_device_path = %s\n", s_net_device_path);
				break;

			default:
				usage(argv[0]);
		}
	}
	fd = open (s_device_path, O_RDWR);
	LOGI("==>opening port %s\n", s_device_path);
	if (fd < 0)
	LOGE("==>Error On open:%s", s_device_path);
       if (fd >= 0) {
           /* disable echo on serial ports */
           struct termios  ios;
           tcgetattr( fd, &ios );
           ios.c_lflag = 0;  /* disable ECHO, ICANON, etc... */
           tcsetattr( fd, TCSANOW, &ios );
       }
       ret = write_wait_read("AT+CFUN=1", "OK", out_put);
	if(ret<0) 
	{
	    LOGI("==>modem can not be enabled\n");
	    goto error;  
	}
	
	ret = write_wait_read("AT+CPIN?", "+CPIN: READY", out_put);
	if(ret<0) 
	{
	    LOGI("==>sim card not ready\n");
	    goto error; 
	}
       sleep(1);
	for(;;)
	{
           ret = write_wait_read("AT^SYSINFO", "^SYSINFO", out_put);
	    if(ret<0) goto error;  
	    ret = ParseRegistrationState(out_put);
	    if(ret != 1)
	    {
	        LOGI("==>waiting modem register .... \n");
	        sleep(2);
	    }
	    else
	    {
	        LOGI("==>modem register successful!\n");
	        break;
	    }
	}
	 sleep(1);
       ret = write_wait_read("AT+CGACT=1,1", "OK", out_put);
	if(ret<0) {
	    LOGI("==>modem dial failed!\n");
	    goto error;
	}   	   
       sleep(1);
       ret = write_wait_read("AT+ZGACT=1,1", "OK", out_put);
	if(ret<0) {
           LOGI("==>modem dial failed!\n");
	    goto error;
	}
	LOGI("==>modem dial successful!\n");
	sleep(2);
        asprintf(&cmd,"udhcpc -i %s", s_net_device_path);
        system(cmd);	
	return 0;
	
	error:
	return -1;
}
