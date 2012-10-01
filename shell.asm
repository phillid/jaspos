Main:
	call	GetKey
	mov		ah, 0x0E
	
GetKey:
	xor		ax, ax
	int		0x16
	ret
