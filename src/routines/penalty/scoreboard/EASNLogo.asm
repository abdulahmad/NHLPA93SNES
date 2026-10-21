EASNLogo:							;Draw the EASN logo on the rink unless a power play is on
	lda.w sflags					; flags
	bit.w #sf2pwrplay
	bne .rtl						; power play: no logo
	jsl.l printz					; position
	%StringCp(CC_Font1Pri,$01,$19)
	stz.b tmp0						; source index
	stz.b tmp1						; text index
	lda.w #$0002					; 2 rows
	sta.b tmp2
.row:								; 8 columns
	lda.w #$0007					; 8 columns
	sta.b tmp2+2
.col:								; logo tile
	ldx.b tmp0						; source
	lda.l EASNLogoMap,x				; logo tile
	clc
	adc.w unusedchars				; plus the base
	adc.w charofs					; plus the character offset
	ldx.b tmp1
	ora.w #$2000					; palette
	sta.l textmap+(25*$40)+(1*2),x	; into the text map
	inc.b tmp0						; next source
	inc.b tmp0
	inc.b tmp1						; next text
	inc.b tmp1
	dec.b tmp2+2					; next column
	bne .col
	lda.b tmp1						; next row
	clc
	adc.w #$0032					; plus a row
	sta.b tmp1
	dec.b tmp2						; next row
	bne .row
	lda.w #$0321					; dirty range of the rink map rows
	cmp.b textdirtylo				; compare
	bcs .hi							; already lower
	sta.b textdirtylo				; new low
.hi:								; already higher: leave
	lda.w #$0347
	cmp.b textdirtyhi				; compare
	bcc .rtl						; already higher
	sta.b textdirtyhi				; new high
.rtl:								; return
	rtl
