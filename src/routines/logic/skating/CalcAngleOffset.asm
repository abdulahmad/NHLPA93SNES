CalcAngleOffset:					;d4 = the cross product of the goalie vector d0 / d1 and the post vector
									;from the puck, scaled by d2
	lda.b d3						; goalie y
	sec
	sbc.w puckx						; minus puck x
	sta.b d3
	lda.b d4
	sec
	sbc.w pucky						; minus puck y
	sta.b mulb
	lda.b d0						; vector x
	sta.b mula
	jsl.l muls32					; cross product term
	sta.b d4
	lda.b mulres+2
	sta.b d4+2
	lda.b d1						; vector y
	sta.b mula
	lda.b d3
	sta.b mulb
	jsl.l muls32					; other term
	sta.b d3
	lda.b mulres+2
	sta.b d3+2
	lda.b d4						; difference
	sec
	sbc.b d3
	sta.b mulb
	lda.b d4+2
	sbc.b d3+2
	sta.b mulb+2
	lda.b d2						; scale d2
	sta.b mula
	jsl.l divs						; signed divide
	sta.b d4						; d4 = result
	rtl
