eraser:								;Fill a d0 by d1 rectangle of the text map at printx / printy with tile d2
	phx								; keep X
	lda.b d2						; tile
	clc
	adc.w printfontset				; plus the font set
	sta.b d2
	stz.b d1+2						; row counter 0
.row:
	lda.w printy					; print y
	clc
	adc.b d1+2						; plus the row
	asl a							; times 32
	asl a
	asl a
	asl a
	asl a
	adc.w printx					; plus print x
	asl a							; word offset
	adc.b printm					; plus the map base
	tax								; X = map offset
	ldy.b d0						; columns
	lda.b d2						; tile
.col:
	sta.l textmap,x					; fill a word
	inx
	inx
	dey								; next column
	bne .col
	inc.b d1+2						; next row
	lda.b d1+2
	cmp.b d1						; all rows done?
	bne .row
	plx								; restore X
	lda.w printy					; print y
	asl a
	asl a
	asl a
	asl a
	asl a
	adc.w printx					; plus print x
	cmp.b textdirtylo				; below the dirty start
	bcs .hi
	sta.b textdirtylo				; new dirty start
.hi:
	lda.w printy					; print y
	clc
	adc.b d1						; plus the height
	and.w #$001F					; wrap at 32
	sta.w printy					; new print y
	dec a							; last row
	and.w #$001F
	asl a
	asl a
	asl a
	asl a
	asl a
	adc.w printx					; plus print x
	adc.b d0						; plus the width
	dec a							; last word
	cmp.b textdirtyhi				; above the dirty end
	bcc .rtl
	sta.b textdirtyhi				; new dirty end
.rtl:
	rtl
