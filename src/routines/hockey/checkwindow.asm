checkwindow:						;Move the view so the screen follows the puck
	lda.w yc1						; previous view target y
	sta.b d2
	lda.w xc1						; previous view target x
	sta.b d3
	lda.w sflags					; sfslock: use xc1/yc1
	bit.w #sfslock
	bne .dd							; locked: keep the old target
	ldx.w #puckobj					; follow the puck, or its carrier with yleader
	lda.w puckc						; puck carrier
	bmi .ok							; loose puck: follow the puck
	asl a							; carrier's object offset
	tax
	lda.w pfgoal,x					; carrier goes up: yleader up to 50, else down to -50
	beq .gd
	lda.w yleader
	adc.b impactstep				; leader grows with the impact step
	sta.w yleader
	sec
	sbc.w #$0032					; up to 50
	bmi .neg
	bvc .ylmax
	bra .ok
.neg:								; signed compare: overflow flag corrects the sign
	bvc .ok
.ylmax:
	lda.w #$0032					; limit 50
	sta.w yleader
	bra .ok
.gd:
	lda.w yleader					; going down: leader shrinks
	sec
	sbc.b impactstep
	sta.w yleader
	sec
	sbc.w #$FFCE					; down to -50
	beq .ylmin
	bmi .vl
	bvs .ylmin
	bra .ok
.vl:
	bvs .ok
.ylmin:
	lda.w #$FFCE					; limit -50
	sta.w yleader
.ok:								;d2 = Ypos + Yvel/128 + yleader, d3 = Xpos
	lda.w Yvel,x					; y velocity / 128
	lsr a
	lsr a
	lsr a
	lsr a
	lsr a
	lsr a
	lsr a
	bit.w #$0100
	beq .sy
	ora.w #$FE00
.sy:
	clc
	adc.w Ypos,x					; plus the object's y
	clc
	adc.w yleader					; plus yleader
	sta.b d2						; d2 = target y
	sta.w yc1						; remember it
	lda.w Xpos,x					; object x
	sta.b d3						; d3 = target x
	sta.w xc1						; remember it
.dd:
	lda.b d2						; |target - Vpos| > 10: scroll
	sec
	sbc.w Vpos						; distance from the current view
	sta.b d0
	sec
	sbc.w #$FFF6					; more than 10 away?
	bmi .neg1
	bvs .up
	bra .1
.neg1:								; signed compare: overflow flag corrects the sign
	bvs .1
.up:
	lda.b d2
	sec
	sbc.w #$FFF6					; d1 = target - 10 (scrolling up)
	sta.b d1
	sec
	sbc.w #$FF39					; limit -199
	beq .yslimd
	bmi .neg2
	bvs .yslimd
	bra .2
.neg2:								; signed compare: overflow flag corrects the sign
	bvs .2
.yslimd:
	lda.w #$FF39					; limit -199
	sta.b d1
	bra .2
.1:
	lda.b d0
	sec
	sbc.w #$000A					; more than 10 below?
	beq .2x
	bmi .neg3
	bvc .down
	bra .2x
.neg3:								; signed compare: overflow flag corrects the sign
	bvc .2x
.down:
	lda.b d2
	sec
	sbc.w #$000A					; d1 = target + 10 (scrolling down)
	sta.b d1
	sec
	sbc.w #$0100					; limit $100
	bmi .neg4
	bvc .yslimu
	bra .2
.neg4:								; signed compare: overflow flag corrects the sign
	bvc .2
.yslimu:
	lda.w #$0100					; limit $100
	sta.b d1
.2:									;Vpos += (target - Vpos) / 8 (at least 1)
	lda.b d1						; step toward d1
	sec
	sbc.w Vpos
	beq .2x
	lsr a							; divide by 8
	lsr a
	lsr a
	bit.w #$1000
	beq .s2
	ora.w #$E000					; sign extend
.s2:
	cmp.w #$0000					; at least 1
	bne .neg5
	inc a
.neg5:
	clc
	adc.w Vpos
	sta.w Vpos						; new vertical position
.2x:
	lda.b d3						; |target - Hpos| > 40: scroll
	sec
	sbc.w Hpos						; distance from the current view
	sta.b d0
	sec
	sbc.w #$FFD8					; more than 40 away?
	bmi .neg6
	bvs .left
	bra .3
.neg6:								; signed compare: overflow flag corrects the sign
	bvs .3
.left:
	lda.b d3
	sec
	sbc.w #$FFD8					; d1 = target + 40 (scrolling left)
	sta.b d1
	sec
	sbc.w #$FFC4					; limit -60
	bmi .neg7
	bvs .xslimn
	bra .4
.neg7:								; signed compare: overflow flag corrects the sign
	bvs .4
.xslimn:
	lda.w #$FFC4					; limit -60
	sta.b d1
	bra .4
.3:
	lda.b d0
	sec
	sbc.w #$0028					; more than 40 to the right?
	beq .rtl
	bmi .neg8
	bvc .right
	bra .rtl
.neg8:								; signed compare: overflow flag corrects the sign
	bvc .rtl
.right:
	lda.b d3
	sec
	sbc.w #$0028					; d1 = target - 40 (scrolling right)
	sta.b d1
	sec
	sbc.w #$003C					; limit 60
	beq .4
	bmi .neg9
	bvc .xslim
	bra .4
.neg9:								; signed compare: overflow flag corrects the sign
	bvc .4
.xslim:
	lda.w #$003C					; limit 60
	sta.b d1
.4:									;Hpos += (target - Hpos) / 8 (at least 1)
	lda.b d1
	sec
	sbc.w Hpos						; step toward d1
	beq .rtl
	lsr a
	lsr a
	lsr a							; divide by 8
	bit.w #$1000
	beq .s4
	ora.w #$E000					; sign extend
.s4:
	cmp.w #$0000					; at least 1
	bne .h2
	inc a
.h2:
	clc
	adc.w Hpos
	sta.w Hpos						; new horizontal position
.rtl:								; return
	rtl
