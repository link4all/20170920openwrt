################OPTION###################
#export STAGING_DIR=/home/david/trunk43375/staging_dir/

OPTION =
#CC = /home/david/trunk43375/staging_dir/toolchain-mipsel_24kec+dsp_gcc-4.8-linaro_uClibc-0.9.33.2/bin/mipsel-openwrt-linux-
CCOMPILE = $(CC)
CPPCOMPILE = 
COMPILEOPTION =
#/home/staging_dir/toolchain-mips_34kc_gcc-4.8-linaro_uClibc-0.9.33.2/bin/mips-openwrt-linux-gcc
LINK = $(CC)
#LINKOPTION = -o client -lpthread 
CFLAGS = 
OBJS =  client.o config.o common_utils.o string_utils.o getmac.o socket_connect_create.o send_heart_beat.o send_terminal_mac.o send_ap_mac.o  
OUTPUT = client

#OTHERFILE = 



################OPTION END################

$(OUTPUT):$(OBJS) $(APPENDLIB)
	$(LINK)  -o client $(LIBDIRS)   $(OBJS) $(SHAREDLIB) $(APPENDLIB) $(CFLAGS) -lpthread
	rm -rf $(OBJS) 
	
clean: 
	rm -rf $(OUTPUT) $(OTHERFILE) $(OBJS) 
all: clean $(OUTPUT)
.PRECIOUS:%.cpp %.c %.C
.SUFFIXES:
.SUFFIXES:  .c .o .cpp .ecpp .pc .ec .C .cc .cxx .h .y


.cpp.o:
	$(CPPCOMPILE) -c -o $*.o $(COMPILEOPTION) $(INCLUDEDIR)  $*.cpp
	
.cc.o:
	$(CCOMPILE) -c -o $*.o $(COMPILEOPTION) $(INCLUDEDIR)  $*.cpp

.cxx.o:
	$(CPPCOMPILE) -c -o $*.o $(COMPILEOPTION) $(INCLUDEDIR)  $*.cpp

.c.o:
	$(CCOMPILE) -c -o $*.o  $(COMPILEOPTION) $(INCLUDEDIR) $*.c

.C.o:
	$(CPPCOMPILE) -c -o $*.o $(COMPILEOPTION) $(INCLUDEDIR) $*.C	
	
