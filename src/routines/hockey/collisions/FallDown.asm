FallDown:							;Player a2 falls (or stumbles) from a hit by X: check stats, the fall
									;animation, maybe an injury with a penalty,
		;   and the crowd
	ldy.b a2						; players only, not fighting
	cpy.w #$0018
	bcc .f1
	jmp.w .rtl
.f1:								; is the other player fighting?
	lda.w pf2fight,y				; fighting?
	beq .spa
	jmp.w .rtl
.spa:								;already in one of the fall anims?
	lda.w SPA,y						; animation of the falling player
	cmp.w #SPAinjury1
	bne .s2
	jmp.w .rtl
.s2:								; already stumbling: nothing to do
	cmp.w #SPAstumble
	bne .s3
	jmp.w .rtl
.s3:								; already falling forward: nothing to do
	cmp.w #SPAfallfwd
	bne .s4
	jmp.w .rtl
.s4:								; already falling back: nothing to do
	cmp.w #SPAfallback
	bne .s5
	jmp.w .rtl
.s5:								; already flipping: nothing to do
	cmp.w #SPAflip
	bne .s6
	jmp.w .rtl
.s6:								;stumble when stickhand (byte $71) >= $C, nopuckb is 0 and impact <
									;$10-$1F
	lda.w #SPAstumble				; stumble animation
	sta.b d1
	lda.w stickhand,y				; stickhand rating
	cmp.w #$000C
	bcc .fall
	lda.w nopuckb,y					; recent stumble?
	bne .fall
	lda.w seed						; random
	and.w #$000F
	ora.w #$0010					; $10-$1F
	sta.b d0
	sec
	sbc.w impact,y					; minus the impact
	beq .fall
	bmi .neg
	bvc .stumble
	bra .fall
.neg:								; signed compare: overflow flag corrects the sign
	bvc .fall
.stumble:							;no second stumble for $3C
	lda.w #$003C
	sta.w nopuckb,y					; no second stumble for 60 frames
	jmp.w .set
.fall:								;no check stats for a goalie hitter
	lda.w position,x				; goalie hitter?
	beq .nostat
	stz.b a0						; team checks, player checks, ChkCnt (+3 when fighting is 0)
	lda.w pfteam,x					; team of the hitter
	beq .tm
	lda.w #$0002
	sta.b a0
.tm:								; count the team's checks
	ldy.b a0
	lda.w tmchecks,y				; team checks
	inc a
	sta.w tmchecks,y				; count it
	inc.w ChkCnt					; total check count
	lda.w pnum,x					; hitter's player number
	sta.b d0
	lda.w pfteam,x					; team offset
	beq .pl
	lda.w #$001A
.pl:								; index the player stats
	clc
	adc.b d0
	tay
	sep #$20						; 8-bit A
	lda.w pchecks,y					; player checks
	inc a
	sta.w pchecks,y					; count it
	rep #$20						; 16-bit A
	lda.w fighting,x				; hitter's fighting rating
	bne .nostat
	inc.w ChkCnt
	inc.w ChkCnt
.nostat:							; nopuck = 120
	ldy.b a2						; nopuck 120 for a2
	lda.w #$0078					; puck lockout 120
	sta.w nopuck,y
	lda.w Xpos,x					; direction from a2 to the hitter
	sec
	sbc.w Xpos,y					; minus x of a2
	sta.b d0
	lda.w Ypos,x					; y of the hitter
	sec
	sbc.w Ypos,y					; minus y of a2
	sta.b d1
	jsl.l vtoa						; vector to direction
	lda.w #SPAfallback				; fall back
	sta.b d1
	ldy.b a2						; hit from the front: fall back
	lda.b d0						; direction to the hitter
	sec
	sbc.w facedir,y
	inc a
	and.w #$0007
	cmp.w #$0003					; within 2 of the facing?
	bcc .set
	lda.w #SPAfallfwd				; else fall forward
	sta.b d1
	lda.w facedir,y					; facedir 0 or 4 and hitter checking >= 10: third fall
	and.w #$0003
	bne .set
	lda.w checking,x				; hitter's checking rating
	sec
	sbc.w #$000A					; minus 10
	bmi .neg1
	bvc .f3
	bra .set
.neg1:								; signed compare: overflow flag corrects the sign
	bvc .set
.f3:								; players only: the flip fall
	cpx.w #$0018					; players only
	bcs .set
	lda.w #SPAflip					; flip
	sta.b d1
.set:								;SetSPA d1 for a2
	ldx.b a2						; a2
	ldy.b a3
	stx.b a3
	sty.b a2
	lda.w #$0001					; pfalock
	sta.w pfalock,x
	jsl.l SetSPA					; start animation d1
	ldx.b a2
	ldy.b a3
	stx.b a3
	sty.b a2
	lda.b crowdlevel				; crowd +300
	clc
	adc.w #$012C					; plus 300
	sta.b crowdlevel
	lda.w puckc						; a2 did not have the puck: check sound only
	sta.b d0
	bpl .pc							; a2 had the puck?
	jmp.w newcheck
.pc:								; find the puck carrier
	tya
	lsr a
	cmp.b d0
	beq .drop
	jmp.w newcheck
.drop:								;a2 had the puck: lose it, maybe an injury
	lda.w #$FFFF					; puck is loose
	sta.w puckc
	lda.w gmode						;injury: no highlight, fall back, facedir 0/4, no penalty, random(160) <=
									;impact, clock running
	bit.w #gmhl						; highlight?
	bne .snd
	lda.w SPA,y						; animation
	cmp.w #SPAfallback
	bne .snd
	lda.w facedir,y					; facing
	and.w #$0003
	bne .snd
	lda.w pflags,y					; already penalised?
	bit.w #pf2pen
	bne .snd
	lda.w #$00A0					; random 0-159
	jsl.l randoma					; random number 0 to A-1
	ldy.b a2
	sec
	sbc.w impact,y					; minus the impact
	beq .inj
	bmi .neg2
	bvs .inj
	bra .snd
.neg2:								; signed compare: overflow flag corrects the sign
	bvs .snd
.inj:								; clock stopped?
	lda.w gmclock					; clock stopped?
	bne .snd
	ldx.b a2
	ldy.b a3
	stx.b a3
	sty.b a2
	lda.w #SPAinjury1				; injury animation
	sta.b d1
	jsl.l SetSPA					; start animation d1
	ldx.b a2
	ldy.b a3
	stx.b a3
	sty.b a2
	jsl.l setInjuryType				; setInjuryType
	lda.w #$0004					; injury countdown
	sta.w InjCntDown
	lda.w #PenNoText				;PenNoText if the hitter is a goalie or penalties are off, else
	;PenRoughing2
									;and Stop4Pen
	sta.b d0
	lda.w position,x				; hitter a goalie?
	bne .g
	jmp.w AddPenalty2
.g:									; penalties off?
	lda.w OptPen					; penalties off?
	bne .rough
	jmp.w AddPenalty2
.rough:								; roughing penalty
	lda.w #PenRoughing2				; roughing penalty
	sta.b d0
	jsl.l AddPenalty2
	jmp.w Stop4Pen					; stop play
.snd:								; crowd boos a home player's fall, cheers the other
	ldy.b a2						; home player fell: boo, else cheer
	lda.w #SFXcrowdcheer			; cheer
	pha
	lda.w pfteam,y
	bne .3
	lda.w #SFXcrowdboo				; boo for the home team
	sta.b $01,s
.3:									; play the crowd sound
	jsl.l sfx						; play it
.rtl:								; return
	rtl
