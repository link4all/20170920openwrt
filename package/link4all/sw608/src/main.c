/*
 * =====================================================================================
 *
 *  Filename:  main.c
 *  Author: manfeel@foxmail.com
 * =====================================================================================
 */

#include<stdio.h>
#include<string.h>
#include<pthread.h>
#include<stdlib.h>
#include<unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include "hardware.h"


pthread_t tid;

void* loop(void *arg) {
    while(1) {
        ISR_TIMER0();
    }

    return NULL;
}


void open_gpio() {
    int fd;


    fd = open("/sys/class/gpio/export", O_WRONLY);

    sprintf(buf, "%d", PIN); 

    write(fd, buf, strlen(buf));

    close(fd);
}

// 1: output, 0:input
void set_gpio_output(int dir) {
    sprintf(buf, "/sys/class/gpio/gpio%d/direction", PIN);

    int fd = open(buf, O_WRONLY);

    if(dir)
        write(fd, "out", 3); 
    else
        write(fd, "in", 2); 

    close(fd);
}

void write_gpio(BYTE val) {
    sprintf(buf, "/sys/class/gpio/gpio%d/value", PIN);

    int fd = open(buf, O_WRONLY);

    if(val)
        write(fd, "1", 1); 
    else 
        write(fd, "0", 1); 

    close(fd);
}

BYTE read_gpio() {
    char value;

    sprintf(buf, "/sys/class/gpio/gpio%d/value", PIN);

    int fd = open(buf, O_RDONLY);

    read(fd, &value, 1);

    close(fd);
    return value=='1' ? 1:0;
}


int main(int argc, char** argv)
{
    int i = 0;
    int err;
    open_gpio();

    // config cycle1 to 2
    onewire_config(20);

    err = pthread_create(&tid, NULL, &loop, NULL);
    if (err != 0)
        printf("\ncan't create thread :[%s]", strerror(err));
    else
        printf("\n Thread created successfully\n");

    getchar();
        
    char rd_data;
    char flag = 0;

    BYTE reg = strtol(argv[1], NULL, 16);
    printf("reg = %X\n", reg);
    onewire_read_byte(reg,&rd_data,&flag);
    
    printf("\n%X\n",rd_data);

    getchar();
    return 0;
}


