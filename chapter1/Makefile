.PHONY: build clean

build:
	dd if=/dev/zero of=hd60M.img bs=512 count=122880 conv=notrunc
	nasm -fbin -o mbr.o -Iinclude/ ./src/mbr.S
	nasm -fbin -o loader.o -Iinclude/ ./src/loader.S
	dd if=mbr.o of=hd60M.img bs=512 count=1 conv=notrunc
	dd if=loader.o of=hd60M.img bs=512 count=1 seek=2 conv=notrunc

clean:
	rm *.o *.img
