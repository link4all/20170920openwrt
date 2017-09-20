# build helloworld executable when user executes "make"
udp_client: udp_client.o
	$(CXX) $(LDFLAGS) udp_client.o -o udp_client 
	$(CXX) $(LDFLAGS) udp_server.o -o udp_server
udp_client.o: udp_client.c
	$(CXX) $(CFLAGS) -c udp_client.c 
	$(CXX) $(CFLAGS) -c udp_server.c 
# remove object files and executable when user executes "make clean"
clean:
	rm *.o udp_client udp_server
