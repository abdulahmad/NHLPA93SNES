DrawGameSetupBack:					;Draw the game setup screen backdrop with the NHLPA logo
	lda.w blankchar					; blank character
	ldx.w #$07FE					; 2KB
.clr:								; clear the text map
	sta.l textmap,x
	dex
	dex
	bpl .clr
	lda.w #GameSetUpMap				; backdrop map
	sta.b tmp0
	lda.w #GameSetUpMap>>16
	sta.b tmp1
	jsl.l DecompressBytecode		; decompress it
	ldx.w #$07FE					; copy to the back map
.map:								; copy the map words to the back map
	lda.l unpackbuf,x				; map word
	and.w #$DFFF					; priority bit off
	sta.l backmap,x					; to the back map
	dex
	dex
	bpl .map
	stz.b textdirtylo				; text all dirty
	lda.w #$03FF					; 1023 words
	sta.b textdirtyhi
	lda.w #NHLPALogo				; the NHLPA logo (packed)
	sta.b tmp0
	lda.w #NHLPALogo>>16
	sta.b tmp1
	jsl.l DecompressBytecode		; decompress the logo
	lda.w #$0009					; 10 rows
	sta.b tmp1
.row:								; next row of 8 columns
	lda.w #$0007					; 8 columns
	sta.b tmp0
.col:								; row times 8
	lda.b tmp1
	sta.b mula						; row
	lda.w #$0008
	sta.b mulb						; times 8
	jsl.l mulu16					; 16-bit multiply
	adc.b tmp0						; plus the column
	asl a							; logo map word + logochars
	tax
	lda.l unpackbuf,x				; logo map word
	adc.w logochars					; plus the logo tile base
	pha								; keep it
	lda.b tmp1						; row
	asl a							; times 32
	asl a
	asl a
	asl a
	asl a							; textmap row y * 32 + x + 12
	adc.b tmp0						; plus the column
	asl a							; word offset
	tax
	pla								; word back
	sta.l textmap+(12*2),x			; into the text map
	dec.b tmp0						; next column
	bpl .col
	dec.b tmp1						; next row
	bpl .row
	rtl
