PuckIChk:							;Watch for icing: the loose puck crossing the far goal line
	lda.w iflags					; icing flags
	bit.w #ifok						; ifok and not ifcgl, puck loose
	beq .rtl						; not armed
	bit.w #ifcgl
	bne .rtl						; already called
	lda.w puckc						; puck carrier
	bpl .rtl						; a carrier: no icing
	lda.w #Blueline+goalline		; Blueline+goalline
	sta.b d0						; d0 = far goal line
	lda.w iflags
	bit.w #ifdir					; direction
	bne .0
	lda.w #-(Blueline+goalline)		; goal line
	sec
	sbc.w pucky						; minus puck y
	beq .rtl						; exactly on it
	bmi .neg
	bvs .rtl						; not past
	bra .set						; past
.neg:								; signed compare: overflow flag corrects the sign
	bvs .set
.rtl:								; return
	rtl
.0:									; ifdir set: compare against the other goal line
	lda.w #Blueline+goalline		; other end
	sec
	sbc.w pucky						; minus puck y
	beq .set
	bmi .neg1
	bvs .set
	bra .rtl
.neg1:								; signed compare: overflow flag corrects the sign
	bvs .rtl
.set:								; ifcgl: icing called
	lda.w #ifcgl					; ifcgl
	tsb.w iflags					; icing called
	rtl
