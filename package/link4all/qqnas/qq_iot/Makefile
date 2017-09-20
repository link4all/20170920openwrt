# keylicense 
SRC_PATH:=./KeySnLicense/src
SRC_FILES:=$(SRC_PATH)/hashmd5.cpp
SRC_FILES+=$(SRC_PATH)/SSLKernelItem.cpp
SRC_FILES+=$(SRC_PATH)/linux/main.cpp
INC_OPENSSL_PATH:=$(OPENSSL_PATH)/include
INC_PARA:=-I$(SRC_PATH) -I$(INC_OPENSSL_PATH)
LIB_OPENSSL_PATH:=$(OPENSSL_PATH)/lib
LIB_PARA:=-L$(LIB_OPENSSL_PATH)

#nassdk
OBJS	:= $(patsubst %.cpp, %.o, $(wildcard ./case/nas/NasSDK/*.cpp))
OBJS	+= $(patsubst %.cpp, %.o, $(wildcard ./case/nas/NasSDK/util/*.cpp))
OBJS	+= $(patsubst %.cpp, %.o, $(wildcard ./case/nas/NasSDK/ft_processor/*.cpp))
LIB     += -lpthread  -lrt -ldl
LIB     += -L./lib -ltxdevicesdk   # Tencent_iot_SDK/lib
INCLUDE += -I./case/nas/NasSDK
INCLUDE += -I./case/nas/include
INCLUDE += -I./include           # Tencent_iot_SDK/include
INCLUDE += -I./case/nas/NasSDK/util
INCLUDE += -I./case/nas/NasSDK/rapidjson
INCLUDE += -I./case/nas/NasSDK/ft_processor
CXXFLAGS+= -fpermissive -Wall -Wno-deprecated -Wno-conversion-null -fpermissive -Wno-format  -std=c++0x  -fPIC
CXXFLAGS += -g
CXXFLAGS += $(INCLUDE)
DEPS    += $(patsubst %.o, %.d, $(OBJS))


#demo
OBJS_demo := $(patsubst %.cpp, %.o, $(wildcard ./case/nas/Demo/*.cpp))
OBJS_demo += $(patsubst %.cpp, %.o, $(wildcard ./case/nas/Demo/util/*.cpp))
DEPS_demo    += $(patsubst %.o, %.dd, $(OBJS_demo))
LIB	+= -L./case/nas/lib -lnassdk
INCLUDE_demo += -I./case/nas/NasSDK
INCLUDE_demo += -I./case/nas/include
INCLUDE_demo += -I./include           # Tencent_iot_SDK/include
INCLUDE_demo += -I./case/nas/Demo/util
INCLUDE_demo += -I./case/nas/Demo/rapidjson
CXXFLAGS_demo +=  -fpermissive -Wall -Wno-deprecated -Wno-conversion-null -fpermissive -Wno-format  -std=c++0x -D_FILE_OFFSET_BITS=64
CXXFLAGS_demo += -g
CXXFLAGS_demo += $(INCLUDE_demo)

all: qq_license nassdk demo
	@echo build complete

qq_license:
	$(CC) $(SRC_FILES) -o ./qq_license $(INC_PARA) $(LIB_PARA) -O0 -g3 -ldl -lssl -lcrypto -lstdc++ -fPIC
	$(STRIP) qq_license

-include ./case/nas/NasSDK/ft_processor/ft_processor.mk
-include ./case/nas/NasSDK/util/util.mk
-include $(DEPS)
%.d: %.cpp
	@echo "make $@"
	@set -e $@ &&  rm -f $@; \
	$(CXX) -MM $(CFLAGS) $(CXXFLAGS) $< > $@; \



nassdk:$(DEPS) $(OBJS)
	$(CXX) -o libnassdk.so $(OBJS) $(LIB) -shared
	$(STRIP) libnassdk.so

-include ./case/nas/Demo/ft_processor/ft_processor.mk
-include ./case/nas/Demo/util/util.mk
-include $(DEPS_demo)
%.dd: %.cpp
	@echo "make $@"
	@set -e $@ &&  rm -f $@; \
	$(CXX) -MM $(CFLAGS) $(CXXFLAGS_demo) $< > $@; \

demo:$(OBJS_demo) $(LIB_demo)
	$(CXX) -o qqnas $(OBJS_demo) $(LIB)
	$(STRIP) qqnas

clean:
	-rm ./KeySnLicense/build/linux/output/qq_license ./KeySnLicense/build/linux/output/*.*
	-rm ./case/nas/NasSDK/*.d  ./case/nas/NasSDK/*.o ./case/nas/NasSDK/*.so 
	-rm ./case/nas/NasSDK/util/*.d  ./case/nas/NasSDK/util/*.o 
	-rm ./case/nas/NasSDK/ft_processor/*.d  ./case/nas/NasSDK/ft_processor/*.o 
	-rm ./case/nas/Demo/*.d  ./case/nas/Demo/*.o ./case/nas/Demo/qqnas ./case/nas/Demo/bin/
	-rm ./case/nas/Demo/util/*.d  ./case/nas/Demo/util/*.o 	




