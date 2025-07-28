build:
	ca65 ./src/bios.s -o ./build/bios.o
	ld65 -C ./bios.cfg ./build/bios.o -o ./bin/rom.bin -Ln ./build/bios.sym
	hexdump -C ./bin/rom.bin