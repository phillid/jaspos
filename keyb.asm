;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  name: jaspos_keyb_getkey
;;  @param	none
;;  @return	keycode
;;  Wait for a keypress from the keyboard,
;;  returning the ASCII code in AL and scancode
;;  in AH
;;
jaspos_keyb_getkey:
	xor		ax, ax						; Zero-out AX
	int		0x16						; Int 16.00 - wait for keypress
	ret									; Return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  name: jaspos_keyb_getstring
;;  @param	buffer		buffer to write to
;;  @param	length		maximum number of bytes to store (ie. buffer length)
;;  @return	read		total number of bytes read, excluding the carriage return
;;  Copy a maximum of [length] keypresses (ASCII
;;  codes) into ES:[buffer] until a ^M is read or
;;  until [length]-1 bytes have been read (last byte
;;  is used for null-termination)
;;
jaspos_keyb_getstring:
	pop		bp
	pop		cx
	pop		di
	push	bp
	mov		bx, di
	dec		cx
	push	cx
.loop:
	call	jaspos_keyb_getkey
	cmp		al, 13d
	jz		.quit
	cmp		al, 8
	jz		.bs
	cmp		al, 32d
	jl		.special
	stosb
.return:
	push	ax
	call	jaspos_monitor_dispchar
	call	jaspos_monitor_updatecursor
	loop	.loop
	jmp		.quit

.special:
	inc		cx
	loop	.loop
.bs:
	inc		cx
	cmp		di, bx
	jz		.loop
	inc		cx
	dec		di
	jmp		.return
.quit:
	xor		al, al
	stosb
	pop		ax
	sub		ax,	cx
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;