; Cheers to the BOOT12 bootloader for a lot of these handy definitions.
; Modified them slightly to fit the kernel's needs
;; TO DO: Confirm that these aren't destroyed as kernel loads
;%define	s_per_clu	0x7C00+0x0D		; byte		Sectors per cluster
;%define	s_b4_fat	0x7C00+0x0E		; word		Sectors (in partition) before FAT
;%define	fats		0x7C00+0x10		; byte		Number of FATs
;%define dir_ent		0x7C00+0x11		; word		Number of root directory entries
;%define	s_p_fat		0x7C00+0x16		; word		Sectors per FAT
;%define s_p_t		0x7C00+0x18		; word		Sectors per track
;%define heads		0x7C00+0x1A		; word		Number of heads
;%define s_b4_prt	0x7C00+0x1C		; dword		Sectors before partition

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  name: jaspos_disk_reset
;;  @param	disk	disk number to reset
;;  @return	none
;;  Resets the disk system
;;
jaspos_disk_reset:
	push	dx
	push	ax
	mov		dl, [Drive]				; DL = drive #
	xor		ah, ah					; AH = 0 = reset disk system
	int		0x13					; Perform the reset
	pop		ax
	pop		dx
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  name: jaspos_disk_readsector
;;  @param	buffer	memory buffer to write sector into
;;  @param	sector	relative sector number to load
;;  @return	none
;;  Loads one sector from the boot disk into memory
;;
jaspos_disk_readsector:
	pop		bp						; Save CALL's address
	pop		cx						; Get sector number into CX
	pop		bx						; Get buffer location
	push	bp						; Push CALL's address back onto stack ready for RET

	push	cx
	call	jaspos_disk_make_chs	; Convert the sector number supplied into a useful CHS (cylinder, head, sector) triplet
	;mov		dl, [Drive]				; DL = Drive number
	;xor		dh, dh					; DH = Head
	xor		ch, ch					; CH = Track number
	mov		al, 1					; AL = # Sectors to read
	mov		ah, 2					; AH = Read command
	int		0x13					; Read sector
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  name: jaspos_disk_make_chs
;;  @param	sector	relative sector number to load
;;  @return	CHS		registers ready for INT13
;;  Converts relative sector into CHS, ready for
;;  interrupt 13
;;
jaspos_disk_make_chs:
	pop		bp
	pop		ax
	push	bp

	xor		dx, dx					; DIV's input is DXAX - clear DX so we're only dividing AX
	div		word [s_per_track]		; Sectors per track
	inc		dl						; Sectors start at 1, not 0
	mov		cl, dl					; Sectors belong in CL for int 13h
	mov		ax, bx

	xor		dx, dx					; Now calculate the head
	div		word [s_per_track]		; Sectors per track

	xor		dx, dx
	div		word [heads]			; Floppy sides
	mov		dh, dl					; Head/side
	mov 	ch, al					; Track

	mov dl, [Drive]				; Set correct device

	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  name: jaspos_disk_get_info
;;  @param	none
;;  @return	none
;;  Load the boot sector into memory and patches
;;  the disk info (label, heads etc) into memory
;;  for use by kernel
;;
jaspos_disk_get_info:
	call	jaspos_disk_reset		;
	jc		jaspos.panic			; If the reset fails, just panic

	; We need to call INT13 manually, because jaspos_diskio_readsector
	; relies on having the disk info we're about to load, loaded.
	; Hooray for having to bootstrap
	mov		bx, free_ram			; Buffer location
	mov		dl, [Drive]				; DL = Drive number
	xor		dh, dh					; DH = Head
	xor		ch, ch					; CH = Track number
	mov		al, 1					; AL = # Sectors to read
	mov		ah, 2					; AH = Read command
	int		0x13					; Read sector

	mov		di, msgDiskLabel + 13	; Load the disk label into the disk label message
	mov		si, free_ram+0x2B		; The label starts 0x2B bytes into the sector
	mov		cx, 11d					; Disk labels are 11 bytes long on FAT12
	rep		movsb					; Copy 11 bytes from the sector buffer into the inside of

	mov		cx, 25d					; There are 25d bytes that I want copied and saved
	mov		si, free_ram+0x0B		; Start copying from byte 0x0B
	mov		di, b_per_s				; Start storing at the b_per_s label
	rep		movsb					; Copy the bytes

	ret								; the disk label message, thus filling it with the disk label
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
