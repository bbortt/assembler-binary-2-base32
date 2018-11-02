#!/bin/sh
# This is an example shell script showing how your code will
# be graded. It compiles and test only the decoder program.
# The real grading script will test BOTH.
# Note that if you pass this script, you will receive at
# least 50% of the points for the Assembler homework!

# Assemble and link decoder
nasm -f elf64 -g -F dwarf base32dec.asm -o b32d.o || { echo "Assembly code base32dec.asm failed to compile"; exit 1; }
ld -o b32d b32d.o || { echo "Object failed to link"; exit 1; }

# run tests
total=0
for n in IFAQ==== IFBA==== IE====== MJRQ==== IQYTG=== IZHU6=== MZXXQ6I= NRQWYYLMMFWGC3DBNQ2DENBS
do
  points=1
  timeout -s SIGKILL 1s echo -n $n | ./b32d > $n.out || { echo "Your 'b32' command failed to run: $?" ; points=0 ; }
  echo -n $n | base32 -d > $n.want || { echo "System 'base32 -d' failed to run"; exit 1; }
  diff -w $n.want $n.out > $n.delta || { echo "Decode failed on $n" ; points=0; }
  if test $points = 1
  then
    echo "Test $n passed"
    total=`expr $total + $points`
  fi
done
# Output grade
echo "Final grade: $total/8"
exit 0
