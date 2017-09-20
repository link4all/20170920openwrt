override DIR_CUR:=$(shell pwd)
#CC:=gcc
#modify by openwrt
#CC=/home/david/trunk43375/widora/staging_dir/toolchain-mipsel_24kec+dsp_gcc-4.8-linaro_uClibc-0.9.33.2/bin/mipsel-openwrt-linux-gcc
#export STAGING_DIR=/home/david/trunk43375/widora/staging_dir/toolchain-mipsel_24kec+dsp_gcc-4.8-linaro_uClibc-0.9.33.2/

# source path
SRC_PATH:=$(DIR_CUR)/../../src

# openssl path 
# change OPENSSL_PATH to $(DIR_CUR)/../../third_part/openssl-x64 if the system is 64bit
OPENSSL_PATH:=$(DIR_CUR)/../../third_part/openssl

# include
# change openssl path to if the system is 64bit
INC_OPENSSL_PATH:=$(OPENSSL_PATH)/include
INC_PARA:=-I$(SRC_PATH) -I$(INC_OPENSSL_PATH)

# library 
LIB_OPENSSL_PATH:=$(OPENSSL_PATH)/lib
LIB_PARA:=-L$(LIB_OPENSSL_PATH)
#modify by openwrt 
#LIB_PARA+=-L/home/david/trunk43375/widora/staging_dir/target-mipsel_24kec+dsp_uClibc-0.9.33.2/usr/lib/

# output path
OUTPUT_PATH:=$(DIR_CUR)/output

# source files 
SRC_FILES:=$(SRC_PATH)/hashmd5.cpp
SRC_FILES+=$(SRC_PATH)/SSLKernelItem.cpp
SRC_FILES+=$(SRC_PATH)/linux/main.cpp

all:ECC
	@echo build complete
	cp $(OUTPUT_PATH)/qq_license ../../../../files/bin/

clean:
	-rm $(OUTPUT_PATH)/qq_license $(OUTPUT_PATH)/*.*

ECC:$(SRC_FILES)
	$(CC) $(SRC_FILES) -o $(OUTPUT_PATH)/qq_license $(INC_PARA) $(LIB_PARA) -O0 -g3 -ldl -lssl -lcrypto -lstdc++ -fPIC
