#CXX=g++

httpsocket:httpsocket.o
	$(CC)  $(LDFLAGS)  httpsocket.o -o httpsocket
httpsocket.o: httpsocket.c
	$(CC) $(CFLAGS) -c httpsocket.c  
clean:
	rm -rf httpsocket httpsocket.o
