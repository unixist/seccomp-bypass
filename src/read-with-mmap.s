.globl _start
_start:
        // open
	movw $0x7374, %r11w             /* ts */
	push %r11
	movq $0x736f682f6374652f, %r11  /* /etc/hos */
	push %r11
	lea 0(%rsp), %rdi
	xor %rsi, %rsi
	addb $2, %al
	syscall

	// mmap
	xor %rdi, %rdi
	xor %rsi, %rsi
	mov $0xffff, %si
	xor %rdx, %rdx
	add $1, %dl
	mov %rax, %r8
	xor %r9, %r9
	xor %r10, %r10
	add $1, %r10b
	xor %rax, %rax
	mov $9, %al
	syscall

	// write
	xor %rdi, %rdi
	inc %dl
	mov %rax, %rsi
	xor %rdx, %rdx
	mov $0xffff, %dx
	xor %rax, %rax
	inc %al
	syscall

	// exit
	xor %rdi, %rdi
	mov $3, %dl
	xor %rax, %rax
	mov $60, %al
	syscall
