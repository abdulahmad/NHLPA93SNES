defaultsprites2:					;Clear the sorted objects and set up the arrows, the rink scroll objects
									;and the players from their start tables,
									;then sort them
	ldx.w #$0000					; SortCords (all fields of the 16 objects)
.clr:								; clear one word at a time
	stz.w Xpos,x					; clear one word at a time
	inx
	inx
	cpx.w #$0840
	bne .clr
	ldx.w #$0000
	ldy.w #$0000
	lda.w #$0003					; 4 sorted objects (count - 1 in d0)
	sta.b d0						; loop counter
.sso:								; x, y, frame, attribute from SsoInitTable
	lda.w #$FFFF					; z = -1: not yet sorted
	sta.w ssoz,y
	lda.l SsoInitTable,x			; x, y, frame, attribute come from the init table
	sta.w ssox,y
	lda.l SsoInitTable+2,x
	sta.w ssoy,y
	lda.l SsoInitTable+4,x
	sta.w ssoframe,y
	lda.l SsoInitTable+6,x
	sta.w ssoattr,y
	txa
	clc
	adc.w #$0008					; next 8 byte entry
	tax
	iny
	iny
	dec.b d0
	bpl .sso
	ldx.w #$0000
	ldy.w #$0000
	lda.w #$0004					; 5 far-field objects
	sta.b d0
.ffo:								; x, y, frame from FfoInitTable
	lda.w #$FFFF					; xofs = -1: unset
	sta.w ffoxofs,y
	lda.l FfoInitTable,x
	sta.w ffox,y
	lda.l FfoInitTable+2,x
	sta.w ffoy,y
	lda.l FfoInitTable+4,x
	sta.w ffoz,y
	lda.l FfoInitTable+6,x
	sta.w ffoframe,y
	lda.l FfoInitTable+8,x
	sta.w ffoattr,y
	txa								; next 10 byte entry
	clc
	adc.w #$000A
	tax
	iny
	iny
	dec.b d0
	bpl .ffo
	stz.b d6						; object number
	stz.b a1						; OOlist index
	stz.b a2						; byte offset into SortObjInitTable
	stz.b a3						; byte offset into the sort tables
	stz.b a4
.obj:								; loop over the 16 sort objects
	ldx.b a2
	ldy.b a3
	lda.b d6
	sta.w SCnum,y					; SCnum = object number
	lda.w #$FFFF
	sta.w oldframe,y				; oldframe and pnum = -1
	sta.w pnum,y
	lda.l SortObjInitTable,x		; position, frame, attribute and radii from the init table
	sta.w Xpos,y
	lda.l SortObjInitTable+2,x
	sta.w Ypos,y
	lda.l SortObjInitTable+4,x
	sta.w Zpos,y
	lda.l SortObjInitTable+6,x
	sta.w frame,y
	lda.l SortObjInitTable+8,x
	sta.w attribute,y
	lda.l SortObjInitTable+10,x
	sta.w radiusx,y
	lda.l SortObjInitTable+12,x
	sta.w radiusy,y
	lda.b d6
	asl a
	asl a
	asl a
	tay
	lda.l SortObjInitTable+14,x
	sta.w asslist,y					; assist list entry
	ldy.b a3
	lda.l SortObjInitTable+16,x
	sta.w pflags,y					; object flags
	lda.w #$0000
	sta.w pfnc,y					; default function 0
	cpy.w #$001E					; object $1E (puck shadow): pfnc
	bne .goal
	lda.w #$0001
	sta.w pfnc,y
.goal:								; pfgoal for objects 6-11 and 12-17
	cpx.w #$006C					; pfgoal for objects 6-11 and 12-15, pfteam $34 for 6-11
	rol a
	inc a
	and.w #$0001
	sta.w pfgoal,y
	cpx.w #$006C
	bcc .next
	cpx.w #$00D8
	bcs .next
	lda.w #$0034
	sta.w pfteam,y					; pfteam = $34
.next:								; next sort table slot
	inc.b a3						; next sort table slot
	inc.b a3
	sep #$20						; 8-bit A
	lda.b d6
	asl a							; build the OOlist entry
	ldy.b a1
	sta.w OOlist,y
	inc.b a1						; OOlist index
	rep #$30						; 16-bit registers
	lda.b d6
	ldy.b a4
	sta.w OOlistpos,y				; OOlistpos[object] = object
	inc.b a4
	inc.b a4
	inc.b d6
	lda.b a2
	clc
	adc.w #$0012					; next init table entry
	sta.b a2
	lda.b d6
	cmp.w #$0010					; all 16 objects done?
	beq .sort
	jmp.w .obj
.sort:								; sort and return
	jml.l SprSort					; sort and return
