腾讯 QQ 物联设备SDK能够嵌入到arm-linux平台、mips-linux平台和RTOS平台，提供音视频能力，消息能力和控制信令能力。将设备注册到QQ平台后，QQ用户就能够用手机和设备进行音视频通话，发送消息和触发控制信令等。

更多信息可以访问 QQ物联资料库 网址：
http://iot.open.qq.com/wiki/index.html#!CASE/IP_Camera.md

SDK 下载页面网址：
Linux SDK：http://iot.open.qq.com/wiki/index.html#!SDK/Linux.md
Android SDK：http://iot.open.qq.com/wiki/index.html#!SDK/Android.md
RTOS SDK：http://iot.open.qq.com/wiki/index.html#!SDK/RTOS.md

@description
（1）将在官网上注册设备时，下载好的服务器公钥拷贝到当前目录下；

（2）将在官网注册时，产生的设备PID填到源文件initDevice读取服务器公钥和设备基本信息对应位置；

（3）在官网注册时，使用key_tools工具利用产品私钥产生一对GUID和licence文件拷贝到当前目录下，注意GUID和licence文件的对应，并重命名为GUID_file.txt和licence.sign.file.txt。

（4）修改环境变量：export LD_LIBRARY_PATH=“./lib”

（5）执行make命令；

（6）运行目标文件，./SDKDemo_bind，在手Q与设备处于同一局域网的情况下，发现并绑定设备，之后输入quit退出，运行./SDKDemo_video，在手Q端点开视频通话，可以看到设备的视频通话。

（7）创建recv目录，然后，运行./SDKDemo_filetransfer，手Q给设备发送一条语音消息
