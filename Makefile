build:
	ca65 ./src/bios.s -o ./build/bios.o
	ld65 -C ./bios.cfg ./build/bios.o -o ./bin/rom.bin
	hexdump -C ./bin/rom.bin