skatetopuckinit:					;d0 / d1 = where the puck will be soon
	lda.w puckvx					; puckvx high byte / 2
	xba								; high byte
	lsr a							; / 2
	and.w #$007F					; 7 bits
	bit.w #$0040					; sign bit of the 7 bits
	beq .x
	ora.w #$FF80					; sign extend
.x:									; puck x plus the lead
	clc
	adc.w puckx						; plus the puck x
	sta.b d0						; d0 = predicted x
	lda.w puckvy
	xba								; high byte
	lsr a							; / 2
	and.w #$007F
	bit.w #$0040
	beq .y							; negative
	ora.w #$FF80
.y:									; puck y plus the lead
	clc
	adc.w pucky						; plus the puck y
	sta.b d1						; d1 = predicted y
	rtl
