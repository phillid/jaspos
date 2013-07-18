;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  name: jaspos_power_connect
;;  @param	none
;;  @return	none
;;  Connects the APM interface or displays an APM
;;  error code on failure
;;
jaspos_power_connect:
	push	power_msgConnecting			; Display a message saying that we're connecting the interface
	call	jaspos_monitor_dispstring	;
	mov		ax, 0x5301					; ax = 0x5301 - connect interface subfunction
	xor		bx, bx						; zero-out bx
	int		0x15						; Int 15.5301 - connect APM interface
	jc		.error						; catch errors from interrupt
.quit:
	ret

.error:
	push	msgFailedWithCode			; Display a message explaining that it failed
	call	jaspos_monitor_dispstring	;
	mov		[free_ram+4], byte 0		; Ensure there'll be a null-terminator
	push	free_ram + 4				; arg1 = buffer
	push	ax							; arg2 = decimal number
	call	jaspos_strutils_d2str		; Convert decimal to string
	push	free_ram					; Load address on NumberBuffer for printing
	call	jaspos_monitor_dispstring	; Print NumberBuffer
	jmp		.quit						; Jump to .quit for some POPping and then return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  name: jaspos_power_shutdown
;;  @param	none
;;  @return	none
;;  Powers the computer off using the (already
;;  connected) APM interface
;;
jaspos_power_shutdown:
	mov		ax, 0x5307					; ax = 5307 - Set power state
	mov		bx, 0x0001					; bx = 0001 - Device: BIOS
	mov		cx, 0x0003					; cx = 0003 - power state: off
	int		0x15						; Int 15.5307 - set power state using APM interface
	jc		.error						; Catch errors
	ret
.error:
	push	msgFailedWithCode			; Warn user of error
	call	jaspos_monitor_dispstring	;
	mov		[free_ram+5], byte 0
	push	free_ram + 4
	push	ax
	call	jaspos_strutils_d2str		; Convert AH to string in NumberBuffer
	push	free_ram					; Print NumberBuffer
	call	jaspos_monitor_dispstring	;
	jmp		jaspos.panic
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;