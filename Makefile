SOURCES			= kernel.asm
MOUNT_POINT		= /home/david/jaspos/floppy/
TARGET			= $(MOUNT_POINT)kernel.run

all:
	- sudo mount ../floppy.img $(MOUNT_POINT)
	- sudo nasm $(SOURCES) -o $(TARGET)
	- sudo umount $(MOUNT_POINT)
	- ./lines.pl
	- make run

run:
	- bochs -f ../bochsrc -q
