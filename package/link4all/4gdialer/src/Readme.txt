1 首先按照ZTE提供的用户手册安装对应的驱动程序。驱动程序安装成功后会加载出网卡和USB串口设备。
2 在系统中安装udhcpc程序。
2 在该目录下使用make编译。
3 假定第一个USB转串口设备为/dev/ttyUSB0，网卡为usb0，则运行./welink-4g-test /dev/ttyUSB0 usb0