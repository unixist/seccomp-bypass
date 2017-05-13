#!/bin/bash

# Assume that first param is name of assembly file, e.g. foo.s. It expects it
# to contain single code label called, "_start".
file=$(sed "s/.s$//" <<< $1)
as $file.s -o $file.o ; ld $file.o -o $file; objdump -D $file | grep -A10000 '<_start>' | sed -e 's/.*\t\([[:alnum:]].*\)\t.*/\1/' | cut -f2- -d: | sed ':a;/$/{N;s/\n//;ba}' | sed 's/^/\\x/' | sed -e 's/[[:space:]]\+\([[:alnum:]]\)/\\x\1/g'
