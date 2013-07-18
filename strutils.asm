;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  name: jaspos_strutils_strlen
;;  @param	string	string to measure
;;  @return	length	length of string
;;  Counts length of string at DS:arg1 and leaves
;;  SI as a pointer to the end of the string
;;
jaspos_strutils_strlen:
	pop		bp
	pop		si
	push	bp
	push	cx
	xor		cx, cx
.loop:
	lodsb
	cmp		al, 0
	jz		.quit
	inc		cx
	jmp		.loop
.quit:
	dec		ax
	dec		si
	mov		ax, cx
	pop		cx
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  name: jaspos_strutils_hex2str
;;  @param	buffer	buffer to write string to
;;  @param	number	hex integer to convert
;;  @return	none
;;  Converts hex word to string
;;
jaspos_strutils_hex2str:
	pop		bp							;
	pop		ax							;
	pop		di							;
	push	bp							;
	mov		bx, strutils_HexLookup		;
	std									; RW memory from right to left
	mov		cx, 2
.loop:
	push	ax
	shl		al, 4
	shr		al, 4
	xlatb
	stosb
	pop		ax
	shr		al, 4
	xlatb
	stosb
	xchg	ah, al
	loop	.loop

	cld									; RW memory from left to right
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  name: jaspos_strutils_d2str
;;  @param	buffer	buffer to write string to
;;  @param	number	fixed decimal to convert
;;  @return	none
;;  Converts integer word to string
;;
jaspos_strutils_d2str:
	std									; We're going to be STOSBing from right-to-left. Set the direction flag
	pop		bp							; Pop return address off the stack
	pop		dx							; Pop arg2 off - decimal number
	pop		di							; pop arg1 off - string buffer
	push	bp							; Push return address onto stack, ready for RET
	mov 	cx, 0x5						; Length of buffer
.loop:
	mov 	ax, dx						; Load remainder or inital number into AX
	xor		dx, dx
	mov 	bx, 10d						; We will divide by 10
	div 	bx							; Divide by DX (10)
	xchg 	dx, ax						; Save quotient in DL
	or	 	al, 00110000b				; Convert quotient into its ASCII equivalent (effectively add 0x30)
	stosb								; Store the converted digit in the buffer
	loop	.loop						; Loop until CX=0 i.e. when at end of string buffer
	cld									; Clear the direction flag; most things expect left-to-right
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  name: jaspos_strutils_compare
;;  @param	str1	one of the strings to compare
;;  @param	str2	the other string to compare
;;  @return	equal	zero flag set if equal, cleared if inequal
;;  Compares the string at DS:SI with ES:DI
;;
jaspos_strutils_compare:
	pop		bp							; Save the return address from being destroyed
	pop		si							; Load pointer to string 1 into SI
	pop		di							; Load pointer to string 2 into DI
	push	bp							; Put the return address back onto stack ready for RET
.loop:
	xchg	si, di						; Switch DI to be the pointer for now
	lodsb								; Load a byte from string 2
	mov		bl, al						; Move the loaded byte into BX so we can load a byte from the other string
	xchg	si, di						; Switch the registers back so we're loading from the other string next
	lodsb								; Load a byte from string 1

	cmp		al, bl						; Comapre the two bytes from each string
	jne		.inequal					; If not equal, jump accordingly to clear the zero flag and return

	cmp		al, 0						; If end of string, quit
	je		.equal

	cmp		bl, 0						; If end of string, quit
	je		.equal
	jmp		.loop

.equal:
	xor		ax, ax						; Zero-out AX to indicate equality
	cmp		ax, ax						; Set the zero flag too
	ret
.inequal:
	mov		ax, 1						; Set AX to 1 to indicate difference
	cmp		ax, 2						; And compare it with something it isn't to clear the zero flag
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  name: jaspos_strutils_tolower
;;  @param	str1	string to convert
;;  @return
;;  Converts the string at DS:arg1 to have all
;;  lowercase letters. Any non-uppercase letter
;;  is skipped over
;;
jaspos_strutils_tolower:
	pop		bp							; Pop return addresss
	pop		si							; Pop string pointer
	push	bp							; Push return address
	push	di							; Save DI
	mov		di, si						; Make sure we're writing the converted chars to the string
.loop:
	lodsb								; Load next byte from string
	cmp		al, 0						; Are we at the end of the string?
	je		.quit						; If so, exit the loop
	cmp		al, 'A'						; Is the character below 'A'?
	jl		.notchar					; If so, it's not an uppercase char
	cmp		al, 'Z'						; Is the char above 'Z'?
	jg		.notchar					; If so, it's not an uppercase char
	or		al, 00100000b				; Set bit 5 of the byte, thus adding 32 to it, converting it to lowercase
.notchar:
	stosb								; Store the byte
	jmp		.loop						; Do it all over again
.quit:
	pop		di
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  name: jaspos_strutils_toupper
;;  @param	str1	string to convert
;;  @return
;;  Converts the string at DS:arg1 to have all
;;  uppercase letters. Any non-lowercase letter
;;  is skipped over
;;
jaspos_strutils_toupper:
	pop		bp							;
	pop		si
	push	bp
	push	di							; Save DI
	push	ax
	mov		di, si						; Ensure we're writing converted chars into the string
.loop:
	lodsb
	cmp		al, 0						; End of string?
	je		.quit						; If so, quit
	cmp		al, 'a'						; Is the character below 'a'?
	jl		.notchar					; If so, it's not a lowercase char
	cmp		al, 'z'						; Is it above 'z'?
	jg		.notchar					; If so, it's not a lowercase char
	and		al, 11011111b				; Make bit 5 low, thus subtracting 32 from it, making it a lowercase char
.notchar:
	stosb								; Store the byte
	jmp		.loop						; Do it all over again with the next char
.quit:
	pop		ax
	pop		di
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  name: jaspos_strutils_trimleading
;;  @param	str1	string to convert
;;  @return
;;  Cuts leading spaces off a string
;;
jaspos_strutils_trimleading:
	pop		bp
	pop		si
	push	bp
	push	di
	mov		di, si
	push	si							; Push pointer to string
	call	jaspos_strutils_strlen		; Get string's length
	mov		cx, ax						; Ready CX with string length

	mov		si, di						; Put the original pointer back into SI
	push	cx							; Save the string length
.findloop:	; We need to find where the leading spaces stop
	lodsb								; Load next byte in string
	cmp		al, ' '						; Is it a space?
	jnz		.quitloop					; If not, quit
	loop	.findloop					; Otherwise, keep searching until we're at the end of the string
.quitloop:
	pop		cx							; Get our original string length back
	dec		si							; Currently SI points to the character after the last leading space, rectify
	inc		cx							; Because we DEC'd SI, we'll need to INC CX
	rep		movsb						; SI = where spaces end, DI = Raw beginning of string

	pop		di							;
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  name: jaspos_strutils_trimtrailing
;;  @param	str1	string to convert
;;  @return
;;  Moves null-terminator to cut trailing spaces
;;  off a string
;;
jaspos_strutils_trimtrailing:
	pop		bp
	pop		si
	push	bp
	push	di

	push	si
	call	jaspos_strutils_strlen
	mov		cx, ax

	std
	dec		si
.findloop:
	lodsb
	cmp		al, ' '
	jz		.findloop
	cld

	add		si, 2

	mov		di, si
	xor		ax, ax
	stosb

	pop		di
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  name: jaspos_strutils_instr
;;  @param	str1	string to find
;;  @param	str2	string to search in
;;  @return	instr	1 if str2 contains str2, else 0
;;  Searches str2 for an occurence of str1
;;
jaspos_strutils_instr:
	pop		bp
	pop		si			; SI = str2
	pop		di			; DI = str1
	push	bp
	push	cx
	push	dx
	mov		cx, si
	mov		dx, di

.loop:
	xchg	si, di
	lodsb				; Load a byte from str1
	cmp		al, 0		; Is the byte an end-of-string in the string to match?
	jz		.match		; If so, we've just found the string! Let's exit appropriately
	mov		bl, al		; Save it in bl

	xchg	si, di
	lodsb				; Load next byte from str2
	cmp		al, 0		; Is the byte an end-of-string?
	jz		.nomatch	; If so, exit with no match
	cmp		al, bl		; Are the bytes equal?

	jz		.loop
	inc		cx
	mov		si, cx
	mov		di, dx
	jmp		.loop

.match:
	pop		dx
	pop		cx
	mov		ax, 1
	ret

.nomatch:
	pop		dx
	pop		cx
	xor		ax, ax
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  name: jaspos_strutils_trim
;;  @param	string	string to trim
;;  @return	none
;;  Trims both trailing and leading spaces from
;;  string
;;
jaspos_strutils_trim:
	pop		bp
	pop		ax
	push	bp
	push	ax
	push	ax
	call	jaspos_strutils_trimleading
	pop		ax
	push	ax
	call	jaspos_strutils_trimtrailing
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;