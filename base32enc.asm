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

	cmp eax, 0		; Control if input is EOF (0 bytes) flagged
	je exitProgramm		; Proceed to exit if ctrl+d pressed

prepareRegisters:

	xor eax, eax		; clear 32 bit register
	xor ebx, ebx		; clear 32 bit register
	xor ecx, ecx		; clear 32 bit register
	xor edx, edx		; clear 32 bit register
	xor sp, sp		; clear 16 bit register
	xor bp, bp		; clear 16 bit register

initializeData:

	mov bh, [input]
	mov cl, 8
	mov ch, 1

; At this point, eax, ebx and ecx is in use!
; eax - contains parameters for the modulo calculation
; bl - contains shift-bits
; bh - contains leftovers
; cl - contains leftover-count
; ch - contains bytes-allocated-count
; edx - contains results of the module calculation
; sp - contains turns-done-count
; bp - contains interim results

toBase32:

	inc sp			; Start new turn, increase counter
	
	add cl, 3		; Increase leftover-count by 3 bits to get 5
	shr bx, cl		; Shift bl+bh (=bx) to have 5 bits left
; TODO

proceedToNextChar:

	cmp ch, inputLength	; Compare byte-allocated-count to input length
	je finalizeBase32String	; Finalize Base32 if EOF reached

checkIfAllocateNeeded:

	xor eax, eax		; Clear eax from previous calcualations
	mov eax, 5		; Prepare 5 bits for every turn we did
	mul sp
	mov bp, [eax]		; Save result for modulo

	xor eax, eax		; Clear eax from previous calculation
	mov eax, 8 		; Prepare 8 bits for every allocated byte
	mul ch			; Multiply with bytes-allocated-count to get amount of bits already processed

	div bp			; dx will be 8 * bytes-allocated-count % 5 * turns-done-count
	mov cl, [dl]		; Copy leftover-count (modulo-result) to register

finalizeBase32String:

; TODO

writeEncodedString:

	mov rax, 1		; Code for sys-write call
	mov rdi, 1		; File-Descriptor 1: Standard outp
	mov rsi, input		; Specify output location
	mov rdx, 16		; Specify output size to read/write
	syscall			; Execute write with kernel kall

	jmp readInput		; Loop until ctrl+d is pressed

exitProgramm:

	mov rax, 60		; Code for exit
	mov rdi, 0		; Return code 0
	syscall			; Execute exit with kernel call

	nop			; End of program
