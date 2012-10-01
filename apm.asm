;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Connect APM interface
apm_ConnectInterface:
	push	ax							; Push some registers
	push	bx							; 
	mov		si, apm_msgConnectingInterface	; Display a message saying that we're connecting the interface
	call	OutText						; 
	mov		ax, 0x5301					; 0x5301 - connect interface subfunction
	xor		bx, bx						; zero-out bx
	int		0x15						; Int 15.5301 - connect APM interface
	jc		.error						; Jump to .error if interrupt set cf on error
.quit:
	pop		bx							; Pop our registers back off the stack
	pop		ax							; 
	ret
.error:
	mov		si, msgFailedWithCode		; Display a message explaining that it failed
	call	OutText						; 
	xor		dx, dx						; clear DX
	mov		dl, ah						; load DL with number to convert
	call	NumberToString				; Convert DL to string in NumberBuffer
	mov		si, NumberBuffer			; Load address on NumberBuffer for printing
	call	OutText						; Print NumberBuffer
	jmp		.quit						; Jump to .quit for some POPping and then return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Power-off the computer using APM interface
apm_PowerOff:
	mov		ax, 0x5307					; 5307 - Set power state
	mov		bx, 0x0001					; 0001 - Device: BIOS
	mov		cx, 0x0003					; 0003 - power state: off
	int		0x15						; Int 15.5307 - set power state using APM interface
	jc		.error
	ret
.error:
	mov		si, msgFailedWithCode		; Print a message to tell the user a failiure happened
	call	OutText						; 
	xor		dx, dx						; Zero-out DX
	mov		dl, ah						; Load DL with number to convert
	call	NumberToString				; Convert DL to string in NumberBuffer
	mov		si, NumberBuffer			; Load NumberBuffer address for printing
	call	OutText						; Print NumberBuffer
	mov		si, msgNewLine				; 
	call	OutText						; 
	mov		si, apm_msgPowerOffFailed	; 
	call	OutText						; 
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;