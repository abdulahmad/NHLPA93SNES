PlayoffScreen:						;In playoff mode, the playoff tree screen with the password; left and
									;right scroll, Start leaves
	lda.w #6						;tile bases: small font 6, big font +100, score/team blocks +100, NHLPA
									;logo +405
	sta.w smallfontchars			; small font tiles first
	clc
	adc.w #100
	sta.w BigFontchars				; big font 100 tiles later
	adc.w #100
	sta.w scorechars				; score and team block tiles
	adc.w #405
	sta.w logochars					; NHLPA logo tiles
	stz.w charofs
	stz.w charofs2
	lda.w OptPlayMode				; not in playoff mode: done
	bne .po
	jmp.w .rtl
.po:								; blank the screen, BG mode 1
	jsl.l forceblack				; blank the screen
	sep #$20						; 8-bit A
	lda.b #BGMODE_1					; BG mode 1
	sta.w BGMODE
	lda.b #$01
	sta.w BG1SC
	lda.b #$01
	sta.w BG12NBA
	lda.b #TM_BG1
	sta.w TM
	rep #$30						; 16-bit registers
	lda.w #$1000					; VRAM address $1000
	sta.w VMADDL
	lda.w #PlayoffTiles				; PlayoffTiles: 128 colors, then 6 tiles
	sta.b tmp0
	lda.w #PlayoffTiles>>16
	sta.b tmp1
	jsl.l DecompressBytecode		; unpack the bracket graphics
	ldx.w #$0000
.treetiles:							; copy the bracket tiles to VRAM
	lda.l unpackbuf+$100,x
	sta.w VMDATAL
	inx
	inx
	cpx.w #$00C0
	bne .treetiles
	ldx.w #$0000
.treepal:							; load the bracket palette
	lda.l unpackbuf,x
	sta.l palbuffer,x
	inx
	inx
	cpx.w #$0100
	bne .treepal
	lda.w #SmallFontTiles			; SmallFontTiles twice: remapped with PixelRemap8F, then with PixelRemap83
	sta.b tmp0
	lda.w #SmallFontTiles>>16
	sta.b tmp1
	jsl.l DecompressBytecode		; decompress them
	lda.w #unpackbuf&$FFFF
	sta.b a0
	lda.w #unpackbuf>>16
	sta.b a0+2
	lda.w #PixelRemap8F				; remap table for the first copy
	sta.b a1
	lda.w #PixelRemap8F>>16
	sta.b a1+2
	lda.w #$0064
	sta.b d0
	jsl.l remap						; remap the 4bpp pixels ([a0] data, [a1] table, d0 tiles)
	lda.w #SmallFontTiles			; second copy
	sta.b tmp0
	lda.w #SmallFontTiles>>16
	sta.b tmp1
	jsl.l DecompressBytecode
	lda.w #unpackbuf&$FFFF
	sta.b a0
	lda.w #unpackbuf>>16
	sta.b a0+2
	lda.w #PixelRemap83				; remap table for the second copy
	sta.b a1
	lda.w #PixelRemap83>>16
	sta.b a1+2
	lda.w #$0064
	sta.b d0
	jsl.l remap						; remap the 4bpp pixels ([a0] data, [a1] table, d0 tiles)
	lda.w #TeamBlocksTiles			; team block tiles
	sta.b tmp0
	lda.w #TeamBlocksTiles>>16
	sta.b tmp1
	jsl.l DecompressBytecode
	ldx.w #$0000
.blocktiles:						; copy the team block tiles to VRAM
	lda.l unpackbuf,x
	sta.w VMDATAL
	inx
	inx
	cpx.w #$32A0
	bne .blocktiles
	lda.w #$0000					; clear textmap and backmap (128 x 32 map)
	ldx.w #$1FFE
.clr:								; clear the text map
	sta.l textmap,x
	dex
	dex
	bpl .clr
	lda.w #potree					; a1 = potree
	sta.b a1
	lda.w #$0000
	sta.b a1+2
	lda.w #PlayoffTreeSetup			; a0 = PlayoffTreeSetup level gamelevel
	sta.b a0
	lda.w #PlayoffTreeSetup>>16
	sta.b a0+2
	lda.w gamelevel					; tree setup for this game level
	asl a
	tay
	lda.b [a0],y
	adc.b a0
	sta.b a0
	lda.b [a0]						; number of team blocks
	inc.b a0
	and.w #$00FF
	sta.b d4
.team:								;DrawTeamBlocks: team block of tree slot d4 at x, y
	lda.b [a0]
	inc.b a0
	and.w #$00FF
	sta.w printx
	stz.w printa
	lda.b [a0]
	inc.b a0
	and.w #$00FF
	sta.w printy
	lda.b [a1]						; team of the slot
	inc.b a1
	and.w #$00FF
	sta.b mula
	ldy.w potreeteam				; the user's team: palette 7
	eor.w potree,y
	and.w #$00FF
	bne .other
	lda.w #$1C00
	sta.w printa
.other:								; 36 bytes per Teamblocksmap entry
	lda.w #36						; 36 bytes per Teamblocksmap entry
	sta.b mulb
	jsl.l mulu16					; 16-bit multiply
	tay
	lda.w #Teamblocksmap
	sta.b a2
	lda.w #Teamblocksmap>>16
	sta.b a2+2
	lda.w printy					; textmap offset (y * 128 + x) * 2
	asl a
	asl a
	asl a
	asl a
	asl a
	asl a
	asl a
	adc.w printx
	asl a
	tax
	lda.w #9						; 9 words per row
	sta.b tmp0
	sta.b tmp1
.row1:								; top row of the team block
	lda.b [a2],y
	clc
	adc.w scorechars
	adc.w charofs
	ora.w printa
	sta.l textmap,x
	iny
	iny
	inx
	inx
	dec.b tmp0
	bne .row1
.row2:								; bottom row of the team block
	lda.b [a2],y
	clc
	adc.w scorechars
	adc.w charofs
	ora.w printa
	sta.l textmap+(3*$40)+(23*2),x
	iny
	iny
	inx
	inx
	dec.b tmp1
	bne .row2
	dec.b d4						; next team block
	beq .arrow
	jmp.w .team
.arrow:								;DrawTreeArrow: arrow column (23 rows of PlayoffBracketMap) at x; $FF ends
	lda.b [a0]						; next arrow column
	inc.b a0
	and.w #$00FF
	cmp.w #$00FF
	beq .scores
	asl a							; column n of PlayoffBracketMap (23 rows of 12 words)
	adc.w #PlayoffBracketMap
	sta.b tmp0
	lda.w #PlayoffBracketMap>>16
	sta.b tmp1
	lda.b [a0]
	inc.b a0
	and.w #$00FF
	asl a
	tax
	ldy.w #23						; 23 rows
.arrowrow:							; copy an arrow row into the text map
	lda.b [tmp0]
	sta.l textmap+(8*$40)+(0*2),x
	lda.b tmp0
	clc
	adc.w #24
	sta.b tmp0
	txa
	adc.w #$0100
	tax
	dey
	bne .arrowrow
	bra .arrow
.rtl:								; return
	rtl
.scores:							;scroll limits, then the series scores (not for single games)
	lda.b [a0]						; Hscroll limits (x8)
	inc.b a0
	and.w #$00FF
	asl a
	asl a
	asl a
	sta.b d2+2
	lda.b [a0]						; right scroll limit
	inc.b a0
	and.w #$00FF
	asl a
	asl a
	asl a
	sta.b d0+2
	stz.b d3+2
	jsl.l printz					; print the string that follows
	%StringCp(CC_Font1Pal1,$00,$00)
	lda.b bosgames					; single games: no scores
	cmp.w #7
	beq .logo
	lda.b [a0]						; number of series scores
	inc.b a0
	and.w #$00FF
	sta.b d4
	beq .logo
	stz.b a2
.score:								; print the series score
	lda.b [a0]						; score X
	inc.b a0
	and.w #$00FF
	sta.w printx
	lda.b [a0]						; score Y
	inc.b a0
	and.w #$00FF
	asl a
	asl a
	sta.w printy
	lda.w #mesarea
	sta.b a1
	lda.w #mesarea>>16
	sta.b a1+2
	lda.w #5						; mesarea "<top team wins>-<bottom team wins>"
	sta.w mesarea
	ldx.b a2
	lda.w gspotwins,x				; top team wins
	adc.w #'0'
	sta.w mesarea+2
	lda.w #'-'
	sta.w mesarea+3
	lda.w gspobwins,x				; bottom team wins
	adc.w #'0'
	sta.w mesarea+4
	jsl.l print						; print it
	inc.b a2
	inc.b a2
	dec.b d4
	bne .score
.logo:								;the NHLPA logo: palette row 2, tiles at logochars, map at x 60, y 2
	lda.w #NHLPALogo				; logo graphics
	sta.b tmp0
	lda.w #NHLPALogo>>16
	sta.b tmp1
	jsl.l DecompressBytecode
	ldx.w #$001E					; logo palette to palette row 2
.logopal:							; load the logo palette
	lda.l unpackbuf+$A0,x
	sta.l palbuffer+(6*$20),x
	dex
	dex
	bpl .logopal
	lda.w logochars					; logo tiles to vram logochars
	asl a
	asl a
	asl a
	asl a
	adc.w #$1000
	sta.w VMADDL
	ldx.w #$0000
.logotiles:							; copy the logo tiles to VRAM
	lda.l unpackbuf+$1A0,x
	sta.w VMDATAL
	inx
	inx
	cpx.w #$06A0
	bne .logotiles
	stz.b tmp1
.logorow:							; logo rows
	stz.b tmp0
.logocol:							; logo columns
	lda.b tmp1						; logo map entry
	sta.b mula
	lda.w #8
	sta.b mulb
	jsl.l mulu16					; 16-bit multiply
	adc.b tmp0
	asl a
	tax
	lda.l unpackbuf,x
	adc.w logochars					; add the logo tile base
	ora.w #$1800					; palette 6
	pha
	lda.b tmp1
	asl a
	asl a
	asl a
	asl a
	asl a
	asl a
	asl a
	adc.b tmp0
	asl a
	tax
	pla
	sta.l backmap+(9*$40)+(28*2),x	; store into the back map (row 9, column 28)
	inc.b tmp0
	lda.b tmp0
	cmp.w #8
	bne .logocol
	inc.b tmp1
	lda.b tmp1
	cmp.w #10
	bne .logorow
	jsl.l ClearSprites				; clear the sprite table
	jsl.l printz					; print the string that follows
	%StringBt(CC_Font1Pal1,"8d")
	jsl.l PWprint
	lda.w #$0180					; start in the middle
	sta.w Hscroll
	stz.w printx
	stz.w printy
	lda.w #32
	sta.b d0
	lda.w #4
	sta.b d1
	lda.w BigFontchars				; blank the top and bottom rows with big font tile 0
	ora.w #$1000
	sta.b d2
	jsl.l eraser					; d0 x d1, tile d2
	stz.w printx
	lda.w #104
	sta.w printy
	lda.w #32
	sta.b d0
	lda.w #24
	sta.b d1
	lda.w BigFontchars
	ora.w #$1000
	sta.b d2
	jsl.l eraser					; d0 x d1, tile d2
	jsl.l StartSngPO				; keep the music going
.scroll:							;clamp Hscroll, queue the 128-column map window, wait a frame
	lda.w Hscroll
	cmp.b d2+2						; clamp to the left limit (d2+2)
	bcs .min
	lda.b d2+2
.min:								; clamp to the right limit (d0+2)
	cmp.b d0+2
	bcc .max
	lda.b d0+2
.max:								; store the clamped scroll
	sta.w Hscroll
	lsr a
	lsr a
	lsr a
	asl a							; source column in textmap
	adc.w #textmap					; source column in textmap
	sta.b tmp0
	stz.b tmp1
	ldy.w #$0000
.dma:								; queue the scroll DMA
	lda.b tmp1
	sta.w DMAList+dmavram,y
	clc
	adc.w #$0020
	sta.b tmp1
	adc.w #$03E0
	sta.w DMAList+dmasize+dmavram,y
	lda.b tmp0
	sta.w DMAList,y
	adc.w #$0040
	sta.w DMAList+dmasize+dmasrc,y
	adc.w #$00C0
	sta.b tmp0
	lda.w #textmap>>16
	sta.w DMAList+dmabank,y
	sta.w DMAList+dmasize+dmabank,y
	lda.w #$0040
	sta.w DMAList+dmalen,y
	lda.w #$000A
	sta.w DMAList+dmasize+dmalen,y
	tya
	adc.w #2*dmasize
	tay
	cpy.w #32*2*dmasize				; 32 rows: 2 dma entries each
	bne .dma
	sty.b DMAlistend				; end of the DMA list
	lda.w #VBlank_Cram				; playoff vblank handler
	sta.b VBint
.wait:								; wait for the next frame
	cmp.b VBint
	beq .wait
.pad:								; read the pads
	jsl.l ReadPads					; read the pads
	lda.w padnew1
	ora.w padnew1+2
	cmp.w #sbut
	bne .frame
	jmp.w .rtl
.frame:								;color 1 of palette 7 blends between the .blink colors (30 frame cycle)
	lda.b Vcount					; once per frame
	cmp.b d7
	beq .pad
	sta.b d7
	sta.b mulb						; Vcount mod 30, then the half
	lda.w #30
	sta.b mula
	jsl.l divu16					; mulb / mula
	lda.b mulres+2
	sta.b tmp0
	lda.w #2
	sta.b mula
	jsl.l divu16					; mulb / mula
	lda.b mulres+2
	asl a
	tax
	lda.l .blink,x					; first blink color
	xba								; red channel
	and.w #$00FF
	lsr a
	lsr a
	sta.b tmp1
	lda.l .blink+2,x				; second blink color
	xba
	and.w #$00FF
	lsr a
	lsr a
	sec
	sbc.b tmp1
	sta.b mula
	lda.b tmp0
	sta.b mulb
	jsl.l muls32					; signed 32-bit multiply
	lda.w #30
	sta.b mula
	jsl.l divs						; signed divide
	adc.b tmp1
	and.w #$001F
	xba
	and.w #$FF00
	asl a
	asl a
	sta.b tmp2
	lda.l .blink,x					; green channel
	lsr a
	lsr a
	lsr a
	lsr a
	lsr a
	and.w #$001F
	sta.b tmp1
	lda.l .blink+2,x
	lsr a
	lsr a
	lsr a
	lsr a
	lsr a
	and.w #$001F
	sec
	sbc.b tmp1
	sta.b mula
	lda.b tmp0
	sta.b mulb
	jsl.l muls32					; signed 32-bit multiply
	lda.w #30
	sta.b mula
	jsl.l divs						; signed divide
	adc.b tmp1
	and.w #$001F
	asl a
	asl a
	asl a
	asl a
	asl a
	tsb.b tmp2
	lda.l .blink,x					; blue channel
	and.w #$001F
	sta.b tmp1
	lda.l .blink+2,x
	and.w #$001F
	sec
	sbc.b tmp1
	sta.b mula
	lda.b tmp0
	sta.b mulb
	jsl.l muls32					; signed 32-bit multiply
	lda.w #30
	sta.b mula
	jsl.l divs						; signed divide
	adc.b tmp1
	and.w #$001F
	ora.b tmp2
	sta.l palbuffer+(7*$20)+(1*2)	; write the blended color
	lda.w joypad1					; held: left/right scroll
	ora.w joypad2
	cmp.w #lbut
	beq .left
	cmp.w #rbut
	beq .right
.move:								; apply the scroll step
	lda.w Hscroll
	clc
	adc.b d3+2
	sta.w Hscroll
	cmp.w #$0058					; stop at round columns $58,$B0,$108,$180,$1F8,$250,$2A8
	beq .stop
	cmp.w #$00B0
	beq .stop
	cmp.w #$0108
	beq .stop
	cmp.w #$0180
	beq .stop
	cmp.w #$01F8
	beq .stop
	cmp.w #$0250
	beq .stop
	cmp.w #$02A8
	bne .again
.stop:								;stop at the round columns
	stz.b d3+2						; stop scrolling
.again:								; far branch to .scroll
	jmp.w .scroll
.blink:								;BGR555 colors the user's team block blinks between (white, blue, white)
	dw $7FFF,$7E10,$7FFF
.left:								; scroll left
	lda.w #$FFFF					; scroll step -1
	sta.b d3+2
	jmp.w .move
.right:								; scroll right
	lda.w #$0001
	sta.b d3+2
	jmp.w .move
