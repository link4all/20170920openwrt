################OPTION###################
#export STAGING_DIR=/home/staging_dir/

LDFLAGS += -lpcap -lpthread 

all:wifi_probe_req_flood collection_packet

wifi_probe_req_flood:
	$(CC)  wifi_probe_req_flood.c make_packet.c -o wifi_probe_req_flood ${CFLAGS} ${LDFLAGS}

collection_packet: collection_packet.o
	$(CC)  collection_packet.c -o collection_packet ${CFLAGS} ${LDFLAGS}



clean:
	rm -rf collection_packet wifi_probe_req_flood *.o





