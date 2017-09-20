# build helloworld executable when user executes "make"
lcx: lcx.o
	$(CC) $(LDFLAGS) lcx.o -o lcx -lpthread
lcx.o: lcx.c
	$(CC) $(CFLAGS) -c lcx.c 
# remove object files and executable when user executes "make clean"
clean:
	rm *.o lcx
