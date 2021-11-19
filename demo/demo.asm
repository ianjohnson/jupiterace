	org 16384

dfile:	equ $2400
chrset:	equ $2c00	

start:	xor a
	ld hl,coord_x
	ld (hl),a
	
	call setchr
	call print

	ld hl,coord_x
	inc (hl)

	call setchr
	call print

	ld hl,coord_x
	inc (hl)

	call setchr
	call print
	
	ld hl,coord_x
	inc (hl)

	call setchr
	call print
	
	ld hl,coord_x
	inc (hl)

	call setchr
	call print
	
	ld hl,coord_x
	inc (hl)

	call setchr
	call print
	
	ld hl,coord_x
	inc (hl)

	call setchr
	call print

	call setchr
	call print

	ld hl,coord_x
	inc (hl)

	call setchr
	call print

	ld hl,coord_x
	dec (hl)

	call setchr
	call print
	
	ld hl,coord_x
	dec (hl)

	call setchr
	call print
	
	ld hl,coord_x
	dec (hl)

	call setchr
	call print
	
	ld hl,coord_x
	dec (hl)

	call setchr
	call print
	
	ld hl,coord_x
	dec (hl)

	call setchr
	call print

	ld hl,coord_x
	dec (hl)

	call setchr
	call print
	
	jp (iy)
	
print:	halt
	halt
	ld hl,dfile
	ld (hl),16
	inc hl
	ld (hl),17
	ld de,31
	add hl,de
	ld (hl),18
	inc hl
	ld (hl),19
	ret

setchr: ld a,(coord_x)
	and $07
	inc a
	ld b,a
	ld hl,$ffe0
	ld de,32
sclp:	add hl,de
	djnz sclp
	ex de,hl
	ld hl,figbase
	add hl,de
	ld de,chrset + (16 * 8)
	ld bc,32
	ldir
	ret

coord_x:	defb 0x00
coord_y:	defb 0x00

figbase:
figone: defb 126,129,129,129,129,129,129,126
	defb 0,0,0,0,0,0,0,0
	defb 0,0,0,0,0,0,0,0
	defb 0,0,0,0,0,0,0,0

figtwo:	defb 63,64,64,64,64,64,64,63
	defb 0,128,128,128,128,128,128,0
	defb 0,0,0,0,0,0,0,0
	defb 0,0,0,0,0,0,0,0

figthree:	defb 31,32,32,32,32,32,32,31
	defb 128,64,64,64,64,64,64,128
	defb 0,0,0,0,0,0,0,0
	defb 0,0,0,0,0,0,0,0

figfour:	defb 15,16,16,16,16,16,16,15
	defb 192,32,32,32,32,32,32,192
	defb 0,0,0,0,0,0,0,0
	defb 0,0,0,0,0,0,0,0

figfive:	defb 7,8,8,8,8,8,8,7
	defb 224,16,16,16,16,16,16,224
	defb 0,0,0,0,0,0,0,0
	defb 0,0,0,0,0,0,0,0

figsix:	defb 3,4,4,4,4,4,4,3
	defb 240,8,8,8,8,8,8,240
	defb 0,0,0,0,0,0,0,0
	defb 0,0,0,0,0,0,0,0

figseven:	defb 1,2,2,2,2,2,2,1
	defb 248,4,4,4,4,4,4,248
	defb 0,0,0,0,0,0,0,0
	defb 0,0,0,0,0,0,0,0

figeight:	defb 0,1,1,1,1,1,1,0
	defb 252,2,2,2,2,2,2,252
	defb 0,0,0,0,0,0,0,0
	defb 0,0,0,0,0,0,0,0


	defb 0,0,0,0,7,8,8,8
	defb 0,0,0,0,224,16,16,16
	defb 8,8,8,7,0,0,0,0
	defb 16,16,16,224,0,0,0,0

_figtwo:	defb 0,0,0,7,8,8,8,8
	defb 0,0,0,244,16,16,16,16
	defb 8,8,7,0,0,0,0,0
	defb 16,16,244,0,0,0,0,0
