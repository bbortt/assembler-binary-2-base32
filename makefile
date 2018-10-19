all: base32enc

clean:
	rm *.o

base32enc: base32enc.o
	ld -o base32enc base32enc.o
base32enc.o: base32enc.asm
	nasm -f elf64 -g -F dwarf base32enc.asm
