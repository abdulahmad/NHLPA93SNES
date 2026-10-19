ScoutingReport:						;The scouting report screen: both teams, their ratings and the scrolling
									;commentary until Start
	jsl.l ClearTeamStats			; reset the team stats
	jsl.l forceblack				; blank the screen
	jsl.l InitPPU					; set up the PPU
	sep #$20						; 8-bit A
	cli								; enable interrupts
	lda.w RDNMI						; acknowledge a pending NMI
	lda.b #NMITIMEN_NMI|NMITIMEN_JOY	; enable NMI and joypad reads
	sta.w NMITIMEN
	lda.b #$03						; sprite size and base
	sta.w OBSEL
	lda.b #BGMODE_1					; BG mode 1
	sta.w BGMODE
	lda.b #$00						; BG1 map at $0000
	sta.w BG1SC
	lda.b #$04						; BG2 map at $0400
	sta.w BG2SC
	lda.b #$11						; tile bases for BG1 and BG2
	sta.w BG12NBA
	lda.b #TM_BG1|TM_BG2			; show BG1 and BG2
	sta.w TM
	rep #$30						; 16-bit registers
	stz.w tmgoalie					; clear tmgoalie
	stz.w tmgoalie+2
	lda.w #$0025					; character layout: blank $25
	sta.w blankchar
	inc a							; score tiles follow the blank
	sta.w scorechars
	clc
	adc.w #$0195					; small font follows
	sta.w smallfontchars
	adc.w #$0064					; framer tiles follow
	sta.w Framercset
	adc.w #$0004					; Ron Barr tiles follow
	sta.w ronbarrchars
	stz.w charofs					; no character offset
	stz.w charofs2
	lda.w blankchar
	ldx.w #$07FE					; clear the text map with the blank
.clrtext:							; clear the text map
	sta.l textmap,x
	dex
	dex
	bpl .clrtext
	lda.w #ScoutMap					; EASN map, compressed
	sta.b tmp0
	lda.w #ScoutMap>>16
	sta.b tmp1
	jsl.l DecompressBytecode		; unpack
	ldx.w #$03FE					; copy the unpacked map into the back map
.copymap:							; copy the scouting map to the back map
	lda.l TestList,x
	sta.l backmap,x
	sta.l backmap+$400,x
	dex
	dex
	bpl .copymap
	lda.w #$1000					; VRAM address $1000
	sta.w VMADDL
	ldx.w #$0000
.easntiles:							; EASN tiles to VRAM
	lda.l TestList+$400,x			; EASN tiles to VRAM
	sta.w VMDATAL
	inx
	inx
	cpx.w #$04A0					; $04A0 bytes
	bne .easntiles
	ldx.w #$0010					; clear $10 words of VRAM
.padvram:							; clear the rest of VRAM
	stz.w VMDATAL
	dex
	bne .padvram
	lda.w #TeamBlocksTiles			; team blocks tiles, compressed
	sta.b tmp0
	lda.w #TeamBlocksTiles>>16
	sta.b tmp1
	jsl.l DecompressBytecode		; unpack
	ldx.w #$0000
.blocktiles:						; team block tiles to VRAM
	lda.l TestList,x				; team block tiles to VRAM
	sta.w VMDATAL
	inx
	inx
	cpx.w #$32A0					; $32A0 bytes
	bne .blocktiles
	lda.w #SmallFontTiles			; small font tiles, compressed
	sta.b tmp0
	lda.w #SmallFontTiles>>16
	sta.b tmp1
	jsl.l DecompressBytecode		; unpack
	ldx.w #$0000
.fonttiles:							; small font tiles to VRAM
	lda.l TestList,x				; small font tiles to VRAM
	sta.w VMDATAL
	inx
	inx
	cpx.w #$0C80					; $0C80 bytes
	bne .fonttiles
	ldx.w #$0000
.framertiles:						; framer tiles to VRAM
	lda.l FramerTiles,x				; framer tiles to VRAM
	sta.w VMDATAL
	inx
	inx
	cpx.w #$0080					; $40 words
	bne .framertiles
	jsl.l printz					; print the string that follows
	%StringCp(CC_Font2,$06,$03)
	lda.w #$0019					; frame 25 x 9
	sta.b d0
	lda.w #$0009
	sta.b d1
	jsl.l Framer					; draw the frame d0 x d1
	lda.w #RonBarrMap				; Ron Barr map, compressed
	sta.b tmp0
	lda.w #RonBarrMap>>16
	sta.b tmp1
	jsl.l DecompressBytecode		; unpack
	sep #$20						; 8-bit A
	stz.w CGADD						; palette from color 0
	ldx.w #$0000
.ronpal:							; Ron Barr palette to CRAM
	lda.l TestList+$90,x			; palette bytes in the unpacked data
	sta.w CGDATA
	inx
	cpx.w #$0080					; $80 bytes
	bne .ronpal
	rep #$30						; 16-bit registers
	ldx.w #$0000
.rontiles:							; Ron Barr tiles to VRAM
	lda.l TestList+$190,x			; Ron Barr tiles to VRAM
	sta.w VMDATAL
	inx
	inx
	cpx.w #$07A0					; $07A0 bytes
	bne .rontiles
	stz.b tmp1						; row counter
.ronrow:							; Ron Barr map row
	stz.b tmp0						; column counter
.roncol:							; row column offset
	lda.b tmp1
	sta.b mula						; row * 8
	lda.w #$0008
	sta.b mulb
	jsl.l mulu16					; A = mula * mulb
	adc.b tmp0						; plus column
	asl a
	tax
	lda.l TestList,x				; map entry
	adc.w ronbarrchars				; plus the Ron Barr character base
	pha
	lda.b tmp1
	asl a
	asl a
	asl a
	asl a
	asl a
	adc.b tmp0
	asl a
	tax
	pla
	sta.l backmap+$44,x				; store in the back map
	inc.b tmp0
	lda.b tmp0
	cmp.w #$0008					; 8 columns
	bne .roncol
	inc.b tmp1
	lda.b tmp1
	cmp.w #$0009					; 9 rows
	bne .ronrow
	jsl.l printz					; print the string that follows
	%StringCp(CC_Font1,$02,$0D)
	lda.w VisTeam					; away team
	sta.b d1
	jsl.l DrawTeamBlocks
	jsl.l printz					; print the string that follows
	%StringCp(CC_Font1,$15,$0D)
	lda.w HomeTeam					; home team
	sta.b d1
	jsl.l DrawTeamBlocks
	jsl.l printz					; print the string that follows
	%StringCp(CC_Font1,$11,$0F)
	lda.w #ScoutLabels
	sta.b a1
	lda.w #ScoutLabels>>16
	sta.b a1+2
.pl:								; string length: half of it centers the name
	lda.b [a1]						; label length
	lsr a
	eor.w #$FFFF					; negate
	inc a
	clc
	adc.w #$0011					; center on column $11
	sta.w printx
	jsl.l print						; print it
	inc.w printy
	ldy.w #$0002
	lda.b [a1],y					; next label
	bit.w #$0080					; last label flag
	beq .pl
	jsl.l printz					; print the string that follows
	%StringCp(CC_Font1,$19,$0F)
	lda.w tmdata					; home team data
	sta.b a0
	lda.w #TeamList>>16
	sta.b a0+2
	sta.b a2+2
	lda.w tmdata+2					; away team data
	sta.b a2
	ldy.w #ScoutReport				; ScoutReport offset in the team data
	lda.b [a0],y
	clc
	adc.b a0
	sta.b a0
	lda.b [a2],y
	adc.b a2
	sta.b a2
	jsl.l PrintScoutRatings			; print the ratings
	jsl.l printz					; print the string that follows
	%StringCp(CC_Font1,$04,$0F)
	lda.b a0
	ldx.b a2						; swap the two pointers
	sta.b a2
	stx.b a0
	jsl.l PrintScoutRatings			; print the other team's ratings
	jsl.l InitScoutingDisplay		; InitScoutingDisplay
	lda.w #$001A
	sta.b [a0]
	inc.b a0
	inc.b a0
	inc a
	sta.b [a0]
	inc.b a0
	inc.b a0
	inc a
	inc a
	sta.b [a0]
	inc.b a0
	inc.b a0
	lda.w HomeTeam					; home team
	sta.b d0
	sta.b [a0]
	inc.b a0
	inc.b a0
	lda.w #$001D
	sta.b [a0]
	inc.b a0
	inc.b a0
	lda.w VisTeam					; away team
	cmp.b d0						; same team as home?
	beq .same
	sta.b [a0]						; append the away team
	inc.b a0
	inc.b a0
.same:								; closing paragraph
	lda.w #$001D
	sta.b [a0]
	inc.b a0
	inc.b a0
	dec a
	sta.b [a0]
	inc.b a0
	inc.b a0
	lda.w #$FFFF
	sta.b [a0]
	stz.w asv
	lda.w #$7FFF
	sta.w screentimer				; run until Start
.top:								; main loop, once per frame: upload the text map
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
.vbwait:							; wait for the next frame
	cmp.b vbint						; until it changes
	beq .vbwait
	jsl.l ReadPads					; read the pads
	lda.w padnew1					; new presses on either pad
	ora.w padnew1+2
	bit.w #$1000					; Start: leave
	bne .rtl
	bit.w #$0400
	beq .upd
	lda.w #$FFFF
	sta.w asv
.upd:								; type the next word if the timer allows
	jsl.l UpdateScoutingDisplay		; UpdateScoutingDisplay
	dec.w screentimer				; count down the screen timer
	bpl .top
.rtl:								; return
	rtl
