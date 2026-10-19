Findhittype:						;Swing type of player X for direction d0: forehand or backhand
	lda.b d0						; direction
	eor.w #$FFFF					; negate it
	inc a
	clc
	adc.w facedir,x					; plus the facing
	and.w #$0007					; 0-7
	sta.b d0
	lda.w attribute,x				; player attributes
	bit.w #attrxflip				; x flip attribute
	beq .noattribute
	phx								; keep X
	ldx.b d0						; direction as index
	lda.l .xflip,x					; x flip: backhand for d0 4-7
	plx								; restore X
	and.w #$00FF					; byte
	rtl
.noattribute:						; backhand for d0 1-4
	phx								; keep X
	ldx.b d0						; direction as index
	lda.l .noflip,x					; backhand for d0 1-4
	plx								; restore X
	and.w #$00FF					; byte
	rtl
.xflip:								;x flip: 1 = backhand for d0 4-7 (%11110000); its last 5 bytes start
									;.noflip
	db $00,$00,$00
.noflip:							;1 = backhand for d0 1-4
	db $00,$01,$01,$01,$01,$00,$00,$00
