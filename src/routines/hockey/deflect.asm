deflect:							;Send the puck off in a random direction after a deflection
	lda.w #$FFFF					; puck loose
	sta.w puckc
	lda.w #$1000					; random velocity +-$1000 in y and x, 0..$1000 up
	jsl.l randomas
	sta.w puckvy					; y speed
	lda.w #$1000
	jsl.l randomas
	sta.w puckvx					; x speed
	lda.w #$1000
	jsl.l randoma
	sta.w puckvz					; z speed
	jmp.w puckflip					; puckflip
