TitleScreen:						;The title screen with its music and the scrolling credits; Start leaves
	lda.w #$0198					; the blank tile and the small font above the title tiles
	sta.w blankchar
	inc a
	sta.w smallfontchars
	stz.w charofs
	stz.w charofs2
	jsl.l forceblack				; blank the screen
	jsl.l InitPPU					; PPU registers off/clear
	sep #$20						; 8-bit A
	cli
	lda.w RDNMI						; enable NMI and auto-joypad read
	lda.b #NMITIMEN_NMI|NMITIMEN_JOY
	sta.w NMITIMEN
	lda.b #$03						; sprite size and name base
	sta.w OBSEL
	lda.b #BGMODE_1					; BG mode 1
	sta.w BGMODE
	lda.b #$00
	sta.w BG1SC
	lda.b #$04
	sta.w BG2SC
	lda.b #$11
	sta.w BG12NBA
	lda.b #TM_BG1|TM_BG2
	sta.w TM
	rep #$30						; 16-bit registers
	lda.w blankchar
	ldx.w #$07FE
.clr:								; clear the text map
	sta.l textmap,x
	dex
	dex
	bpl .clr
	lda.w #Title1Map				; Title1Map (packed): map $700, palette $700, tiles $800
	sta.b tmp0
	lda.w #Title1Map>>16
	sta.b tmp1
	jsl.l DecompressBytecode
	lda.l TestList					; first map word fills backmap
	ldx.w #$07FE
.fill:								; fill the back map
	sta.l backmap,x
	dex
	dex
	bpl .fill
	ldx.w #$06FE
.map:								; copy the title map to the back map
	lda.l TestList,x
	sta.l backmap,x
	dex
	dex
	bpl .map
	ldx.w #$057E					; rows 0-21: priority
.prio:								; set the priority bit on the back map
	lda.l backmap,x
	ora.w #$2000
	sta.l backmap,x
	dex
	dex
	bpl .prio
	lda.w #$1000					; VRAM address $1000
	sta.w VMADDL
	ldx.w #$0000
.tiles:								; copy the title tiles to VRAM
	lda.l TestList+$800,x
	sta.w VMDATAL
	inx
	inx
	cpx.w #$3300
	bne .tiles
	sep #$20						; 8-bit A
	stz.w CGADD
	ldx.w #$0000
.pal:								; load the title palette
	lda.l TestList+$700,x
	sta.w CGDATA
	inx
	cpx.w #$0100
	bne .pal
	rep #$30						; 16-bit registers
	ldx.w #$0010
.clearvr:							; clear the rest of VRAM
	stz.w VMDATAL
	dex
	bne .clearvr
	lda.w #SmallFontTiles			; remapped with PixelRemap8F
	sta.b tmp0
	lda.w #SmallFontTiles>>16
	sta.b tmp1
	jsl.l DecompressBytecode
	lda.w #unpackbuf&$FFFF			; remap the font pixels
	sta.b a0
	lda.w #unpackbuf>>16
	sta.b a0+2
	lda.w #PixelRemap8F
	sta.b a1
	lda.w #PixelRemap8F>>16
	sta.b a1+2
	lda.w #$0064
	sta.b d0
	jsl.l remap						; remap the 4bpp pixels ([a0] data, [a1] table, d0 tiles)
	jsl.l StartSong6				; start the title music
	jsl.l printz					; print the string that follows
	%StringCp(CC_Font1Pal3,$00,$1C)
	stz.b d0
	lda.w #Credits					; a0 = the credits text
	sta.b a0
	lda.w #Credits>>16
	sta.b a0+2
	lda.w #textmap					; DMAList: textmap $1000 bytes to vram 0 each frame
	sta.w DMAList
	lda.w #textmap>>16
	sta.w DMAList+dmabank
	lda.w #$1000
	sta.w DMAList+dmalen
	stz.w DMAList+dmavram
	lda.w #dmasize
	sta.b DMAlistend
	lda.w #VBlank_VScroll			; title vblank handler
	sta.b vbint
	lda.w #$0001					; fade in
	sta.b fadein
.wait1:								; wait for the next frame
	cmp.b vbint
	beq .wait1
.top2:								;next credits page
	ldy.w #$0002					; next credits page
	lda.b [a0],y
	and.w #$00FF
	cmp.w #$00FF					; end of the credits
	bne .top4
	jmp.w .exit
.top4:								;blank the 6 rows below the screen
	lda.w printy					; blank the 6 rows below the screen
	pha
	ldx.w #$0006
.erase:								; erase the credits text
	stz.w printx
	txa
	clc
	adc.b $01,s
	and.w #$001F
	sta.w printy
	lda.w #CreditsBlank				; blank line text
	sta.b a1
	lda.w #CreditsBlank>>16
	sta.b a1+2
	jsl.l print						; print it
	dex
	bpl .erase
	lda.b $01,s
	sta.w printy
.top4x:								;print the page lines centred
	lda.w #34						; printx = (34 - length) / 2
	sec
	sbc.b [a0]
	lsr a
	sta.w printx
	lda.b a0
	sta.b a1
	lda.b a0+2
	sta.b a1+2
	jsl.l print						; print it
	lda.w printy
	inc a
	and.w #$001F
	sta.w printy
	lda.b [a0]						; next line of the page
	clc
	adc.b a0
	sta.b a0
	ldy.w #$0002
	lda.b [a0],y
	and.w #$00FF
	sta.b d3
	cmp.w #$00FE					; $FE: last page, $FF: end
	beq .scroll
	cmp.w #$00FF
	bne .top4x
.scroll:							; scroll the credits
	lda.b [a0]						; advance past the page
	clc
	adc.b a0
	sta.b a0
	pla								; printy moves by 6 rows
	clc
	adc.w #6
	and.w #$001F
	sta.w printy
	sec								; scroll target
	sbc.w #28
	and.w #$001F
	asl a
	asl a
	asl a
	sta.b d1
	jsl.l QueueTextDMA				; queue the changed textmap words
.top5:								;scroll 6*8 lines
	lda.b d0
	inc a
	and.w #$00FF
	sta.b d0
	lda.w #VBlank_VScroll
	sta.b vbint
.wait:								; wait for the next frame
	cmp.b vbint
	beq .wait
	jsl.l ReadPads					; read the pads
	lda.b d3
	cmp.w #$00FE					; $FE: no Start (copyright page)
	bne .nopause
	stz.w padnew1					; copyright page: ignore Start
	stz.w padnew1+2
.nopause:							; no pause: check for Start
	lda.w padnew1					; Start pressed?
	ora.w padnew1+2
	bit.w #JOYSTART
	bne .exit
	lda.b d0
	cmp.b d1
	bne .top5
	lda.b vcount					; 90 frames
	clc
	adc.w #90
	sta.b d2
	lda.b d3
	cmp.w #$00FE
	bne .top6s
	lda.b vcount					; 180 frames for the copyright page
	clc
	adc.w #180
	sta.b d2
.top6:								; hold the page for 120 frames
	jsl.l ReadPads					; read the pads
	lda.b d3
	cmp.w #$00FE
	bne .top6s
	stz.w padnew1
	stz.w padnew1+2
.top6s:								; check for Start on either pad
	lda.w padnew1
	ora.w padnew1+2
	bit.w #JOYSTART
	bne .exit
	lda.b vcount					; page time up?
	cmp.b d2
	bne .top6
	jmp.w .top2						; next page
.exit:								;wait for the default vblank handler, return
	lda.b vbint						; wait for the default vblank handler
	cmp.w #vb2						; the default vblank handler
	bne .exit
	rtl
