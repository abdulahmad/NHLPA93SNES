puckgoalie:							;The puck hits goalie a2: a save or not, by his save ratings. A hard shot
									;from the blue line area may
		;   slip through; a slow loose puck is held
	lda.w gmode						; game mode
	bit.w #gmhl						; gmhl
	beq .go
	jmp.w .rtl
.go:
	stz.b d2						; region 0
	lda.w Zpos+puckobj				; puck height
	sec
	sbc.w #$0008					; minus 8
	beq .low
	bmi .neg
	bvs .low
	bra .side
.neg:								; signed compare: overflow flag corrects the sign
	bvs .side
.low:								;puck region: +2 when low
	inc.b d2
	inc.b d2
.side:
	lda.b d0						; direction from the goalie to the puck, relative to facedir
	eor.w #$FFFF					; negate
	inc a
	sta.b d0
	lda.b d1
	eor.w #$FFFF					; negate
	inc a
	sta.b d1
	jsl.l vtoa						; vector to direction
	ldy.b a2
	lda.b d0						; minus the facing
	sec
	sbc.w facedir,y
	and.w #$0007					; 0-7
	sta.b d0
	and.w #$0003					; front or back?
	sta.b d1
	bne .lr
	lda.w seed						; straight in front or behind: random side
	sta.b d0
.lr:
	lda.b d0						; side bit
	and.w #$0004
	lsr a
	lsr a
	eor.w #$0001
	clc
	adc.b d2
	asl a
	sta.b d2
	lda.w GGSleft,y					; save rating for the region: GGSleft, passacc, spodds, endurance
	sta.b d1
	lda.b d2
	beq .odds
	lda.w passacc,y					; passacc
	sta.b d1
	lda.b d2
	cmp.w #$0002
	beq .odds
	lda.w spodds,y					; spodds
	sta.b d1
	lda.b d2
	cmp.w #$0004
	beq .odds
	lda.w endurance,y				; endurance
	sta.b d1
.odds:								;d1 = save rating + 15
	lda.b d1
	clc
	adc.w #$000F					; plus 15
	sta.b d1
	lda.w attribute,y				; attribute
	bit.w #attrxflip				; x flip
	beq .noflip
	lda.b d2						; mirror the side
	eor.w #$0002
	sta.b d2
.noflip:
	lda.w puckvy					; puck y velocity
	bit.w #$8000					; absolute value
	beq .hard
	eor.w #$FFFF					; negate
	inc a
.hard:								;hard shot from the blue line area may slip through
	cmp.w #$3000					; |puckvy| >= $3000
	bcc .frame
	lda.w carriedy					; shot taken 80..169 from the goal line: 1 in (182-y) slips through
	bit.w #$8000
	beq .dist
	eor.w #$FFFF					; negate
	inc a
.dist:
	cmp.w #$0050					; within 80..169?
	bcc .frame
	cmp.w #$00AA
	bcs .frame
	eor.w #$FFFF					; negate
	inc a
	clc
	adc.w #$00B6					; 182 minus the distance
	jsl.l randoma					; random number 0 to A-1
	cmp.w #$0003					; 1 in that: slips through
	bne .frame
	jmp.w .rtl
.frame:								;goalie in the down frames and the puck on the ice: no save
	lda.w frame,y					; goalie frame
	sec
	sbc.w #SPFgdive					; goalie dive frames SPFgdive..+15
	cmp.w #$0010
	bcs .saved
	lda.w Zpos+puckobj				; puck height
	sec
	sbc.w #$0002					; minus 2
	bmi .neg1
	bvs .saved
.nosave:							; far branch to .rtl
	jmp.w .rtl
.neg1:								; signed compare: overflow flag corrects the sign
	bvs .nosave
.saved:
	jsl.l ChkShotStat				; ChkShotStat
	jsl.l a2touchpuck				; goalie touches the puck
	lda.w seed+1					; puck body sound (one of 2)
	and.w #$0001
	clc
	adc.w #SFXpuckbody				; puck body sound
	pha
	jsl.l sfx						; play it
	lda.w puckvy					; puck y velocity
	bit.w #$8000
	beq .vy
	eor.w #$FFFF					; negate
	inc a
.vy:
	cmp.w #$3000					; hard shot?
	bcc .nosong
	lda.w #SFXcrowdcheer			; crowd: home save
	pha
	ldy.b a2
	lda.w pfteam,y					; team of the goalie
	beq .song
	lda.w #SFXoooh2					; home goalie: sound
	sta.b $01,s
.song:
	jsl.l sfx						; play it
.nosong:
	lda.w puckc						; carrier
	sta.b d2
	bpl .carried					; loose puck
	jmp.w .nopc
.carried:							;carrier loses the puck
	lda.w #$FF00					; puckc high byte = $FF: loose
	tsb.w puckc
	asl.b d2						; offset
	lda.b d2
	sta.b a0						; a0 = old carrier
	tay
	lda.w #$0014					; old carrier nopuck = 20
	sta.w nopuck,y					; nopuck 20
	tya
	lsr a
	sta.w lastplayer				; lastplayer
	lda.w #sfspdir|sfssdir			; clear sfspdir/sfssdir
	trb.w sflags
.bounce:
	stz.w Zvel,x					; Zvel = 0, nopuck(a2) = 10, temp4(a2) = 4
	ldy.b a2
	lda.w #$000A					; nopuck 10 for the goalie
	sta.w nopuck,y
	lda.w #$0004
	sta.w temp4,y					; temp4 = 4
	lda.w Xpos,x					; puck x
	sec
	sbc.w Xpos,y					; minus the goalie x
	sta.b d0
	lda.w Ypos,x					; puck y
	sec
	sbc.w Ypos,y					; minus the goalie y
	sta.b d1
	bne .sx
	lda.b a2						; goalie player number
	jsl.l GetHot					; hot spot offset
.sx:
	lda.b d1
	and.w #$00FF					; low byte
	bit.w #$0080
	beq .sy
	ora.w #$FF00
.sy:
	sta.b d1						; sign extend
	lda.b d1
	beq .away						; zero: away
	inc.b d1
.away:
	ldy.b a2						; goalie
	lda.w Yvel,y					; goalie y velocity
	eor.b d1						; compared with the direction
	bmi .0
	lda.b d1
	eor.w #$FFFF					; negate
	inc a
	sta.b d1
.0:
	sep #$20						; 8-bit A
	lda.b d0						; x velocity high byte
	sta.w Xvel+1,x
	lda.b d1						; y velocity high byte
	sta.w Yvel+1,x
	rep #$20						; 16-bit A
	jmp.w puckflip					; flip the puck
.rtl:								; return
	rtl
.nopc:								;loose puck: the goalie holds it if it is slow enough
	ldy.b a2
	lda.w SPA,y						; goalie animation
	cmp.w #SPAgdive					; SPAgdive: always bounce
	beq .bounce
	lda.w #$0002					; catch speed limit = random((2+shotspd)*512) + $C00
	clc
	adc.w shotspd,y					; plus the shot speed
	xba
	and.w #$FF00
	asl a
	jsl.l randoma					; random number 0 to A-1
	adc.w #$0C00					; plus $C00
	sta.b d0						; limit
	sec
	sbc.w puckvx					; minus puck x velocity
	bmi .neg2
	bvc .c2
.b1:								; far branch to .bounce
	jmp.w .bounce
.neg2:								; signed compare: overflow flag corrects the sign
	bvc .b1
.c2:
	lda.b d0
	sec
	sbc.w puckvy					; minus puck y velocity
	bmi .neg3
	bvc .c3
.b2:								; far branch to .bounce
	jmp.w .bounce
.neg3:								; signed compare: overflow flag corrects the sign
	bvc .b2
.c3:
	lda.b d0
	eor.w #$FFFF					; negate
	inc a
	sta.b d0
	sec
	sbc.w puckvx					; minus puck x velocity
	beq .c4
	bmi .neg4
	bvs .c4
.b3:								; far branch to .bounce
	jmp.w .bounce
.neg4:								; signed compare: overflow flag corrects the sign
	bvs .b3
.c4:
	lda.b d0
	sec
	sbc.w puckvy					; minus puck y velocity
	beq .c5
	bmi .neg5
	bvs .c5
.b4:								; far branch to .bounce
	jmp.w .bounce
.neg5:								; signed compare: overflow flag corrects the sign
	bvs .b4
.c5:
	ldy.b a2						; goalie
	lda.w pflags,y					; flags
	bit.w #pf2unav					; pf2unav
	beq .hold
	jmp.w .bounce
.hold:
	stz.w Zvel,x					; Zvel = 0
	jmp.w puckglue					; puckglue: goalie holds the puck
