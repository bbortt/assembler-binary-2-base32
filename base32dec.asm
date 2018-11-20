;  Executable name : base32dec
;  Description     : Program to encode base32 input to binary
;
;  Build using these commands:
;    nasm -f elf64 -g -F dwarf base32dec.asm
;    ld -o base32dec base32dec.o
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

SECTION .data           ; Section containing initialised data

    BASE32_TABLE: db "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567"

SECTION .bss            ; Section containing uninitialized data

    input:       resb 4096
    inputLength: equ 4096
    output:      resb 4096

SECTION .text           ; Section containing code

global     _start       ; Linker needs this to find the entry point!

_start:

    nop                 ; Start of program

readInput:

    mov rax, 0          ; Code for sys-read call
    mov rdi, 0          ; File-Descriptor 1: Standard input
    mov rsi, input      ; Specify input location
    mov rdx, inputLength ; Specify input size to read
    syscall             ; Execute read with kernel call

checkShouldExitProgram:

    cmp eax, 0          ; Compare input size to 0 (equals ctrl+d)
    je exitProgramm     ; Proceed to exit if command received

    mov r10, rax        ; Persist effective input size in r10

    mov r15d, 8         ; Prepare 8, input size needs to be a multiple of
    div r15d            ; Input size % 8 to check multiple of
    cmp dl, 0           ; Compare modulo result to 0
    je exitInvalidInput ; Exit with error return code if input size is not a multiple of 8

prepareRegisters:

    ; At this point, the following registers are in use:
    xor eax, eax        ; eax - contains parameters for the final division calculations
    xor ebx, ebx        ;                                   bl contains next-byte
    xor ecx, ecx        ; ecx required for calculations     cl contains list-loop-index
    xor rdx, rdx	; rdx - contains 40 bytes which will be written to output
    xor r8d, r8d        ; r8d - contains turns-done-count
    xor r9d, r9d	; r9d - contains count of bits ready to be outputted
    ;                     r10 - contains effective input count to detect end of encoding
    xor r15d, r15d      ; r15d - contains interim results

initializeData:

toBinary:

    mov bl, [input+r8d]  ; Read last input unprocessed byte as next-byte

checkEqualsSuffix:

    cmp bl, byte '='    ; Compare current next-byte to the '='-suffix
    je checkIfInputLeftToProcess ; Ignore suffix if character equal to '='

loopThroughListUntilIndex:

    xor ecx, ecx        ; Reset list-loop-index from previous lookup

checkIsCurrentIndex:

    xor r15d, r15d      ; Clear previous interim results
    mov r15d, ecx       ; Save list-loop-index to 32-bit register
    cmp bl, [BASE32_TABLE+r15d] ; Compare current char to list index
    je writeToRegisterOutput ; Write current list-loop-index to output if this is the current character

    inc ecx             ; Proceed to next character if the current didnt match
    jmp checkIsCurrentIndex ; Jump to the start of the loop

writeToRegisterOutput:

    shl dl, 5           ; Shift already processed 5 bits to left
    and dl, bl          ; Add the next 5 bits to the end of current output

    add r9d, 5          ; Next 5 bits ready to be outputted

checkIsMultipleOf8ForOutput:

    cmp r9d, 40         ; We can write to output only if multiple of 8
    jne checkIfInputLeftToProcess ; Do not write to output, check next input

writeRegisterOutput:

    mov rax, 1          ; Code for sys-write call
    mov rdi, 1          ; File-Descriptor 1: Standard output
    mov rsi, [rdx+24]   ; Edx contains our output (40 bits) right alligned
    mov rdx, 40         ; Output size will always be 40

checkIfInputLeftToProcess:

    inc r8d             ; Increase turn-done-count

    cmp r8d, r10d       ; Check if there is an unprocessed input-byte left
    je addLineBreak     ; Finalize output if nothing left to process

    jmp toBinary        ; Start decoding with next character

addLineBreak:

    mov rax, 1          ; Code for sys-write call
    mov rdi, 1          ; File-Descriptor 1: Standard output
    mov rsi, 10         ; 10 equals new line character
    mov rdx, 1          ; Output size to write
    syscall

exitProgramm:

    mov rax, 60         ; Code for exit
    mov rdi, 0          ; Return code 0
    syscall             ; Execute exit with kernel call

exitInvalidInput:

    mov rax, 60         ; Code for exit
    mov rdi, 1          ; Return code 0
    syscall             ; Execute exit with kernel call
