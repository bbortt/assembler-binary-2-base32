;  Executable name : base32enc
;  Description     : Program to encode binary input to base32
;
;  Build using these commands:
;    nasm -f elf64 -g base32enc.asm
;    ld -o base32enc base32enc.o
;

SECTION .data			; Section containing initialised data

	encodingTable: db "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567", 32

SECTION .bss			; Section containing uninitialized data

	input: resb 16
	inputLength: equ 16

SECTION .text			; Section containing code

global 	_start			; Linker needs this to find the entry point!

_start:
	nop			; Start of program

readInput:
	mov rax, 0		; Code for sys-read call
	mov rdi, 0		; File-Descriptor 1: Standard input
	mov rsi, input		; Specify input location
	mov rdx, inputLength	; Specify input size to read/write
	syscall			; Execute read with kernel call

	mov ebx, input	  	; Move message to register
	cmp eax, 0		; Control if input is EOF (0 bytes) flagged
	je exitProgramm		; Proceed to exit if ctrl+d pressed

prepareConversion:
	mov ecx, inputLength
	
toBase32:
; TODO

proceedToNextChar:
	inc ebx			; Proceed to next char
	dec ecx			; Decreese amount of chars to process
	jnz toBase32		; Transform next char if not finished

writeEncodedString:
	mov rax, 1		; Code for sys-write call
	mov rdi, 1		; File-Descriptor 1: Standard outp
	mov rsi, input		; Specify input location
	mov rdx, 16		; Specify input size to read/write
	syscall			; Execute write with kernel kall

	jmp readInput		; Loop until ctrl+d is pressed

exitProgramm:
	mov rax, 60		; Code for exit
	mov rdi, 0		; Return code 0
	syscall			; Execute exit with kernel call
	
	nop			; End of program
