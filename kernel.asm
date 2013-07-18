%define JASPOS_VERSION		"Jaspos Pre Build 1"
%define STACK_SIZE			0xFFFF
; TO DO: Document all functions with parameters, input and output
;          o Include full commenting of all instructions in functions.
;            Let's get this god damned project into line on the doc
;            side and keep it like that

%include "apijmps.asm"

jaspos:
	mov		ax, cs						; AX = code segment
	mov		ds, ax						; DS = AX = code segment
	mov		es, ax						; ES = AX = code segment
	add		ax, 0x1000					; semgnet(AX) += 1
	mov		ss, ax						; SS = code segment + 1 segment
	xor		dh, dh						; Let's be sure we won't store what crud may be in DH
	mov		[Drive], dx					; Save the drive number that the bootloader passes to us
	mov		sp, STACK_SIZE				; Set stack pointer based upon predefined stack size
	call	jaspos_monitor_clear		; Clear the screen
	call	jaspos_disk_get_info		; Load the boot disk's info into memory
	push	msgLoading					; Display a loading message
	call	jaspos_monitor_dispstring	;
	push	0x3000						; Set the cursor pos for right hand side of screen
	call	jaspos_monitor_setcursorxy	; Set the cursor position
	call	jaspos_monitor_updatecursor
	push	msgPoolClosed				; Print the string
	call	jaspos_monitor_dispstring	;
	call	jaspos_bootbanner			; Print our nice banner showing disk number, label etc

;#######################################################################

	mov		ah, 4
	int		0x1A

	mov		[free_ram + 4], byte 0
	push	free_ram + 3
	push	cx
	call	jaspos_strutils_hex2str
	push	free_ram
	call	jaspos_monitor_dispstring

	push	free_ram + 3
	push	dx
	call	jaspos_strutils_hex2str
	push	free_ram
	call	jaspos_monitor_dispstring

	push	msgNewLine
	call	jaspos_monitor_dispstring

	mov		ah, 2
	int		0x1A

	push	free_ram + 3
	push	cx
	call	jaspos_strutils_hex2str
	push	free_ram
	call	jaspos_monitor_dispstring

	push	free_ram + 3
	mov		dl, dh
	xor		dh, dh
	push	dx
	call	jaspos_strutils_hex2str
	push	free_ram + 2
	call	jaspos_monitor_dispstring

;#######################################################################
%include "panic.asm"
%include "emergencyshell.asm"
.halt:
	call	jaspos_keyb_getkey
	jmp		.halt						; Loop


%include "bootbanner.asm"				; monitor.asm	- printing to screen etc.
%include "monitor.asm"					; monitor.asm	- printing to screen etc.
%include "power.asm"					; power.asm		- APM functions
%include "diskio.asm"					; diskio.asm	- Functions for talking to floppy disks
%include "keyb.asm"						; keyb.asm		- getting keypresses from keyboards etc.
%include "strutils.asm"					; strutils.asm	- string length and string processing
%include "strings.asm"					; strings.asm	- not to be comfused with strutils.asm string constants in the operating system
free_ram: