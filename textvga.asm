;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Print text onto the text screen
OutText:
	pop		ax
	pop		si
	push	ax
	mov		ax, 0xB800					; Load AX with the VGA segment
	mov		es, ax						; and then ES
	mov		di, [VGAMemPointer]			; Load DI with VGA memory pointer

.loop:
	lodsb								; Load a byte from the string into AL
	or		al, al						; Do a byte comarison on the char
	jz		.Quit						; Exit the function if it's a null
	cmp		al, 1						; Check to see if it's a colour control char
	jz		.SetColour					; If so, jump to handle it
	cmp		al, 13d						; Is the byte a CR?
	jz		.cr							; if so, jump
	cmp		al, 10d						; Is the byte a LF?
	jz		.lf							; Jump if it is
	stosb								; Store the byte in memory. This happens if it's not a control char
	mov		al, [CharColour]			; Load the current char colour
	stosb								; Store the char colour in the byte after the character
	jmp		short .loop					; Loop

.cr:
	add		di, 160d					; Add 160 to the byte pointer, thus moving the pointer down one line
	jmp		short .loop					; Jump back to top of the loop

.lf:
	mov		ax, di						; Move our current position/pointer into AX
	mov		di, 160d					; Load DI with 160 (# of bytes per line)
	div		di							; AX = AX / DI  and  DX = remainder
	mul		di							; AX = AX * DI
	mov		di, ax						; So now AX has been divided and had the remainder chopped off in doing so
	jmp		short .loop					; and is now multiplied back, so the pointer is now at the start of current line

.SetColour:
	lodsb								; Load the byte
	mov [CharColour], al				; Set the CharColour to that byte
	jmp short .loop						; Go back to top of loop

.Quit:
	mov [VGAMemPointer], di				; Move the updated cursor position into VGAMemPointer
	ret									; Return to where this function was called
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Clear the text screen
ClearScreen:
	push	ax							; push our registers used
	push	cx
	push	di
	push	es
	mov		ax, 0xB800					; Load AX with the VGA segment
	mov		es, ax						; And then load ES with AX
	xor		di, di						; Set our reading pointer to the base of the segment
	mov		cx, 0x7D0					; We'll be looping 2000 times
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
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Set the cursor position
SetCursorPosition:
	push	ax							; Push our registers
	push	bx							; 
	mov		ah, 2						; Subfunction 2 - set cursor pos.
	xor		bh, bh						; clear BH
	int		0x10						; Int 10.02 - set cursor position
	pop		bx							; Pop registers back off stack
	pop		ax							; 
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Convert decimal in dx to string in NumberBuffer
NumberToString:
	std
	pop		dx
	mov 	cx, 0x5
	lea 	di, [NumberBuffer + 4]
.loop:
	mov 	ax, dx
	mov 	dx, 10d
	div 	dl
	mov 	dl, al
	mov 	al, ah
	add 	al, 0x30
	stosb
	loop	.loop
	cld
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Convert he value in al to string in HexNumberBuffer
HexToString:
	mov		di, HexNumberBuffer
	xor		ah, ah					; zero-out ah so shifiting doesn't cause bits of ah to come into al
	push	ax						; save AL
	shr		al, 4					; Shift AL along 4 bits
	add		al, 48d					; add 48 onto it
	cmp		al, 57d					; see if it's > 9
	jg		.letter
.return:
	stosb
	pop		ax
	shl		al, 4
	shr		al, 4
	add		al, 48d
	cmp		al, 57d
	jg		.letter_last_digit
	stosb
.quit:
	ret

.letter:
	add		ax, 7d
	jmp		.return

.letter_last_digit:
	add		ax, 7d
	stosb
	jmp		.quit
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;