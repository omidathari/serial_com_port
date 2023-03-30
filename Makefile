SERVICE := serial_com_port

all: get_shards build

src/serial_libc.o : src/serial_libc.c
	echo "Build serial_libc"
	$(CC) -Wall -O3 -c $< -o $@

build : src/serial_libc.o
	crystal -v
	shards build -p

get_shards :
	shards install

clean :
	rm -rf src/serial_libc.o

