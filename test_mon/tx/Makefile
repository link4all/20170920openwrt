################OPTION###################
#export STAGING_DIR=/home/staging_dir/

OPTION =
CC = mips-openwrt-linux-
CCOMPILE = $(CC)gcc 
CPPCOMPILE = 
COMPILEOPTION =
#/home/staging_dir/toolchain-mips_34kc_gcc-4.8-linaro_uClibc-0.9.33.2/bin/mips-openwrt-linux-gcc
LINK = $(CCOMPILE)
LINKOPTION = -o wifi_probe_req_flood 
CFLAGS = 
OBJS =  wifi_probe_req_flood.o make_packet.o 
OUTPUT = wifi_probe_req_flood
INCLUDEDIR = -I ./include/pcap/ -lpcap  -L ./lib
SHAREDLIB = -lpthread -ldl -lpcap -I ./include/pcap/ -lpcap  -L ./lib
OTHERFILE = 



################OPTION END################

$(OUTPUT):$(OBJS) $(APPENDLIB)
	$(LINK)  $(LINKOPTION)  $(LIBDIRS)   $(OBJS) $(SHAREDLIB) $(APPENDLIB) $(CFLAGS) 
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
	$(CCOMPILE) -c -o $*.o $(COMPILEOPTION) $(INCLUDEDIR) $*.c

.C.o:
	$(CPPCOMPILE) -c -o $*.o $(COMPILEOPTION) $(INCLUDEDIR) $*.C	
	
