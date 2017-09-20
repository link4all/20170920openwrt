LDFLAGS += -lpthread  

welink-4g-test: main.o
	$(CC) ${CFLAGS} main.o -o 4gdialer ${LDFLAGS}
	
main.o:main.c
	$(CC) ${CFLAGS} -c main.c -o main.o ${LDFLAGS}

clean:
	rm -rf 4gdialer *.o
