.globl _start
_start:
	movw $0x7374, %r11w            /* ts */
	push %r11
	movq $0x736f682f6374652f, %r11  /* /etc/hos */
	push %r11
	lea 0(%rsp), %rdi
	xor %rsi, %rsi
	addb $2, %al                   /* %rsi is initialized to 0 */
	syscall

	// sendfile
	xor %rdi, %rdi
	inc %rdi
	mov %rax, %rsi
	xor %rdx, %rdx
	mov $0xffff, %r10
	mov $40, %al
	syscall

	// exit
	xor %rdi, %rdi
	mov $3, %dl
	xor %rax, %rax
	mov $60, %al
	syscall
