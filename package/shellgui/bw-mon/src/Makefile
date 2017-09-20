all: bw_convert delete_chain_from_table

bw_convert: bw_convert.o
	$(CC) $(CFLAGS) $(LDFLAGS) $^ -o $@ -lericstools
delete_chain_from_table: delete_chain_from_table.o
	$(CC) $(CFLAGS) $(LDFLAGS) $^ -o $@ -lericstools

%.o:%.c
	$(CC) $(CFLAGS) -c $^ -o $@

clean:
	rm -rf *.o *~ .*sw* bw_convert
