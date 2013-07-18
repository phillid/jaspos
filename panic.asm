jaspos.panic:
	; Quick! Save state of registers before perhaps
	; accidentally corrupting them while printing
	push	sp
	push	bp
	push	di
	push	si

	push	gs
	push	ss
	push	es
	push	ds
	push	cs

	push	dx
	push	cx
	push	bx
	push	ax

	push	msgPanic					; Show a panic message
	call	jaspos_monitor_dispstring	; ... Then halt (see lines below)

	push	msgAX
	call	jaspos_monitor_dispstring
	pop		ax
	call	.printax
	push	msgBX
	call	jaspos_monitor_dispstring
	pop		ax
	call	.printax
	push	msgCX
	call	jaspos_monitor_dispstring
	pop		ax
	call	.printax
	push	msgDX
	call	jaspos_monitor_dispstring
	pop		ax
	call	.printax

	push	msgCS
	call	jaspos_monitor_dispstring
	pop		ax
	call	.printax
	push	msgDS
	call	jaspos_monitor_dispstring
	pop		ax
	call	.printax
	push	msgES
	call	jaspos_monitor_dispstring
	pop		ax
	call	.printax
	push	msgSS
	call	jaspos_monitor_dispstring
	pop		ax
	call	.printax
	push	msgGS
	call	jaspos_monitor_dispstring
	pop		ax
	call	.printax

	push	msgSI
	call	jaspos_monitor_dispstring
	pop		ax
	call	.printax
	push	msgDI
	call	jaspos_monitor_dispstring
	pop		ax
	call	.printax
	push	msgBP
	call	jaspos_monitor_dispstring
	pop		ax
	call	.printax
	push	msgSP
	call	jaspos_monitor_dispstring
	pop		ax
	call	.printax

	jmp		.end

.printax:
	mov		[free_ram + 4], byte 0
	push	free_ram + 3
	push	ax
	call	jaspos_strutils_hex2str
	push	msg0x
	call	jaspos_monitor_dispstring
	push	free_ram
	call	jaspos_monitor_dispstring
	ret

.end: