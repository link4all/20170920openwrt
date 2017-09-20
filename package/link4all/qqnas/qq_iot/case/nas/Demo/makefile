#TARGETS := NasSDKDemo
TARGETS := qqnas

OBJS	:= $(patsubst %.cpp, %.o, $(wildcard *.cpp))
#CROSS   := 
#CROSS   := /home/david/trunk43375/widora/staging_dir/toolchain-mipsel_24kec+dsp_gcc-4.8-linaro_uClibc-0.9.33.2/bin/mipsel-openwrt-linux-

#openwrt 
#export STAGING_DIR=/home/david/trunk43375/widora/staging_dir/toolchain-mipsel_24kec+dsp_gcc-4.8-linaro_uClibc-0.9.33.2


#需要包含的头文件搜索路径
#INCLUDE += -I../../../include   #txdevicesdk headers
#INCLUDE += -I../include         #libnassdk.so headers
#INCLUDE += -I./util
#INCLUDE += -I./rapidjson
#INCLUDE += -I./
#INCLUDE += -I/usr/include
#INCLUDE += -I/home/david/trunk43375/widora/staging_dir/target-mipsel_24kec+dsp_uClibc-0.9.33.2/usr/include/
INCLUDE += -I./case/nas/NasSDK
INCLUDE += -I./case/nas/include
INCLUDE += -I./include           # Tencent_iot_SDK/include
INCLUDE += -I./case/nas/Demo/util
INCLUDE += -I./case/nas/Demo/rapidjson

#需要引用的库
#LIB     += -L/home/david/trunk43375/widora/staging_dir/target-mipsel_24kec+dsp_uClibc-0.9.33.2/usr/lib/
#LIB     += -L../../../lib -ltxdevicesdk  
#LIB     += -L../../../lib_x86 -ltxdevicesdk  
#LIB	+= -L../lib -lnassdk
LIB     += -lpthread  -lrt 
LIB     += -L./lib -ltxdevicesdk   # Tencent_iot_SDK/lib
LIB	+= -L./case/nas/lib -lnassdk
 

#需要的标志位
#CXX	:= $(CROSS)g++
#STRIP	:= $(CROSS)strip
CXXFLAGS+= -fpermissive -Wall -Wno-deprecated -Wno-conversion-null -fpermissive -Wno-format -std=c++0x -D_FILE_OFFSET_BITS=64
CXXFLAGS += -g
#增加根据d文件自动推导编译的标志
CXXFLAGS    += $(INCLUDE)



-include util/util.mk

#deps
DEPS    += $(patsubst %.o, %.d, $(OBJS))

.PHONY: all
all: $(DEPS) $(OBJS)
	$(CXX) -o $(TARGETS) $(OBJS) $(LIB)
	$(STRIP) $(TARGETS)

-include $(DEPS)

%.d: %.cpp
	@echo "make $@"
	@set -e $@ &&  rm -f $@; \
	$(CXX) -MM $(CFLAGS) $(CXXFLAGS) $< > $@; \

.PHONY:clean
clean:
	rm -rf $(TARGETS) $(OBJS) $(DEPS)

