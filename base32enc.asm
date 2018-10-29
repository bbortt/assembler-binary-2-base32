;  Executable name : base32enc
;  Description     : Program to encode binary input to base32
;
;  Build using these commands:
;    nasm -f elf64 -g base32enc.asm
;    ld -o base32enc base32enc.o
;

SECTION .data			; Section containing initialised data

	BASE32_TABLE: db "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567"

SECTION .bss			; Section containing uninitialized data

	input: resb 16
	output:	resb 16
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
	xor eax, eax		; eax - contains parameters for the modulo calculation
	xor ebx, ebx		; bh - contains leftovers;		bl contains shift-bits
	xor ecx, ecx		; ecx - contains leftover-count, ecx required because of calculations
	xor edx, edx		; edx - contains modulo calculation results
	xor r8d, r8d		; r8d - contains bytes-allocated-count
	xor r9d, r9d		; r9d - contains turns-done-count
	xor r14d, r14d		; r14d - contains output (tmporary)
	xor r15d, r15d		; r15d - contains interim results

initializeData:

	mov bh, [input]		; Read first byte as "leftovers" of the (unexisting) previous calculation
	mov ecx, 8		; There were 8 bits left in the (unexisting) previous calculation
	mov r8d, 1		; One-time one byte was allocated (processed)

toBase32:

	inc r9d			; Start new turn, increase counter

	add ecx, 3		; Increase leftover-count by 3 bits to get 5
	shr bx, cl		; Shift bh+bl (=bx) to have 5 bits left
	mov bl, [BASE32_TABLE+ebx] ; Replace encoding table index with effective base32 char

writeToOutput:

	shl r14b, 8	    	; Move last allocated output to not override id
	mov r14b, bl		; Move calculated value to output

; TODO

proceedToNextChar:

	cmp r8w, inputLength	; Compare byte-allocated-count to input length
	je finalizeBase32String	; Finalize Base32 if EOF reached

checkIfAllocateNeeded:

	xor eax, eax		; Clear eax from previous calcualations
	mov eax, 5		; Prepare 5 bits for every turn we did
	mul r9d			; Multiply by turns-done-count to get amount of processed bits
	mov r15d, eax		; Save result for modulo

	xor eax, eax		; Clear eax from previous calculation
	mov eax, 8 		; Prepare 8 bits for every allocated byte
	mul r8w			; Multiply with bytes-allocated-count to get amount of bits already processed

	div r15w		; dx will be 8 * bytes-allocated-count % 5 * turns-done-count
	mov cl, dl		; Copy leftover-count (modulo-result) to register

	cmp ecx, 0		; Look if we do not have any leftovers
	jg checkShouldAllocateFromInput	; Allocate from next byte if any leftovers exist

	mov bl, [rsi]		; Allocate remaining bits to shift-byte without leftovers
	jmp toBase32		; Start algorithm from the beginning

checkShouldAllocateFromInput:

	mov bh, [rsi]		; Allocate remaining bits to leftovers

	cmp ecx, 5		; Compare leftover-count to 5
	jge toBase32		; If more or exactly 5 bits left, do not allocate from next byte

allocateFromNextByte:

	inc rsi 		; Proceed to next byte from input
	mov bl, [rsi]		; Move input to shift-bits
	inc r8d			; Increase bytes-allocated-count by 1
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
