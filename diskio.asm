;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Reset the disk system
;; DL must be disk to reset
diskio_ResetDiskSystem:
	pop		ax
	pop		dx
	push	ax
	xor		ah, ah
	int		0x13
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
diskio_DumpBootSector:
	xor		bx, bx
	mov		es, bx
	mov		bx, diskio_SectorBuffer	; ES:BX = address
	mov		dl, [Drive]			; DL = Drive number
	mov		ah, 2				; AH = Read command
	int		0x13					; Read sector
	push	diskio_SectorBuffer
	call	OutText
	ret
