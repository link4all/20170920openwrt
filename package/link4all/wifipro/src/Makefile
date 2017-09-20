w_objs=Comm.o main.o Protocol.o Thread.o

wifipro:$(w_objs)
	$(CC) $(w_objs) -o wifipro -lpthread
.c.o:
	$(CC) -c $<
clean:
	rm -rf *.o wifipro
