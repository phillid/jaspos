Entry:
	mov		ax, cs
	mov		ds, ax
	mov		es, ax
	mov		ss, ax
	;mov		esp, 0x7FFFF
	mov		sp, 0xFFFE
	call	ClearScreen					; Clear the screen
	mov		[Drive], dl					; Get the drive we booted from before we go and mess with dl
	
	push	msgJasposSplash				; 
	call	OutText						; 
	
	call	GetKey						; 
	call	diskio_ResetDiskSystem
	call	diskio_ResetDiskSystem
	call	diskio_ResetDiskSystem
	call	diskio_DumpBootSector
	call	GetKey
	call	apm_ConnectInterface		; 
	call	apm_PowerOff				; 
	jmp		short Halt

GetKey:
	xor		ax, ax						; Zero-out EAX
	int		0x16						; Int 16.00 - wait for keypress
	ret									; Return

Halt:
	xor		ax, ax						; Zero-out AX
	int		0x16						; Int 16.00 - wait for keypress
	jmp		Halt						; Loop

ClearNumberBuffer:
	push	cx							; Push the registers we'll be messing with
	push	ax							; 
	push	di							; 
	mov		al, '0'						; AL = "0" - char to fill buffer with
	mov		cx, 5						; write 0 six times
	mov		di, NumberBuffer			; Destination is NumberBuffer
	rep		stosb						; Store the byte AL CX times
	pop		di							; Pop our regisers back off the stack
	pop		ax							; 
	pop		cx							; 
	ret

ShowFiles:
	pop		ax
	pop		si
	push	ax
	cld
	mov		di, diskio_SectorBuffer
	mov		cx, 16
	rep		movsb
	
	push	msgFile
	call	OutText
	push	diskio_SectorBuffer
	call	OutText
	
	mov		di, diskio_SectorBuffer
	mov		cx, 16
	rep		movsb
	push	msgAuthor
	call	OutText
	push	diskio_SectorBuffer
	call	OutText
	ret

%include "Kernel/textvga.asm"
%include "Kernel/apm.asm"
%include "Kernel/strings.asm"
%include "Kernel/diskio.asm"