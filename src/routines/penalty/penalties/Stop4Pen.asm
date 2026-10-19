Stop4Pen:							;Stop play for a penalty: stop the clock, set the face off spot from the
									;penalty type and blow the whistle
	lda.w #$FFFF					; clock already stopped: skip the face off spot
	tsb.w gmclock					; stop the clock (all bits)
	beq .spot
	jmp.w .skipfo
.spot:								;goal: center; OOP: last touch; icing: the end of the icing team (+-600);
									;else the puck
	stz.b d0						; default spot: center
	stz.b d1
	dec.b a0						; penalty type is before a0
	dec.b a0
	lda.b (a0)						; read it
	inc.b a0
	inc.b a0
	and.w #$00FF					; type byte
	cmp.w #PenGoal					; goal: center ice
	beq .noticing
	ldy.w ltx						; last touch x
	sty.b d0
	ldy.w lty						; last touch y
	sty.b d1
	cmp.w #PenOOP					; OOP: last touch
	beq .noticing
	ldy.w puckx						; puck x
	sty.b d0
	ldy.w pucky						; puck y
	sty.b d1
	cmp.w #PenIcing					; icing: +-600 by pfgoal of the icing player
	bne .noticing
	dec.b a0						; icing player number
	lda.b (a0)
	inc.b a0
	and.w #$00FF
	asl a							; times 2
	tay
	lda.w #$0258					; spot y +600
	sta.b d1
	lda.w pfgoal,y					; his goal
	beq .noticing
	lda.w #$FDA8					; spot y -600
	sta.b d1
.noticing:
	lda.b d0						; x within +-70; y near the ends: end face off spots (+-206, x +-70)
	sta.b tmp0
	sec
	sbc.w #$0046					; limit x to +70
	bmi .neg
	bvc .x0
	bra .0
.neg:								; signed compare: overflow flag corrects the sign
	bvc .0
.x0:
	lda.w #$0046					; x limit 70
	sta.b d0
.0:									; clamp the faceoff X
	lda.b d0
	sec
	sbc.w #$FFBA					; and to -70
	beq .x1
	bmi .neg1
	bvs .x1
	bra .1
.neg1:								; signed compare: overflow flag corrects the sign
	bvs .1
.x1:
	lda.w #$FFBA					; -70
	sta.b d0
.1:
	lda.b d1						; y
	sec
	sbc.w #$00A6					; beyond the end of +166?
	bmi .neg2
	bvc .yhi
	bra .2
.neg2:								; signed compare: overflow flag corrects the sign
	bvc .2
.yhi:
	lda.w #$00CE					; end spot y 206
	sta.b d1
	lda.w #$0046					; x 70
	sta.b d0
	lda.b tmp0						; sign of the original x
	bpl .2
	lda.w #$FFBA					; x -70
	sta.b d0
.2:									; clamp the faceoff Y
	lda.b d1
	sec
	sbc.w #$FF5A					; beyond -166?
	beq .ylo
	bmi .neg3
	bvs .ylo
	bra .3
.neg3:								; signed compare: overflow flag corrects the sign
	bvs .3
.ylo:
	lda.w #$FF32					; end spot y -206
	sta.b d1
	lda.w #$0046					; x 70
	sta.b d0
	lda.b tmp0						; sign of the original x
	bpl .3
	lda.w #$FFBA					; x -70
	sta.b d0
.3:									; store the faceoff spot
	lda.b d0
	sta.w fox						; face off x
	lda.b d1
	sta.w foy						; face off y
	jsl.l limitfo					; limit the spot
.skipfo:
	lda.b vcount					; sound cut off within 60 frames: reset the queue
	sec
	sbc.w sfxmutetime
	cmp.w #$003C					; within 60 frames?
	bcc .snd
	jsl.l sndqreset					; reset the sound queue
.snd:
	lda.w #SFXwhistle				; whistle, Pencntdwn = 0, gmpen, SetPA PenWhistle
	pha								; whistle
	jsl.l sfx
	stz.w Pencntdwn					; clear the penalty countdown
	lda.w #gmpen
	tsb.w gmode						; penalty game mode
	lda.w #PenWhistle				; penalty whistle
	sta.b d0
	jmp.w SetPA						; start the penalty announcement
