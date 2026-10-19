goalieacc:							;The goalie skates in direction d0, turning one step toward it
	lda.w #SPAgready				; SPAgready (2)
	sta.b d1						; ready animation
	lda.b d0						; direction
	and.w #$000F					; 4 bits
	sta.b d0						; keep it
	cmp.w #$0008					; 8 = no direction
	bcc .d1							; 0-7: a direction
	cmp.w #$0009					; 9 = stop
	bne .cgl
	lda.w Xvel,x					; moving?
	ora.w Yvel,x					; either axis
	beq .cgl						; standing: ready stance
	jmp.w StopNA					; moving: slow down
.cgl:								;no direction: ready stance unless an animation is in progress
	lda.w pf2aip,x
	bne .rts						; animation in progress
	jmp.w SetSPA					; start the ready stance
.rts:								; return
	rtl
.d1:								;d0 = wanted direction: step facedir one eighth toward it
	sec
	sbc.w facedir,x					; difference to the facing
	sta.b d0						; d0 = difference
	beq .spa						; none: skate
	eor.w #$FFFF					; negate
	inc a
	and.w #$0004					; one step (+1/-1) toward d0
	lsr a							; +1 or -1
	dec a
	clc								; plus the facing
	adc.w facedir,x
	and.w #$0007					; 0-7
	sta.b d0						; d0 = new direction
	sta.w facedir,x					; new facing
.spa:
	lda.w #SPAgskate				; SPAgskate $3F8
	sta.b d1						; skating animation
	jsl.l SetSPA					; start it
	lda.w facedir,x
	sta.b d2						; skate that way
	jml.l playeracc					; d2 = facedir, bank $8F (d2 = direction)
