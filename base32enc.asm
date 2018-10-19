;  Executable name : base32enc
;  Version         : 1.0
;  Created date    : 10/19/2018
;  Last update     : 10/19/2018
;  Author          : Timon Borter
;  Description     : Program converting binary to base32 encoded string.
;
;  Run it this way:
;    base32enc
;    -> Then provide binary data via system input.
;
;  Build using these commands:
;    nasm -f elf64 -g -F dwarf base32enc.asm
;    ld -o base32enc base32enc.o
;
SECTION .bss			; Section containing uninitialized data

	Buffer:	resb 16
	BufferLength: equ $-Buffer

SECTION .data			; Section containing initialised data

	HexStr:	db " 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00",10
	HEXLEN equ $-HexStr

	Characters:	db "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567"
		
SECTION .text			; Section containing code

global 	_start			; Linker needs this to find the entry point!
	
_start:
	nop			; This no-op keeps gdb happy...

; Read a buffer full of text from stdin:
Read:
	mov eax,0		; Specify sys_read call
	mov ebx,0		; Specify File Descriptor 0: Standard Input
	mov ecx,Buffer		; Pass offset of the buffer to read to
	mov edx,BufferLength	; Pass number of bytes to read at one pass
	syscall			; Call sys_read to fill the buffer
	mov ebp,eax		; Save # of bytes read from file for later
	cmp eax,0		; If eax=0, sys_read reached EOF on stdin
	je Done			; Jump If Equal (to 0, from compare)

; Set up the registers for the process buffer step:
	mov esi,Buffer		; Place address of file buffer into esi
	mov edi,HexStr		; Place address of line string into edi
	xor ecx,ecx		; Clear line string pointer to 0

; Go through the buffer and convert binary values to base32 digits:
Scan:
	xor eax,eax		; Clear eax to 0

; Bump the buffer pointer to the next character and see if we're done:
	inc ecx		; Increment line string pointer
	cmp ecx,ebp	; Compare to the number of characters in the buffer
	jna Scan	; Loop back if ecx is <= number of chars in buffer

; Write the line of encoded values to stdout:
	mov eax,1		; Specify sys_write call
	mov ebx,1		; Specify File Descriptor 1: Standard output
	mov ecx,HexStr		; Pass offset of line string
	mov edx,HEXLEN		; Pass size of the line string
	syscall 		; Make kernel call to display line string
	jmp Read		; Loop back and load file buffer again

; All done! Let's end this party:
Done:
	mov eax,60		; Code for Exit Syscall
	mov ebx,0		; Return a code of zero	
	syscall 		; Make kernel call
