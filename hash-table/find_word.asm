FIND-WORD:	rst $18			; Pop off Forth stack the address of
					; the search string into DE
		xor a
	        ld b,a
		ld a,(de)
		ld c,a			; C is the length of the string
		inc de			; DE points to string

		ld hl,($3c33)		; CONTEXT system variable value
		ld a,(hl)		; Low byte of address
		inc hl
		ld h,(hl)		; High byte of address
		ld l,a			; HL points to name length field of most
					; recent word in dictionary

LENGTH-CHECK:	ld a,(hl) 		; Fetch word name string length
		and $3f	  		; Bit 6 is immediate word indicator, length in range [1-31]
		jr z,NEXT-WORD		; A zero length indicates this is a "link"
		xor c			; Does word length match what we are looking for
		jr nz,NEXT-WORD		; Word length does not match, next word
	
WORD-MATCH:	push de			; Save the pointer to our search string
		push hl			; Save the pointer to the current word name length field
		call $15e8		; WORDSTART finds start of name A is returned as 0
		ld b,c
WORD-MATCH-LP:	ld a,(de)		; Fetch letter of our search string 
		call $0807		; UPPERCASE the letter
		inc de			; Next letter of our search string
		xor (hl)		; XOR with a letter of the current word name
		and $7f			; Ignore any inverted bit
		inc hl			; Next letter of the current word name
		jr nz,WORD-NO-MATCH	; No match of word name
		djnz WORD-MATCH-LP	; Successful match so far...

					; We have a MATCH!
		pop de			; Pop the name length field into DE, previously held in HL
		inc de			; Increment to the compilation address
		rst $10			; Add compilation address to Forth TOS
		pop de			; Drop search term string pointer
		jp (iy)			; Return to Forth

WORD-NO-MATCH:	pop hl			; Restore name length field pointer 
		pop de			; Restore search string pointer

NEXT-WORD:	dec hl			; Point to the high byte of the link field
		ld a,(hl)
		dec hl
		ld l,(hl)
		ld h,a			; HL is pointer to the next name length field in
					; the dictionary
		or l			; If HL is zero the previous word was the last in
					; the dictionary
		jr nz,LENGTH-CHECK

		jp $068a		; No match found in vocabulary.
					; Call internal word 'stk-zero'


DF 21 3F 00 19 AF 47 4E 23 EB 2A 33 3C 7E 23
66 6F 7E E6 3F 28 1E A9 20 1B D5 E5 CD E8 15 41
1A CD 07 08 13 AE E6 7F 23 20 08 10 F3 D1 13 D7
D1 FD E9 E1 D1 2B 7E 2B 6E 67 B5 20 D5 C3 8A 06

