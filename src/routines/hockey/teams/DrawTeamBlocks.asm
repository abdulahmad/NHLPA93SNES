DrawTeamBlocks:						;Draw team d1's name block at printx / printy
	lda.b a2						; keep a2
	pha
	phx								; keep X
	lda.b d1						; 36 bytes per team
	sta.b mula
	lda.w #36
	sta.b mulb
	jsl.l mulu16					; A = mula * mulb
	tay								; Y = offset of the team block
	lda.w #Teamblocksmap			; team block map
	sta.b a2
	lda.w #Teamblocksmap>>16
	sta.b a2+2
	lda.w printy					; print y
	asl a							; times 32
	asl a
	asl a
	asl a
	asl a
	adc.w printx					; plus print x
	asl a							; word offset
	adc.b printm					; plus the map base
	tax								; X = text map offset
	lda.w #9						; 9 tiles per row
	sta.b tmp0
	sta.b tmp1
.row1:								; first row of the team block
	lda.b [a2],y					; map tile
	clc
	adc.w scorechars				; plus the score font offset
	adc.w printfontset				; plus the font set
	ora.w printa					; plus the attributes
	sta.l textmap,x					; first row
	iny								; next tile
	iny
	inx								; next text word
	inx
	dec.b tmp0						; row done?
	bne .row1
.row2:								; second row of the team block
	lda.b [a2],y					; map tile
	clc
	adc.w scorechars
	adc.w printfontset
	ora.w printa
	sta.l textmap+$2E,x				; second row: one text row down
	iny
	iny
	inx
	inx
	dec.b tmp1						; row done?
	bne .row2
	plx								; restore X
	pla								; restore a2
	sta.b a2
	rtl
