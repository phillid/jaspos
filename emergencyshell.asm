;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	push	msgEnteringShell
	call	jaspos_monitor_dispstring
.eshell:
	push	msgPrompt
	call	jaspos_monitor_dispstring		; Show the prompt

	push	free_ram						; Buffer = free ram
	push	32d								; Max chars to read = 32
	call	jaspos_keyb_getstring			; Get a command

	push	msgNewLine
	call	jaspos_monitor_dispstring

	push	free_ram
	call	jaspos_strutils_tolower

	push	cmdExit
	push	free_ram
	call	jaspos_strutils_compare
	jz		.quit

	push	cmdVersion
	push	free_ram
	call	jaspos_strutils_compare
	jz		.eshell_version

	push	cmdCompileDate
	push	free_ram
	call	jaspos_strutils_compare
	jz		.eshell_compiledate

	push	cmdOff
	push	free_ram
	call	jaspos_strutils_compare
	jz		.eshell_off

	push	cmdHelp
	push	free_ram
	call	jaspos_strutils_compare
	jz		.eshell_help


	jmp		.eshell


.eshell_version:
	push	msgVersion
	call	jaspos_monitor_dispstring
	jmp		.eshell

.eshell_compiledate:
	push	msgCompileDate
	call	jaspos_monitor_dispstring
	jmp		.eshell

.eshell_off:
	call	jaspos_power_connect
	jmp		jaspos_power_shutdown

.eshell_help:
	push	msgShellHelp
	call	jaspos_monitor_dispstring
	jmp		.eshell

.quit: