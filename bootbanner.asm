;#######################################
;  BOOT BANNER
;  Displays a nice info banner on boot
jaspos_bootbanner:
	; Print nice horizontal line
	push	msgHLine
	call	jaspos_monitor_dispstring

	; Show version
	push	msgVersion
	call	jaspos_monitor_dispstring

	; Show compile date
	push	msgCompileDate
	call	jaspos_monitor_dispstring

	; Print disk label
	push	msgDiskLabel
	call	jaspos_monitor_dispstring

	; Convert and print Drive number
	mov		[free_ram+5], byte 0
	push	free_ram + 4				; Convert drive number to a string.
	push	word [Drive]				; This code preps the buffer ready for the banner, in case a slow processor's
	call	jaspos_strutils_d2str		; running the code - just to make the display as smooth as possible
	push	msgDrive
	call	jaspos_monitor_dispstring
	push	free_ram
	call	jaspos_monitor_dispstring
	push	msgNewLine
	call	jaspos_monitor_dispstring

	push	msgStackSize
	call	jaspos_monitor_dispstring
	mov		[free_ram+4], byte 0
	push	free_ram + 3
	push	STACK_SIZE
	call	jaspos_strutils_hex2str
	push	free_ram
	call	jaspos_monitor_dispstring
	push	msgNewLine
	call	jaspos_monitor_dispstring

	; Print nice horizontal line
	push	msgHLine
	call	jaspos_monitor_dispstring
	ret
;#######################################