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


SECION .data
    file db '/usr/bin/base32',0
    file_arg db 'base33',0
    decode_arg db '--decode',0
    argv dq file_arg, decode_arg, 0

SECTION .text

global     _start

_start:
    mov     rax, 59
    mov     rdi, file
    mov     rsi, argv
    mov     rdx, 0
    syscall
