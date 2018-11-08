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

    input: resb 4096
    inputLength: equ 4096
    output:    resb 4096

SECTION .text           ; Section containing code

global     _start       ; Linker needs this to find the entry point!

_start:

    nop                 ; Start of program

readInput:

    mov rax, 0          ; Code for sys-read call
    mov rdi, 0          ; File-Descriptor 1: Standard input
    mov rsi, input      ; Specify input location
    mov rdx, inputLengthn; Specify input size to read
    syscall             ; Execute read with kernel call

checkShouldExitProgram:

    cmp eax, 0          ; Compare input size to 0 (equals ctrl+d)
    je exitProgramm     ; Proceed to exit if command received

prepareRegisters:

    mov r10d, eax       ; Persist input size as eax is used for calculations

    ; At this point, the following registers are in use:
    xor eax, eax        ; eax - contains parameters for the modulo calculation
    xor ebx, ebx        ; bh - contains and-byte;          bl contains next-byte
    xor cl, cl          ; cl - required for calculations    cl contains leftover-count
    xor edx, edx        ; edx - contains modulo calculation results
    xor r8d, r8d        ; r8d - contains turns-done-count
    xor r9d, r9d        ; r9d - contains bytes-allocated-count
    ;                     r10 - contains effective input size to detect end of encoding
    xor r15d, r15d      ; r15d - contains interim results

initializeData:


toBinary:

;; TODO

addLineBreak:

    mov [output+r8d], byte 10 ; Add line-break to the end of output

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
