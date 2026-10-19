puckstick:							;The puck hits player a2's stick
	ldy.b a2						; player a2
	lda.w position,y				; position
	bne .0
	lda.w gmode						; game mode
	bit.w #gmhl						; gmhl: goalie ignores the puck
	beq .0
	jmp.w .rtl
.0:
	lda.w pflags,y					; player flags
	and.w #~pfdoff&$FFFF			; clear pfdoff
	sta.w pflags,y
	lda.w puckc						; puck carrier
	bpl .carried					; loose puck: no steal
	jmp.w .nosteal
.carried:							; puck carried: carrier offset
	asl a
	sta.b a0						; a0 = carrier offset
	tay
	lda.w pfteam,y					; carrier team
	beq .t1
	lda.w #$0001
.t1:								; team of the carrier
	sta.b tmp0
	ldy.b a2						; team of a2
	lda.w pfteam,y					; team of a2
	beq .t2
	lda.w #$0001
.t2:
	eor.b tmp0						; different teams?
	bne .range
	jmp.w .rtl						; same team: nothing
.range:
	lda.b d0						; distance squared
	cmp.w #$0025					; 6*6: smaller range for stealing
	lda.b d0+2
	sbc.w #$0000
	bcc .roll						; too far: nothing
	jmp.w .rtl
.roll:								;steal roll: carrier stickhand - stealer stickhand + 36
	lda.w position,y				; position of a2
	beq .steal						; goalie always steals
	ldy.b a0						; carrier
	lda.w position,y				; his position
	bne .rnd
	jmp.w .rtl
.rnd:
	lda.w stickhand,y				; stickhand of the carrier
	sta.b d0
	jsl.l makepde					; makepde
	lda.b d0
	pha								; keep it
	lda.b a0						; carrier offset
	ldy.b a2						; a2
	sta.b a2						; swap a0 and a2
	sty.b a0
	lda.w stickhand,y				; stickhand of a2
	sta.b d0
	jsl.l makepde					; makepde
	lda.b a0						; carrier offset
	ldy.b a2
	sta.b a2						; swap back
	sty.b a0
	pla								; carrier value
	sec
	sbc.b d0						; minus a2 value
	clc
	adc.w #$0024					; plus 36
	jsl.l randoma					; random number 0 to A-1
	cmp.w #$0003					; steal fails
	bcs .rtl
.steal:
	ldy.b a0						; carrier
	lda.w stickhand,y				; his stickhand
	sta.b d0
	jsl.l makepde					; makepde
	lda.b d0						; result
	clc
	adc.w #$0014					; nopuck = makepde(stickhand) + 20 for both
	ldy.b a0
	sta.w nopuck,y					; store it for the carrier
	lda.b a0						; a2
	ldy.b a2						; stealer
	sta.b a2
	sty.b a0
	lda.w stickhand,y				; stealer stickhand
	sta.b d0
	jsl.l makepde					; makepde
	lda.b d0
	clc
	adc.w #$0014					; plus 20
	ldy.b a0
	sta.w nopuck,y					; store it for the stealer
	lda.b a0
	ldy.b a2
	sta.b a2
	sty.b a0
	tya								; old carrier
	lsr a
	sta.w lastplayer				; lastplayer = the old carrier
	lda.w #sfspdir|sfssdir			; clear sfspdir/sfssdir
	trb.w sflags
.stdef:								;stick deflect sound, touch, deflect
	lda.w seed+1					; stick deflect sound (one of 4)
	and.w #$0003
	clc
	adc.w #SFXshotwiff				; stick deflect sound
	pha
	jsl.l sfx						; play it
	jsl.l a2touchpuck				; a2 touches the puck
	jmp.w deflect					; deflect
.rtl:								; return
	rtl
.nosteal:
	ldy.b a2						; a2
	lda.w position,y				; position
	bne .spd
	lda.b d0						; goalie?
	cmp.w #$0041					; goalie: loose puck within 8
	lda.b d0+2
	sbc.w #$0000
	bcs .rtl
.spd:								;catch if the puck speed^2 <= (13000+700*stickhand)^2
	lda.w puckvx					; puck x velocity
	sta.b mula
	sta.b mulb
	jsl.l muls32					; signed 32-bit multiply
	sta.b d0
	lda.b mulres+2
	sta.b d0+2
	lda.w puckvy					; puck y velocity
	sta.b mula
	sta.b mulb
	jsl.l muls32					; signed 32-bit multiply
	adc.b d0						; sum
	sta.b d0
	lda.b d0+2
	adc.b mulres+2
	sta.b d0+2
	stz.b d1						; no stickhand bonus
	lda.w sflags					; sf2shot: no stickhand bonus
	bit.w #sf2shot
	bne .nohand
	ldy.b a2						; a2
	lda.w stickhand,y				; stickhand
	sta.b mulb
	lda.w #$02BC					; * 700
	sta.b mula
	jsl.l mulu16					; mulu, mulres = mula*mulb
	sta.b d1						; bonus
.nohand:							; no stick hand: add the offset
	lda.b d1
	clc
	adc.w #$32C8					; + 13000
	sta.b mula
	sta.b mulb
	jsl.l mulu						; mulres = mula*mulb
	cmp.b d0
	lda.b mulres+2
	sbc.b d0+2
	bcs puckglue					; slower: glue to the stick
	ldy.b a2
	lda.w #$0008					; too fast: nopuck 8, deflect
	sta.w nopuck,y
	jmp.w .stdef					; deflect
