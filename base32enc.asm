;  Executable name : base32enc
;  Description     : Program to encode binary input to base32
;
;  Build using these commands:
;    nasm -f elf64 -g base32enc.asm
;    ld -o base32enc base32enc.o
;
; -----------------------------------------------------------
;  MIT License
;
;  Copyright (c) 2018 Timon Borter
;
;  Permission is hereby granted, free of charge, to any person obtaining a copy
;  of this software and associated documentation files (the "Software"), to deal
;  in the Software without restriction, including without limitation the rights
;  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
;  copies of the Software, and to permit persons to whom the Software is
;  furnished to do so, subject to the following conditions:
;
;  The above copyright notice and this permission notice shall be included in all
;  copies or substantial portions of the Software.
;
;  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
;  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
;  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
;  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
;  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
;  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
;  SOFTWARE.

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

checkShouldExitProgram:

	cmp eax, 0		; Compare input size to 0 (equals ctrl+d)
	je exitProgramm		; Proceed to exit if command received

prepareRegisters:

	mov r10d, eax		; Persist input size as eax is used for calculations

	; At this point, the following registers are in use:
	xor eax, eax		; eax - contains parameters for the modulo calculation
	xor ebx, ebx		; bh - contains leftovers;		bl contains shift-bits
	xor cl, cl		; cl - required for calculations	cl contains leftover-count
	xor edx, edx		; edx - contains modulo calculation results
	xor r8d, r8d		; r8d - contains turns-done-count
	xor r9d, r9d		; r9d - contains bytes-allocated-count
	;			  r10 - contains effective input size to detect end of encoding
	xor r15d, r15d		; r15d - contains interim results

initializeData:

	mov bh, [rsi]		; Read first byte as "leftovers" of the (unexisting) previous calculation
	mov cl, 8		; Initialize 8 leftovers, this will shift the leftovers (bh) into the shift-bits (bl)
	mov r9d, 1		; Initial byte was allocated (read from input)

toBase32:
removeAlreadyProcessedShiftBits:

	mov r15b, cl		; Save leftover-count as interim result because of the "shift-left-right" to nullify previously processed bits
	mov cl, 8		; Allocate 8 to cl to subtract leftover-count
	sub cl, r15b		; Subtract leftover-count from 8 to get the amount of already processed bits int this leftovers
	shl bx, cl		; Nullify already processed leftovers
	shr bx, cl		; Reset leftovers to original position
	mov cl, r15b		; Reallocate leftover-count to intended register

shiftToFiveBase32Bits:

	add cl, 3		; Increase leftover-count by 3 to get 5 out of 8 bits
	shr bx, cl		; Shift bh+bl (=bx) to have 5 bits left
	mov bl, [BASE32_TABLE+ebx] ; Replace encoding table index with effective base32 char

addToOutput:

	mov [output+r8d], bl	; Write current encoded char to output
	inc r8d			; Increase turns-done-count, one more output processed

checkShouldAllocate:

	mov eax, 5		; Prepare 5 bits for every turn done
	mul r8d			; Multiply by turns-done-count to get amount of processed bits
	mov r15d, eax		; Save interim result for modulo calculation

	mov eax, 8 		; Prepare 8 bits for every allocated byte
	mul r9d			; Multiply with bytes-allocated-count to get amount of bits already read from input

	div r15d		; dx will be 8 * bytes-allocated-count % 5 * turns-done-count, equals leftovers to process
	mov cl, dl		; Copy leftover-count (modulo-result) to intended register

checkEndOfInputReached:

	cmp cl, 8		; Check if leftovers were not nullified (end of input); Take a look at checkShouldAllocateZeros:
	jge finalizeBase32String ; Jump to finalization if end of input reached

	cmp cl, 0		; Check if there are any leftovers
	jne checkShouldProcessLeftovers ; Continue encoding input if any leftovers exist
	cmp r9d, r10d		; Check if end of input without was reached without any leftovers
	je finalizeBase32String	; Jumpt to suffixing if all input processed without leftovers

checkShouldProcessLeftovers:

	cmp cl, 0		; Look if any leftovers exist
	jg checkShouldAllocateFromInput	; Check if allocate (read byte from input) needed

	inc rsi 		; Proceed to next byte from input if no leftovers exist
	mov bh, [rsi]		; Allocate next byte as leftovers
	inc r9d			; Increase bytes-allocated-count by 1
	mov cl, 8		; 0 remaining equals 8, need to shift ALL leftovers to shift-bits on next turn
	jmp toBase32		; Start algorithm from the beginning

checkShouldAllocateFromInput:

	mov bh, [rsi]		; Allocate remaining bits to leftovers

	cmp cl, 5		; Compare leftover-count to 5
	jge toBase32		; If more or exactly 5 bits left, do not allocate from next byte

checkShouldAllocateZeros:

	cmp r9d, r10d		; Compare bytes-allocated-count to input size
	jl allocateFromInput	; Allocate from remaining input if there is some

	xor bl, bl		; Nullify allocated byte if only the leftovers need to be processed
	jmp toBase32		; Process leftovers, then exit

allocateFromInput:

	inc rsi 		; Proceed to next byte from input
	mov bl, [rsi]		; Move input to shift-bits, will be concatenated with leftovers
	inc r9d			; Increase bytes-allocated-count by 1
	jmp toBase32		; Start algorithm from the beginning

finalizeBase32String:

	xor edx, edx		; Set edx to 0 because 64-bit div is edx | eax
	mov r15d, 8		; Save 8 (as a divider) in register

checkShouldSuffixEncodedString:

	mov eax, r8d		; Allocate turns-done-count (equal to bytes processed) to eax for modulo calculation
	div r15d		; dx will be turns-done-count % 8
	cmp edx, 0		; Compare modulo result to 0 to detect multiple of 0
	je addLineBreak		; Add final line break without suffixing if already a multiple of 8

suffixUntilMultipleOf8:

	mov [output+r8d], byte '=' ; Write suffix ('=') to fill up to multiple of 8

	mov eax, r8d		; Allocate turns-done-count (equal to bytes processed) to eax for modulo calculation
	div r15d		; dx will be turns-done-count % 8
	cmp edx, 0		; Compare modulo result to 0 to detect multiple of 0
	je addLineBreak		; Add final line break if a multiple of 8

	inc r8d			; Increase turns-done-count by one
	jmp suffixUntilMultipleOf8 ; Loop suffixing until multiple of 8

addLineBreak:

	mov [output+r8d], byte 10 ; Add line-break to the end of output

writeEncodedString:

	mov rax, 1		; Code for sys-write call
	mov rdi, 1		; File-Descriptor 1: Standard outp
	mov rsi, output		; Specify output location
	mov rdx, r8		; Specify output size to read/write
	syscall			; Execute write with kernel kall

	jmp readInput		; Loop until ctrl+d is pressed

exitProgramm:

	mov rax, 60		; Code for exit
	mov rdi, 0		; Return code 0
	syscall			; Execute exit with kernel call
