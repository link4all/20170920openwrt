h264capture:h264capture.o
	$(CC)  $(LDFLAGS)  h264capture.o -o h264capture
h264capture.o:v2v_api_v4l2.c
	$(CC) $(CFLAGS) -c v2v_api_v4l2.c -o h264capture.o
clean:
	rm -rf h264capture h264capture.o
