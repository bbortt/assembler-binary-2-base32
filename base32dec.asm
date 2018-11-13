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

    mov r15d, 8         ; Prepare 8, input size needs to be a multiple of
    div r15d            ; Input size % 8 to check multiple of
    cmp dl, 0           ; Compare modulo result to 0
    je exitInvalidInput ; Exit with error return code if input size is not a multiple of 8

prepareRegisters:

    mov r10d, eax       ; Persist input size as eax is used for calculations

    ; At this point, the following registers are in use:
    xor eax, eax        ; eax - contains parameters for the final division calculations
    xor ebx, ebx        ;                                   bl contains next-byte
    xor ecx, ecx        ; ecx required for calculations     cl contains list-loop-index
    xor r8d, r8d        ; r8d - contains output-bits-count
    ;                     r10 - contains byte-to-process-count to detect end of encoding
    xor r15d, r15d      ; r15d - contains interim results

initializeData:

toBinary:

    mov bl, [input+r10d]  ; Read last input unprocessed byte as next-byte

checkEqualsSuffix:

    cmp bl, byte '='    ; Compare current next-byte to the '='-suffix
    je checkIfInputLeftToProcess ; Ignore suffix if character equal to '='

loopThroughListUntilIndex:

    xor ecx, ecx        ; Reset list-loop-index from previous lookup

checkIsCurrentIndex:

    xor r15d, r15d      ; Clear previous interim results
    mov r15d, ecx       ; Save list-loop-index to 32-bit register
    cmp bl, [BASE32_TABLE+r15d] ; Compare current char to list index
    je addToOutput      ; Write current list-loop-index to output if this is the current character

    inc ecx             ; Proceed to next character if the current didnt match
    jmp checkIsCurrentIndex ; Jump to the start of the loop

addToOutput:

    shr [output], 5     ; Prepare output for next 5 bits, nullify
    and [output], cl    ;  Match current list-loop-index to output

    add r8w, 5          ; 5 more bits written to output-buffer

checkIfInputLeftToProcess:

    cmp r10d, 0         ; Check if there is an unprocessed input-byte left
    je addLineBreak     ; Finalize output if nothing left to process

readNextInputByte:

    dec r10d            ; Decrease byte-to-process-count, read next byte from input
    jmp toBinary        ; Start decoding with next character

addLineBreak:

    mov eax, r8d        ; Move output-bits-count (amount of processed bits) to eax
    mov r15b, 8         ; Prepare 8-bit divisor
    div r15b            ; Divide output-size by 8 to get amount of bytes.
    ; ah - contains reminder, al - contains quotien

    inc al              ; Increase al by one, this is the line-break location
    mov [output+eax], byte 10 ; Add line-break to the end of output

writeEncodedString:

    mov rax, 1          ; Code for sys-write call
    mov rdi, 1          ; File-Descriptor 1: Standard outp
    mov rsi, output     ; Specify output location
    mov rdx, r8         ; Specify output size to read/write
    syscall             ; Execute write with kernel kall

    jmp readInput       ; Loop until ctrl+d is pressed

exitProgramm:

    mov rax, 60         ; Code for exit
    mov rdi, 0          ; Return code 0
    syscall             ; Execute exit with kernel call

exitInvalidInput:

    mov rax, 60         ; Code for exit
    mov rdi, 1          ; Return code 0
    syscall             ; Execute exit with kernel call
