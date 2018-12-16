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

    BASE32: db "/usr/bin/base32",0
    BASE32_ARG: db "base32",0
    DECODE_ARG: db "--decode",0
    ARGV: dq BASE32_ARG, DECODE_ARG, 0

SECTION .text           ; Section containing code

global     _start       ; Linker needs this to find the entry point!

_start:

    nop                 ; Start of program

executeBase32:

    mov     rax, 59     ; Code for sys-execenv call
    mov     rdi, BASE32 ; File pointer for /usr/bin/base32
    mov     rsi, ARGV   ; Arguments: argv[0]="base32", arg[1]="--decode"
    mov     rdx, 0      ; File-Descriptor 0: Standard input
    syscall             ; Execute program with kernel call

exitProgram:

    mov rax, 60         ; Code for exit
    mov rdi, 0          ; Return code 0
    syscall             ; Execute exit with kernel call
