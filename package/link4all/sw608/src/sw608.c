/*************************************************************************
	> File Name: ds18b20.c
	> Author: Osama 
	> Mail: 822741550@qq.com 
	> Created Time: Tue 07 Apr 2015 04:14:05 PM CST
 ************************************************************************/
#include <linux/mm.h>
#include <linux/miscdevice.h>
#include <linux/slab.h>
#include <linux/vmalloc.h>
#include <linux/mman.h>
#include <linux/random.h>
#include <linux/init.h>
#include <linux/raw.h>
#include <linux/tty.h>
#include <linux/capability.h>
#include <linux/ptrace.h>
#include <linux/device.h>
#include <linux/highmem.h>
#include <linux/crash_dump.h>
#include <linux/backing-dev.h>
#include <linux/bootmem.h>
#include <linux/splice.h>
#include <linux/pfn.h>
#include <linux/export.h>
#include <linux/io.h>
#include <linux/aio.h>
#include <linux/kernel.h>
#include <linux/module.h>
#include <asm/uaccess.h>

//定义DS18b20端口控制


#define DS18B20_L 		*GPIO27_22_DATA &= ~ (1<<4)  //让数据线输出低电平
#define DS18B20_H 		*GPIO27_22_DATA |=   (1<<4)  //让数据线输出高电平
#define DS18B20_OUT 	*GPIO27_22_DIR  |=   (1<<4)   //将数据线设置为输出
#define DS18B20_IN	 	*GPIO27_22_DIR  &=  ~(1<<4)   //将数据线设置为输入

#define DS18B20_STA		(*GPIO27_22_DATA>>4)&0X01     //读数据线状态
volatile unsigned long *GPIOMODE;
volatile unsigned long *GPIO27_22_DIR;
volatile unsigned long *GPIO27_22_DATA;

static struct class *ds18b20_drv_class;
static int major;

static unsigned char reset_ds18b20(void)
{
	unsigned char ret;
	DS18B20_OUT;
	DS18B20_H;
	DS18B20_L;			// 将数据线拉低
	udelay(700);			// 至少拉低480us，为了保险起见，我们拉低了700us
	DS18B20_H;			// 释放数据线
	udelay(75);			// 应该等待15~60us，为了保险起见，我们等待了75us

	DS18B20_IN;			// 将GPIO26设置为输入，用于监测存在脉冲
	ret = DS18B20_STA;
	DS18B20_OUT;

	udelay(400);			// 为了让DS18B20释放数据线，我们至少应该延时240us
	DS18B20_H;			// 释放总线

	return ret;
}
static void write_bit(unsigned char dat)
{
	DS18B20_OUT;
	DS18B20_H;			// 数据线输出高电平
	DS18B20_L;			// 将数据线拉低
	udelay(5);			// 应该拉低1~15us，用于告诉DS18B20，主机将要给你写数据

	if(dat)
	{
		DS18B20_H;		// 写1
	}
	else
	{
		DS18B20_L;		// 写0
	}
	udelay(60);			// 电平保持时间应该足够，以便DS18B20完成采样

	DS18B20_H;			// 释放总线
}
static void send_cmd(unsigned char cmd)
{
char i=0;

	while(i++ < 8)
	{
		write_bit(cmd&0x1);		// 从最低位开始发
		cmd >>= 1;
	}
}
static unsigned char read_bit()
{
unsigned char ret;

	DS18B20_OUT;
	DS18B20_H;			// 数据线输出高电平
	DS18B20_L;			// 将数据线拉低
	udelay(5);			// 应该拉低1~15us，用于告诉DS18B20，主机将要读数据
	DS18B20_H;			// 释放总线

	udelay(10);			// 为了让我们读取的值准确
	DS18B20_IN;			// 将GPIO26设置为输入，用于监测存在脉冲
	ret = DS18B20_STA;	// 读取数据线的状态
	udelay(60);			// 为了能让DS18B20释放总线
	DS18B20_OUT;

	DS18B20_H;			// 释放总线

	return ret;
}
static unsigned char read_byte()
{
	char i=0;
	unsigned char dat = 0;

	for(i=0;i<8;i++)
	{
		dat >>= 1;		// 最先读取的是最低位
		if(read_bit())
			dat |= 0x80;
	}

	return dat;
}
static unsigned int read_tamp(void)
{
	unsigned char a=0, b=0;
	unsigned int t;

	if(reset_ds18b20())
	{
		printk("reset_ds18b20 error\n");
		return 0;
	}
	send_cmd(0xcc);		// 跳过ROM
	send_cmd(0x44);		// 启动温度转换
	if(reset_ds18b20())
	{
		printk("reset_ds18b20 error\n");
		return 0;
	}
	send_cmd(0xcc);		// 跳过ROM
	send_cmd(0xbe);		// 读取暂存器
	a = read_byte();		// 读取暂存器第0字节的数据
	b = read_byte();		// 读取暂存器第1字节的数据
	t = b;
	t <<= 8;
	t = t|a;

	return t;
}
static int ds18b20_drv_open(struct inode *inode, struct file *file)
{
	//设置相应GPIO
	*GPIOMODE |= (0x01 << 14);
	//设置数据线为输出
	DS18B20_OUT;
	return 0;
}
static ssize_t ds18b20_drv_read(struct file *file, const char __user *buf, size_t size, loff_t *ppos)
{
	unsigned int temp;
	temp = read_tamp();
	copy_to_user(buf,&temp,4);

	return 4;
}
static ssize_t ds18b20_drv_write(struct file *file, const char __user *buf, size_t size, loff_t *ppos)
{

	return 1;
}

/* 1.分配、设置一个file_operations结构体 */
static struct file_operations ds18b20_drv_fops = {
	.owner   			= THIS_MODULE,    				/* 这是一个宏，推向编译模块时自动创建的__this_module变量 */
	.open    			= ds18b20_drv_open,
	.write				= ds18b20_drv_write,
	.read				=ds18b20_drv_read,
};


static int __init ds18b20_drv_init(void)
{
	/* 2.注册 */
	major = register_chrdev(0, "ds18b20_drv", &ds18b20_drv_fops);

	/* 3.自动创建设备节点 */
	/* 创建类 */
	ds18b20_drv_class = class_create(THIS_MODULE, "ds18b20");
	/* 类下面创建设备节点 */
	device_create(ds18b20_drv_class, NULL, MKDEV(major, 0), NULL, "ds18b20");		// /dev/ds18b20

	/* 4.硬件相关的操作 */
	/* 映射寄存器的地址 */
	GPIOMODE = (volatile unsigned long *)ioremap(0x10000060, 4);
	GPIO27_22_DIR = (volatile unsigned long *)ioremap(0x10000674, 4);
	GPIO27_22_DATA = (volatile unsigned long *)ioremap(0x10000670, 4);

	return 0;
}

static void __exit ds18b20_drv_exit(void)
{
	unregister_chrdev(major, "ds18b20_drv");
	device_destroy(ds18b20_drv_class, MKDEV(major, 0));
	class_destroy(ds18b20_drv_class);
	iounmap(GPIOMODE);
	iounmap(GPIO27_22_DIR);
	iounmap(GPIO27_22_DATA);
}

module_init(ds18b20_drv_init);
module_exit(ds18b20_drv_exit);

MODULE_LICENSE("GPL");




