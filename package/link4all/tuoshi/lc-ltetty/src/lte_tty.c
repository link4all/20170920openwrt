#include <linux/kernel.h>
#include <linux/errno.h>
#include <linux/slab.h>
#include <linux/tty.h>
#include <linux/tty_flip.h>
#include <linux/module.h>
#include <linux/moduleparam.h>
#include <linux/usb.h>
#include <linux/usb/serial.h>
#include <linux/uaccess.h>

#ifndef CONFIG_USB_SERIAL_GENERIC
#  error "this module depends on the generic usb serial module."
#endif

#define DRIVER_AUTHOR "drivercoding"
#define DRIVER_DESC "USB serial driver for leadcore LTE device"

int debug = 1;

module_param(debug, bool, S_IRUGO | S_IWUSR);
MODULE_PARM_DESC(debug, "Debug enabled or not");

static struct usb_device_id ltetty_serial_ids[] = {
	// leadcore lte device
	{ USB_DEVICE(0x1ab7, 0x5160), },
	{ USB_DEVICE(0x1ab7, 0x6160), },
	{ USB_DEVICE(0x1ab7, 0x1761), },
	{ USB_DEVICE(0x1ab7, 0x1766), },
	{ USB_DEVICE(0x1ab7, 0x1768), },
	{}
};


static int ltetty_probe(struct usb_interface *interface, const struct usb_device_id *id)
{
	struct usb_device *dev;
	const struct usb_device_id *id_pattern;
	__u8 bInterfaceNumber = interface->cur_altsetting->desc.bInterfaceNumber;
	
	dev = interface_to_usbdev(interface);
	if (!dev)
	{
		printk("%s : interface_to_usbdev failed.\n", __func__);
		return -ENODEV;
	}

	printk("%s : usb\\vid_%04x&pid_%04x&mi_%02x\n", 
		__func__,
		le16_to_cpu(dev->descriptor.idVendor),
		le16_to_cpu(dev->descriptor.idProduct),
		bInterfaceNumber);

	// 1ab7_1761
	if ((le16_to_cpu(dev->descriptor.idVendor) == 0x1ab7) && 
		  (le16_to_cpu(dev->descriptor.idProduct) == 0x1761))
	{
		if ((bInterfaceNumber == 0x02) || 
			  (bInterfaceNumber == 0x03) || 
			  (bInterfaceNumber == 0x04))
		{
			printk("%s : match interfacenumber success.\n", __func__);
			return usb_serial_probe(interface, id);
		}
	}

	// 1ab7_1766
	if ((le16_to_cpu(dev->descriptor.idVendor) == 0x1ab7) && 
		  (le16_to_cpu(dev->descriptor.idProduct) == 0x1766))
	{
		if ((bInterfaceNumber == 0x03) || 
			  (bInterfaceNumber == 0x04))
		{
			printk("%s : match interfacenumber success.\n", __func__);
			return usb_serial_probe(interface, id);
		}
	}

	// 1ab7_1768
	if ((le16_to_cpu(dev->descriptor.idVendor) == 0x1ab7) && 
		  (le16_to_cpu(dev->descriptor.idProduct) == 0x1768))
	{
		if ((bInterfaceNumber == 0x03) || 
			  (bInterfaceNumber == 0x04))
		{
			printk("%s : match interfacenumber success.\n", __func__);
			return usb_serial_probe(interface, id);
		}
	}
		
	//id_pattern = usb_match_id(interface, ltetty_serial_ids);
	//if (id_pattern != NULL)
	//	return usb_serial_probe(interface, id);

	return -ENODEV;
}



static struct usb_driver ltetty_driver = {
	.name = "usbserial_ltetty",
	.probe = ltetty_probe,
	.disconnect = usb_serial_disconnect,
	.id_table =	ltetty_serial_ids,
	.no_dynamic_id =	1,
};


static struct usb_serial_driver ltetty_device = {
	.driver = {
		.owner = THIS_MODULE,
		.name = "ltetty",
	},
	.id_table = ltetty_serial_ids,
	.usb_driver = &ltetty_driver,
	.num_ports = 1,
	.resume = usb_serial_generic_resume,
};


static int __init ltetty_init(void)
{
	int retval = 0;

	dbg("-> %s\n", __func__);

	retval = usb_serial_register(&ltetty_device);
	if (retval) {
		dbg("register ltetty_device failed, retval(%d)\n", retval);
		goto exit;
	}

	retval = usb_register(&ltetty_driver);
	if (retval) {
		dbg("register ltetty_driver failed, retval(%d)\n", retval);
		usb_serial_deregister(&ltetty_device);
		goto exit;
	}

exit:
	return retval;
}


static void __exit ltetty_exit(void)
{
	dbg("-> %s\n", __func__);

	usb_deregister(&ltetty_driver);
	usb_serial_deregister(&ltetty_device);
}


module_init(ltetty_init);
module_exit(ltetty_exit);


/* Module information */
MODULE_AUTHOR(DRIVER_AUTHOR);
MODULE_DESCRIPTION(DRIVER_DESC);
MODULE_LICENSE("GPL");
