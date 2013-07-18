;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  name: jaspos_monitor_dispstring
;;  @param	string	null terminated string to display
;;  @return	none
;;  Print text onto the text screen
;;
jaspos_monitor_dispstring:
	pop		bp
	pop		ax
	push	bp
	push	di
	push	si
	push	es
	push	cx
	push	dx
	mov		si, ax
	call	jaspos_monitor_init
.loop:
	lodsb								; Load a byte from the string into AL
	cmp		al, 0						; Compare the byte with null
	jz		.quit						; Return if it's a null
	cmp		al, 1						; Check to see if it's a colour control char
	jz		.setcolour					; If so, jump to handle it
	push	ax							; Push the ASCII code of the character to print
	call	jaspos_monitor_dispchar		; Print the character to the screen
	mov		di, [VGAMemPointer]			; Load DI with the new, updated VGA memory pointer
	jmp		.loop						; Loop

.setcolour:
	lodsb								; Load the colour byte
	mov		[CharColour], al			; Set the CharColour to that byte
	jmp		.loop						; Go back to top of loop

.quit:
	mov		[VGAMemPointer], di			; Move the updated cursor position into VGAMemPointer
	call	jaspos_monitor_updatecursor	; Update the cursor position on screen
	pop		dx
	pop		cx
	pop		es
	pop		si
	pop		di
	ret									; Return to where this function was called
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  name: jaspos_monitor_dispchar
;;  @param	char	ASCII code of char to show
;;  @return	none
;;  Print single character to the screen
;;
jaspos_monitor_dispchar:
	pop		bp
	pop		ax
	push	bp
	push	es
	push	di
	call	jaspos_monitor_init			; Set up the registers ready for printing text
	cmp		di, 4000d					; Is DI (our VGA memory pointer) at the end of the screen?
	jge		.scroll						; If so, scroll the screen up a line
.checkchar:
	cmp		al, 8d						; Is the character a backspace?
	jz		.bs							; If so, jump to handle it
	cmp		al, 13d						; Is the byte a CR?
	jz		.cr							; if so, jump
	cmp		al, 10d						; Is the byte a LF?
	jz		.lf							; Jump if it is
	stosb								; Store the byte in AL in memory. This happens if it's not a control char
	mov		al, [CharColour]
	stosb
.quit:
	mov		[VGAMemPointer], di
	pop		di
	pop		es
	ret

.bs:
	sub		di, 2
	mov		al, 32d
	stosb
	sub		di, 2
	mov		al, [CharColour]
	stosb
	jmp		.quit

.cr:
	add		di, 160d					; Add 160 to the byte pointer, moving it down one line
	jmp		.quit						; Jump back to top of the loop

.lf:
	mov		ax, di						; Move our current position/pointer into AX
	xor		dx, dx
	mov		di, 160d					; Load DI with 160 (# of bytes per line)
	div		di							; AX = AX / DI  and  DX = remainder
	mul		di							; AX = AX * DI
	mov		di, ax						; So now AX has been divided and had the remainder chopped off in doing so
	xor		ax, ax
	jmp		.quit						; and is now multiplied back, so the pointer is now at the start of current line

.scroll:
	push	ds
	push	ax
	push	di
	push	si
	mov		cx, 0xB800					; Load DS with the video segment
	mov		ds, cx						;
	mov		si, 160d					;
	xor		di, di						;
	mov		cx, 3840d					;
	rep		movsb						; Move the bytes

	xor		al, al						; We'll be storing nulls to clear the last line
	mov		cx,	160d
	mov		di, 3840d
	rep		stosb
	pop		si
	pop		di
	sub		di, 160d
	pop		ax
	pop		ds
	jmp		.checkchar
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  name: jaspos_monitor_init
;;  @param	none
;;  @return	none
;;  Puts right values into ES and DI for putting
;;  strings on the screen
;;
jaspos_monitor_init:
	push	ax
	mov		ax, 0xB800					; Load AX with the VGA segment
	mov		es, ax						; and then ES
	mov		di, [VGAMemPointer]			; Load DI with VGA memory pointer
	pop		ax
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  name: jaspos_monitor_clear
;;  @param	none
;;  @return	none
;;  Clears the text screen
;;
jaspos_monitor_clear:
	push	ax							; push our registers used
	push	cx
	push	di
	push	es
	push	0x0000						; Overly explicit XY co-ord
	call	jaspos_monitor_setcursorxy	; Set the cursor position
	call	jaspos_monitor_init
	xor		di, di						; Set our reading pointer to the base of the segment
	mov		cx, 2000d					; We'll be looping 2000 times
.loop:
	mov		al, 0x20					; Load AL with character to clear address with
	stosb								; Store our byte
	mov		al, [CharColour]			;
	stosb								;
	loop	.loop						; Loop
	xor		ax, ax						; Zero-out AX
	mov		[VGAMemPointer], ax			; Load nulled-out AX into pointer
	pop		es
	pop		di
	pop		cx
	pop		ax							; pop registers we used back off stack
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  name: jaspos_monitor_setcursorxy
;;  @param	coord	word whose upper byte is the X lower byte is the Y coord
;;  @return	none
;;  Set the XY position of the text cursor but NOT where the next
;;  byte will be printed to the screen
;;
jaspos_monitor_setcursorxy:
	pop		bp
	pop		ax
	push	bp
	push	cx
	mov		cx, ax
	xor		ah, ah
	mov		bx, 160d
	mul		bx
	shr		cx, 8
	shl		cl, 1
	add		ax, cx
	mov		[VGAMemPointer], ax
	pop		cx
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  name: jaspos_monitor_getcursorxy
;;  @param	none
;;  @return	coord	word whose upper byte is the X lower byte is the Y coord
;;  Gets the XY position of the text cursor.
;;
jaspos_monitor_getcursorxy:
	push	dx
	mov		ax, [VGAMemPointer]			; Load the current cursor position
	mov		dx, 160d					; Divide it by 160 (bytes per row)
	div		dl							;
	shr		ah, 1						; Divide the X by 2
	pop		dx
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  name: jaspos_monitor_updatecursor
;;  @param	none
;;  @return	none
;;  Moves where the current cursor's (the actual
;;  flashing underscore) position is. Updates the
;;  position according to the current VGA memory
;;  pointer.
;;
jaspos_monitor_updatecursor:
	push	ax
	push	bx
	push	dx
	call	jaspos_monitor_getcursorxy
	mov		dh, al
	mov		dl, ah
	mov		ax, 0x0200					; AH = 2 - set cursor pos.
	xor		bh, bh						; clear BH
	int		0x10						; Int 10.02 - set cursor position
	pop		dx
	pop		bx
	pop		ax
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
