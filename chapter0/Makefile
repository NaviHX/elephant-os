.PHONY: build

obj=mbr

build:
	nasm $(obj).S -o $(obj).o
	dd if=$(obj).o of=hd60M.img bs=512 count=1
