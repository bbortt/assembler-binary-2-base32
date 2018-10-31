# Base32 Encoder/Decoder

This project was written in the first semester at [BFH TI](https://www.ti.bfh.ch/). It is intended to encode any input-string to base32 and backwards.

## Table of contents

* [Difficulties when encoding to base32](#difficulties-when-encoding-to-base32)
* [Road to the perfect algorithm](#road-to-the-perfect-algorithm)
* [Explaining the final code](#explaining-the-final-code)
* [Copyright, license and usage for BFH TI](#copyright-license-and-usage-for-bfh-ti)

## Difficulties when encoding to base32

The original difficulty is to transform an input of 8 bit blocks into blocks of 5 bits prefixed with 3 zeros. Because this requires us to keep a transactional byte as well as making the next byte transactional.

The problem is visualized in this short note with two bytes of numeric bits:
![Problem of packing 8 bits into blocks of 5](https://github.com/bbortt/assembly-binary-2-base32/blob/master/notes/original_problem_on_block_size.jpg)

## Road to the perfect algorithm



## Explaining the final code



## Copyright, license and usage for BFH TI

This project is licensed under the terms of [MTI License](https://github.com/bbortt/assembly-binary-2-base32/blob/master/LICENSE).

This means you have the permission to use the code for commercial as well as for private use. You may modify and contribute to the code, in addition you may distribute it. But: I do not guarantee warranty nor am I liable in any case.

It is meant to help other students understanding the complex topic of encoding and decoding to or from base32, to get them a first idea. It is not intended to be copied! Keep in mind that I ([bbortt](https://github.com/bbortt)) am the original owner of this code in any case of plagiarism conflict.
