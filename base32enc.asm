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

	input: resb 4096
	inputLength: equ 4096
	output:	resb 4096

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

	cmp rax, 0		; Control if input is EOF (0 bytes) flagged
	je exitProgramm		; Proceed to exit if ctrl+d pressed

prepareRegisters:

	mov r10, rax		; Move input size to r10 to detect end of encoding

	; At this point, the following registers are in use:
	xor eax, eax		; eax - contains parameters for the modulo calculation
	xor ebx, ebx		; bh - contains leftovers;		bl contains shift-bits
	xor ecx, ecx		; ecx - contains leftover-count, ecx required because of calculations
	xor edx, edx		; edx - contains modulo calculation results
	xor r8, r8		; r8 - contains bytes-allocated-count
	xor r9, r9		; r9 - contains turns-done-count
	;			  r10 - contains input count to detect end of encoding
	xor r15d, r15d		; r15d - contains interim results

initializeData:

	mov bh, [rsi]		; Read first byte as "leftovers" of the (unexisting) previous calculation
	mov ecx, 8		; There were 8 bits left in the (unexisting) previous calculation
	mov r8, 1		; One-time one byte was allocated (processed)

toBase32:
checkShouldBedderStop:

	cmp r8, r10		; Compare bytes-allocated-count to input size
	jg T

	inc r9			; Start new turn, increase counter
	jmp shiftLeftRightRemovePrefixingLeftoverBits

T:	
	jmp finalizeBase32String	; Finalize string if end of input reached and already nullified

shiftLeftRightRemovePrefixingLeftoverBits:

	mov r15d, ecx		; Save leftover-count as interim result
	mov ecx, 8		; Allocate 8 to ecx to subtract leftover-count
	sub ecx, r15d		; Subtract leftover-count from 8 to get to-nullify-bit-count
	shl bx, cl		; Nullify bits prefixing the leftovers
	shr bx, cl		; Reset leftovers to original position
	mov ecx, r15d		; Reallocate leftover-count to intended register

shiftToFiveBase32Bits:

	add ecx, 3		; Increase leftover-count by 3 bits to get 5 out of 8
	shr bx, cl		; Shift bh+bl (=bx) to have 5 bits left
	mov bl, [BASE32_TABLE+ebx] ; Replace encoding table index with effective base32 char

addToOutput:

	dec r9			; Remove one from turn-done-count to get array index (starting at 0)
	mov [output+r9], bl	; Write current encoded char to output
	inc r9			; Increase r9 back to turn-done-count

checkShouldAllocate:

	mov eax, 5		; Prepare 5 bits for every turn we did
	mul r9			; Multiply by turns-done-count to get amount of processed bits
	mov r15d, eax		; Save result for modulo

	mov eax, 8 		; Prepare 8 bits for every allocated byte
	mul r8			; Multiply with bytes-allocated-count to get amount of bits already read from input

	div r15d		; dx will be 8 * bytes-allocated-count % 5 * turns-done-count
	mov cl, dl		; Copy leftover-count (modulo-result) to register

	cmp cl, 8		; Check if leftovers were not nullified (e.g. end of input)
T1:
	jge finalizeBase32String ; Jump to finalization if end of input reached
	
	cmp ecx, 0		; Look if we do not have any leftovers
	jg checkShouldAllocateFromInput	; Allocate from next byte if any leftovers exist

	inc rsi 		; Proceed to next byte from input
	mov bh, [rsi]		; Allocate next byte as leftovers
	inc r8			; Increase bytes-allocated-count by 1
	mov ecx, 8		; 0 remaining equals 8, need to shift ALL on next turn
	jmp toBase32		; Start algorithm from the beginning

checkShouldAllocateFromInput:

	mov bh, [rsi]		; Allocate remaining bits to leftovers

	cmp ecx, 5		; Compare leftover-count to 5
	jge toBase32		; If more or exactly 5 bits left, do not allocate from next byte

checkShouldAllocateZeros:

	cmp r8, r10		; Compare turn-done-count to input size
	jl allocateFromInput	; Allocate from remaining input if there is some

	xor bl, bl		; Nullify allocated byte if only the leftovers need to be processed
	jmp toBase32		; Process leftovers, then exit

allocateFromInput:

	inc rsi 		; Proceed to next byte from input
	mov bl, [rsi]		; Move input to shift-bits
	inc r8			; Increase bytes-allocated-count by 1
	jmp toBase32		; Start algorithm from the beginning

finalizeBase32String:

	xor edx, edx		; Set edx to 0 because 64-bit div is edx | eax
	mov r15, 8		; Save 8 (as a divider) in register

checkShouldSuffixEncodedString:

	mov eax, r9d		; Allocate turn-done-count (equal to bytes processed) to eax for modulo calculation
	div r15d		; dx will be turn-done-count % 8
	cmp edx, 0		; Compare modulo result to 0 to detect multiple of 0
	je addLineBreak		; Add final line break without suffixing if already a multiple of 8

suffixUntilMultipleOf8:

	mov [output+r9], byte '=' ; Write suffix ('=') to fill up to multiple of 8

	mov eax, r9d		; Allocate turn-done-count (equal to bytes processed) to eax for modulo calculation
	div r15d		; dx will be turn-done-count % 8
	cmp edx, 0		; Compare modulo result to 0 to detect multiple of 0
	je addLineBreak		; Add final line break if a multiple of 8

	inc r9			; Increase turn-done-count by one
	jmp suffixUntilMultipleOf8 ; Loop suffixing until we reach multiple of 8

addLineBreak:

	mov [output+r9], byte 10 ; Add line-break ad the end of output

writeEncodedString:

	mov rax, 1		; Code for sys-write call
	mov rdi, 1		; File-Descriptor 1: Standard outp
	mov rsi, output		; Specify output location
	mov rdx, r9		; Specify output size to read/write
	syscall			; Execute write with kernel kall

	jmp readInput		; Loop until ctrl+d is pressed

exitProgramm:

	mov rax, 60		; Code for exit
	mov rdi, 0		; Return code 0
	syscall			; Execute exit with kernel call

	nop			; End of program
