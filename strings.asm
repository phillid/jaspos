msgAX						db		13,10,	"AX: ",0
msgBX						db				"   BX: ",0
msgCX						db				"   CX: ",0
msgDX						db				"   DX: ",0
msgCS						db		13,10,	"CS: ",0
msgDS						db				"   DS: ",0
msgES						db				"   ES: ",0
msgSS						db				"   SS: ",0
msgGS						db		13,10,	"GS: ",0
msgSI						db				"   SI: ",0
msgDI						db				"   DI: ",0
msgSP						db				"   SP: ",0
msgBP						db		13,10,	"BP: ",0

msgPanic					db		1,0x0C,"Kernel panic! Oh god, oh god, OH GOD!",13,10,1,0x0A,"Oh, just ignore him, here's the register dump you asked for:",1,0x07,0

; Boot banner strings
msgStackSize				db		"Stack Size: ",0
msgCompileDate				db		"Compiled: ",__DATE__," at ",__TIME__," UTC+12",13,10,0
msgDiskLabel				db		"Disk Label: '           '",13,10,0
msgVersion					db		"Version: ",JASPOS_VERSION,13,10,0
msgDrive					db		"Drive: ",0
msgLoading					db		1,0x09,"J",1,0x0A,"a",1,0x0B,"s",1,0x0C,"p",1,0x0D,"o",1,0x0E,"s ",1,0x1F,"http://batchbin.ueuo.com/jaspos.php",1,0x07,0
msgPoolClosed				db		1,0x0C,">",1,0x0A,"Stop saying the pool's closed!",1,0x0C,"<",1,0x07,0
msgHLine		times(80)	db		196d
							db		0

; Status, misc and so on
msgDone						db		"Done",13,10,0
msgSuccess					db		1,0x0A,"Success",1,0x07,13,10,0
msgFailed					db		1,0x0C,"Failed",1,0x07,13,10,0
msgFailedWithCode			db		1,0x0C,"Failed",1,0x07," with error code: ",0
msgNewLine					db		13,10,0
msg0x						db		"0x",0

; Longer-term storage for jaspos_monitor_dispstring
VGAMemPointer				dw		0
CharColour					db		7d

;
power_msgConnecting			db		"Connecting APM Interface...",13,10,0
power_msgShutdown			db		"Powering-off...",13,10,0
power_ShutdownFailed		db		"Jaspos tried to power off, but it failed. Halted instead.",13,10,0

; Tables, lookup tables and so on
strutils_HexLookup			db		"0123456789ABCDEF"

;#### EMERGENCY SHELL ####
msgEnteringShell			db		"Entering emergency shell...",13,10,0
msgPrompt					db		1,0x0A,"Emergency Shell ",1,0x0E,"} ",1,0x07,0
msgShellHelp				db		"exit         - quit and panic",13,10
							db		"version      - show Jaspos version",13,10
							db		"compile date - show Jaspos compile date and time",13,10
							db		"off          - power-off",13,10,0
cmdExit						db		"exit",0
cmdVersion					db		"version",0
cmdCompileDate				db		"compile date",0
cmdOff						db		"off",0
cmdHelp						db		"help",0
;#########################




b_per_s			dw      512				; 000Bh - Bytes per sector
s_per_clu		db      1				; 000Dh - Sector per cluster
s_b4_fat		dw      1				; 000Eh - Reserved sectors
fats			db      2				; 0010h - FAT copies
root_entries	dw      0E0H			; 0011h - Root directory entries
brSectorCount	dw      2880			; 0013h - Sectors in volume, < 32MB
media			db      240				; 0015h - Media descriptor
s_per_fat		dw      9				; 0016h - Sectors per FAT
s_per_track		dw      18              ; 0018h - Sectors per head/track
heads			dw      2				; 001Ah - Heads per cylinder
s_b4_part		dd      0               ; 001Ch - Hidden sectors
num_s			dd      0				; 0020h - Total number of sectors
Drive			dw      0				; 0024h - Physical drive no.