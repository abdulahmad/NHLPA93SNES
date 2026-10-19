TeamRosterScreen:					;Team Roster screen: each line's players and one attribute column. The pad
									;moves, Y switches team,
		;   Start leaves
	jsl.l forceblack				; blank the screen
	sep #$20						; 8-bit A
	stz.w BG1HOFS					; scroll both backgrounds to 0
	stz.w BG1HOFS
	stz.w BG1VOFS
	stz.w BG1VOFS
	stz.w BG2HOFS
	stz.w BG2HOFS
	stz.w BG2VOFS
	stz.w BG2VOFS
	lda.b #$00						; BG1 map at $0000
	sta.w BG1SC
	lda.b #$04						; BG2 map at $0400
	sta.w BG2SC
	lda.b #$44						; tile bases for BG1 and BG2
	sta.w BG12NBA
	lda.b #TM_BG1|TM_BG2			; show BG1 and BG2
	sta.w TM
	rep #$30						; 16-bit registers
	lda.w #$FD00					; character offset for the text
	sta.w charofs
	sta.w charofs2
	sta.w printfontset
	stz.b printm
	lda.w smallfontchars
	asl a
	asl a
	asl a
	asl a
	adc.w #$1000					; VRAM address after the small font
	sta.w VMADDL
	lda.w #SmallFontTiles			; small font tiles, compressed
	sta.b tmp0
	lda.w #SmallFontTiles>>16
	sta.b tmp1
	jsl.l DecompressBytecode		; unpack
	stz.b a0
	lda.w #unpackbuf>>16
	sta.b a0+2
	lda.w #PixelRemap8F				; pixel remap table
	sta.b a1
	lda.w #PixelRemap8F>>16
	sta.b a1+2
	lda.w #$0064					; $64 tiles
	sta.b d0
	jsl.l remap						; remap the font pixels
	ldx.w #$0000
.framertiles:
	lda.l FramerTiles,x				; framer tiles to VRAM
	sta.w VMDATAL
	inx
	inx
	cpx.w #$0080
	bne .framertiles
	lda.w scorechars
	asl a
	asl a
	asl a
	asl a
	adc.w #$1000					; VRAM address after the score tiles
	sta.w VMADDL
	lda.w #TeamBlocksTiles			; team blocks tiles, compressed
	sta.b tmp0
	lda.w #TeamBlocksTiles>>16
	sta.b tmp1
	jsl.l DecompressBytecode		; unpack
	ldx.w #$0000
.blocktiles:
	lda.l TestList,x				; team block tiles to VRAM
	sta.w VMDATAL
	inx
	inx
	cpx.w #$32A0
	bne .blocktiles
	lda.w #EASNmap					; EASN map, compressed
	sta.b tmp0
	lda.w #EASNmap>>16
	sta.b tmp1
	jsl.l DecompressBytecode		; unpack
	ldx.w #$0000
.easntiles:
	lda.l TestList+$400,x			; EASN tiles to VRAM
	sta.w VMDATAL
	inx
	inx
	cpx.w #$04A0
	bne .easntiles
	ldx.w #$03FE					; copy the unpacked map into the back map
.copymap:
	lda.l TestList,x
	clc
	adc.w ExtraChars				; plus extra chars
	clc
	adc.w charofs2					; plus the character offset
	sta.l backmap,x
	sta.l backmap+$400,x
	dex
	dex
	bpl .copymap
	lda.w #RonBarrMap				; Ron Barr map, compressed
	sta.b tmp0
	lda.w #RonBarrMap>>16
	sta.b tmp1
	jsl.l DecompressBytecode		; unpack
	sep #$20						; 8-bit A
	stz.w CGADD						; palette from color 0
	ldx.w #$0000
.ronpal:
	lda.l TestList+$90,x			; palette bytes in the unpacked data
	sta.w CGDATA
	inx
	cpx.w #$0080
	bne .ronpal
	rep #$30						; 16-bit registers
	stz.b a2						; a2 = team 0
	lda.w cont1team					; controller 1 team
	sta.b tmp0
	lda.w sflags					; pad swap flag
	bit.w #sfpj
	beq .cont1
	lda.w cont2team
	sta.b tmp0
.cont1:
	lda.b tmp0
	cmp.w #$0002
	bne .gotteam
	lda.w #$0002
	sta.b a2
.gotteam:
	ldy.b a2
	lda.w tmline,y					; line of that team
	inc a
	sta.b d0
	sta.w SelectedPlayerIdx			; start with this player
	stz.w DispAttribCtr				; first attribute column
.redraw:
	jsl.l printz					; print the string that follows
	%StringCp(CC_Font2,$03,$01)
	lda.w #$001A					; frame 26 x 6
	sta.b d0
	lda.w #$0006
	sta.b d1
	jsl.l Framer					; draw the frame d0 x d1
	lda.w blankchar					; blank character
	clc
	adc.w charofs
	ldx.w #$07FE					; clear the text map
.clrtext:
	sta.l textmap,x
	dex
	dex
	bpl .clrtext
	jsl.l printbigz					; big font title
	%StringCtc(CC_Font1Pri,$05,$04,"Team  Roster",CC_Font1Pri,$0B,$01)
	lda.w HomeTeam					; home team
	sta.b d1
	lda.b a2
	beq .home
	lda.w VisTeam
	sta.b d1						; away team
	lda.w #$0030
.home:
	sta.b d0
	jsl.l DrawTeamBlocks			; draw the team blocks
	jsl.l printz					; print the string that follows
	%StringCtctc(CC_Font1Pal2Pri,$08,$0C,"Player",CC_Font1Pal2Pri,$18,$0C,"Rating",CC_Font2Pri,$01,$08)
	lda.w #$000F					; frame 15 x 3
	sta.b d0
	lda.w #$0003
	sta.b d1
	jsl.l Framer					; draw the frame d0 x d1
	jsl.l printz					; print the string that follows
	%StringCp(CC_Font2Pri,$10,$08)
	lda.w #$000F					; frame 15 x 3
	sta.b d0
	lda.w #$0003
	sta.b d1
	jsl.l Framer					; draw the frame d0 x d1
	jsl.l .show						; print the selected line
.loop:
	lda.w #textmap					; upload the text map every frame
	sta.w DMAList
	lda.w #textmap>>16
	sta.w DMAList+dmabank
	lda.w #$1000					; $1000 bytes
	sta.w DMAList+dmalen
	stz.w DMAList+dmavram
	lda.w #$0007
	sta.b DMAlistend
	lda.w #VBlank_List				; wait for the vblank
	sta.b vbint
.vbwait:
	cmp.b vbint						; until it changes
	beq .vbwait
	jsl.l ReadPads					; read the pads
	jsl.l getpzjoy					; joypad state
	jsl.l ProcessInputWithRepeat	; with repeat
	lda.b d1
	bit.w #$1000					; Start
	beq .nostart
	jmp.w .rtl						; leave
.nostart:
	bit.w #$4000					; Y
	bne .team
	stz.b d0						; d0 = 1
	inc.b d0
	bit.w #$0100					; right
	bne .col
	dec.b d0						; d0 = -1
	dec.b d0
	bit.w #$0200					; left
	bne .col
	bit.w #$0800					; down
	bne .line
	inc.b d0						; d0 = 1
	inc.b d0
	bit.w #$0400					; up
	beq .again
.line:								; move the selected line by d0
	lda.b d0
	clc
	adc.w SelectedPlayerIdx
	sta.b d0
	bmi .again						; stay within the list
	cmp.w #$0008					; 8 lines
	bcs .again
	sta.w SelectedPlayerIdx			; new selected line
	jsl.l .show						; reprint
.again:
	jmp.w .loop
.col:
	lda.b d0						; move the attribute column by d0
	clc
	adc.w DispAttribCtr
	sta.b d0
	bmi .again						; not below the first column
	sta.w DispAttribCtr				; new column
	jsl.l .show
	bra .again
.team:
	lda.b a2						; toggle the team
	eor.w #$0002
	sta.b a2
	jmp.w .redraw					; redraw the screen
.show:								;print the selected line and attribute column
	jsl.l printz					; print the string that follows
	%StringCp(CC_Font1Pal2Pri,$02,$09)
	lda.w SelectedPlayerIdx			; selected line
	sta.b d0
	lda.w #RosterLineNames			; line names
	sta.b a1
	lda.w #RosterLineNames>>16
	sta.b a1+2
	jsl.l AdvanceStringPtr			; step to the name
	jsl.l print						; print it
	lda.w #$0011					; x 17
	sta.w printx
	lda.w #$0009					; y 9
	sta.w printy
.top:
	lda.w #PAttribColumns			; attribute columns of skaters
	sta.b a1
	lda.w #PAttribColumns>>16
	sta.b a1+2
	lda.w DispAttribCtr				; column number
	sta.b d0
	lda.w SelectedPlayerIdx
	bne .2							; line 0 is the goalie
	lda.w #GAttribColumns			; goalie attribute columns
	sta.b a1
	lda.w #GAttribColumns>>16
	sta.b a1+2
	bra .2
.next:
	lda.b a1
	clc
	adc.b [a1]
	adc.w #$0004
	sta.b a1
.2:
	lda.b [a1]						; end of the list?
	bmi .check
	dec.b d0
	bpl .next
.check:
	lda.b [a1]
	bpl .found
	dec.w DispAttribCtr				; ran past the end: go back one column
	bra .top
.found:
	jsl.l print						; print it
	lda.b [a1]
	sta.b d4+2
	ldy.w #$0002
	lda.b [a1],y
	sta.b d4
	jsl.l printz					; print the string that follows
	%StringCp(CC_Font1Pri,$00,$0D)
	lda.w #$0020
	sta.b d0
	lda.w #$0013
	sta.b d1
	lda.w blankchar
	sta.b d2
	jsl.l eraser					; erase d0 x d1 with tile d2
	jsl.l printz					; print the string that follows
	%StringCtc(CC_Font1Pal2Pri,$08,$1A,"Y - Switch Teams",CC_Font1Pri,$00,$0E)
	jsl.l GetGoalieCount			; number of goalies
	lda.b d0
	dec a
	sta.b d1
	lda.w #RosterG
	sta.b a4+4
	lda.w #RosterG>>16
	sta.b a4+6
	lda.w #RosterGoalies
	sta.b a3
	lda.w #RosterGoalies>>16
	sta.b a3+2
	lda.w SelectedPlayerIdx
	dec a							; selected line - 1
	sta.b d0
	bmi .row						; goalie line: use the goalie list
	asl a
	asl a
	asl a
	sta.b d0
	ldy.b a2						; team data
	lda.w #TeamList>>16
	sta.b a3+2
	lda.w tmdata,y
	sta.b a3
	ldy.w #LineSets
	clc
	adc.b [a3],y
	sec
	adc.b d0
	sta.b a3
	lda.w #PlayerPositionText		; position text
	sta.b a4+4
	lda.w #PlayerPositionText>>16
	sta.b a4+6
	lda.w #$0004
	sta.b d1
	lda.w SelectedPlayerIdx
	sec
	sbc.w #$0005
	beq .row
	bmi .neg
	bvc .fewer
	bra .row
.neg:
	bvc .row
.fewer:
	dec.b d1
.row:
	lda.w #$0002					; print the names at x 2
	sta.w printx
	lda.b a4+4
	sta.b a1
	lda.b a4+6
	sta.b a1+2
	jsl.l print						; print it
	lda.b a1
	sta.b a4+4
	lda.b a1+2
	sta.b a4+6
	lda.w #$0005
	sta.w printx
	lda.b [a3]						; player number in the line
	inc.b a3
	and.w #$00FF
	dec a							; roster index
	sta.b d0
	jsl.l GetNameandAttrib			; print the name and attribute
	inc.w printy					; next row
	inc.w printy
	dec.b d1
	bpl .row						; more rows?
.rtl:
	rtl
