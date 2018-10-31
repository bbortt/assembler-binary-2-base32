# Base32 Encoder/Decoder

This project was written in the first semester at [BFH TI](https://www.ti.bfh.ch/). It is intended to encode any input-string to Base32 and backwards.

## Table of contents

* [Difficulties when encoding to Base32](#difficulties-when-encoding-to-base32)
* [Road to the perfect algorithm](#road-to-the-perfect-algorithm)
* [Explaining the final code](#explaining-the-final-code)
* [Explanation on decoding](#explanation-on-decoding)
* [Copyright, license and usage for BFH TI](#copyright-license-and-usage-for-bfh-ti)

## Difficulties when encoding to Base32

The original difficulty is to transform an input of 8 bit blocks into blocks of 5 bits prefixed with 3 zeros. Because this requires us to keep a transactional byte as well as making the next byte transactional.

The problem is visualized in this short note with two bytes of numeric bits:
![Problem of packing 8 bits into blocks of 5](https://github.com/bbortt/assembly-binary-2-base32/blob/master/notes/original_problem_on_block_size.jpg)

## Road to the perfect algorithm

I started very simple: By visualizing my mind onto a paper. This is what my first idea of an algorithm looked like:
![First algorithm page 1](https://github.com/bbortt/assembly-binary-2-base32/blob/master/notes/idea_on_algorithm_page_1.jpg)
![First algorithm page 2](https://github.com/bbortt/assembly-binary-2-base32/blob/master/notes/idea_on_algorithm_page_2.jpg)

I started by converting the first byte into a 5 bit block like this.
```
// Read first byte
1234 5678

// Shift until the first 5 bits left
0001 234
```

But to calculate the next 5 bits I realized that i need the second byte too. I ended up like this:
```
// Read first byte and some zeros
1234 5678 | 0000 0000

// Shift until the first 5 bits left
0000 0000 | 0001 2345

// Now reset it to the inital state
1234 5678 | 0000 0000
// And read the second byte
1234 5678 | 1234 5678

// TODO: How to get 5 next bits?
```

In order to get the 5 next bits without the previously processed we need to do a "shift-left-right":
```
// Shift left to remove previously processed bits
6781 2345 | 6780 0000

// Shift left until next 5 bits left
0000 0000 | 0006 7810
```

## Explaining the final code

`// TODO`

## Explanation on decoding

There is no explanation on decoding from Base32 as this is literally the exact same algorithm just in reverse.

## Copyright, license and usage for BFH TI

This project is licensed under the terms of [MTI License](https://github.com/bbortt/assembly-binary-2-base32/blob/master/LICENSE).

This means you have the permission to use the code for commercial as well as for private use. You may modify and contribute to the code, in addition you may distribute it. But: I do not guarantee warranty nor am I liable in any case.

It is meant to help other students understanding the complex topic of encoding and decoding to or from Base32, to get them a first idea. It is not intended to be copied! Keep in mind that I ([bbortt](https://github.com/bbortt)) am the original owner of this code in any case of plagiarism conflict.
