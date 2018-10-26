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
	mov rdx, inputLength	; Specify input size to read
	syscall			; Execute read with kernel call

	cmp eax, 0		; Control if input is EOF (0 bytes) flagged
	je exitProgramm		; Proceed to exit if ctrl+d pressed

prepareRegisters:

	; At this point, theee following registers are in use:
	xor eax, eax		;	eax - contains parameters for the modulo calculation
	xor ebx, ebx		; bh - contains leftovers;		bl contains shift-bits
	xor ecx, ecx		; ch - contains bytes-allocated-count;	cl - contains leftover-count
	xor edx, edx		;	edx - contains modulo calculation results
	xor r8w, r8w		;					r8w - contains turn-done-count
	xor r9d, r9d		;	r9d - contains interim results

initializeData:

	mov bh, [input]		; Read first byte as "leftovers" of the (unexisting) previous calculation
	mov cl, 8		; There were 8 bits left in the (unexisting) previous calculation
	mov ch, 1		; One-time one byte was allocated (processed)

toBase32:

	add r8w, 1		; Start new turn, increase counter

	add cl, 3		; Increase leftover-count by 3 bits to get 5
	shr bx, cl		; Shift bl+bh (=bx) to have 5 bits left
; TODO

proceedToNextChar:

	cmp ch, inputLength	; Compare byte-allocated-count to input length
	je finalizeBase32String	; Finalize Base32 if EOF reached

checkIfAllocateNeeded:

	xor eax, eax		; Clear eax from previous calcualations
	mov eax, 5		; Prepare 5 bits for every turn we did
	mul r8w
	mov r9d, eax		; Save result for modulo

	xor eax, eax		; Clear eax from previous calculation
	mov eax, 8 		; Prepare 8 bits for every allocated byte
	mul ch			; Multiply with bytes-allocated-count to get amount of bits already processed

	div r9w			; dx will be 8 * bytes-allocated-count % 5 * turns-done-count
	mov cl, dl		; Copy leftover-count (modulo-result) to register

	cmp cl, 0		; Look if we do not have any leftovers
	jg checkShouldAllocateFromInput	; Allocate from next byte if any leftovers exist

	mov bl, [rsi]		; Allocate remaining bits to shift-byte without leftovers
	jmp toBase32		; Start algorithm from the beginning

checkShouldAllocateFromInput:

	mov bh, [rsi]		; Allocate remaining bits to leftovers

	cmp cl, 5		; Compare leftover-count to 5
	jge toBase32		; If more or exactly 5 bits left, do not allocate from next byte

allocateFromNextByte:

	inc rsi 		; Proceed to next byte from input
	mov bl, [rsi]		; Move input to shift-bits
	add ch, 1		; Increase bytes-allocated-count by 1
	jmp toBase32		; Start algorithm from the beginning

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
