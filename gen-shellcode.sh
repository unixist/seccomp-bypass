#!/bin/bash

# Assume that first param is name of assembly file, e.g. foo.s. It expects it
# to contain single code label called, "_start".
file=$(sed "s/.s$//" <<< $1)
sc=$(as $file.s -o $file.o; objdump -D $file.o | grep -A10000 '<_start>' | sed -e 's/.*\t\([[:alnum:]].*\)\t.*/\1/' | cut -f2- -d: | sed ':a;/$/{N;s/\n//;ba}' | sed 's/^/\\x/' | sed -e 's/[[:space:]]\+\([[:alnum:]]\)/\\x\1/g' | sed -e 's/[[:space:]]\+$//' | sed 's/\\x/\n/g' | column -c 120 -x | sed 's/^/\\x/; s/\t/\\x/g' | sed '1 s/^/"/;1 s/$/"/; 2,$ s/^\(.*\)/                   "\1"/')
rm $file.o
cat << EOF
#include <stdint.h>
#include <sys/mman.h>

char shellcode[] = $sc;

int main(){
  mprotect((void *)((uint64_t)shellcode & ~4095), 4096, PROT_READ|PROT_EXEC);
  (*(void(*)()) shellcode)();
  return 0;
}
EOF
