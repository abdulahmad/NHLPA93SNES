checkgoal:							;Collision with the goal: over the top, into the net for a goal, off a
									;post or off the side and back
	lda.w Zpos,x					; Zpos > 13 (goal height): over the goal
	sec
	sbc.w #$000D
	beq .z
	bmi .neg
	bvs .z
.ex1:								; far branch to .rtl
	jmp.w .rtl
.neg:								; signed compare: overflow flag corrects the sign
	bvs .ex1
.z:									; the puck only: players use checkgoalp
	cpx.w #puckscnum					; not the puck: checkgoalp
	beq .puck
	jmp.w checkgoalp				; else the player version
.puck:								;puck: inside |dx| <= 16+wcradiusx and |dy| <= 4+wcradiusy?
	ldy.b a2						; d2 = x - goal x
	lda.w #$0010					; half the goal width 16
	clc
	adc.w wcradiusx					; plus the radius
	sta.b d4
	lda.b d2						; x of the object
	sec
	sbc.w Xpos,y					; minus the goal x
	sta.b d2
	sec								; within the right edge?
	sbc.b d4
	beq .xl
	bmi .neg1
	bvs .xl
.ex2:								; far branch to .rtl
	jmp.w .rtl
.neg1:								; signed compare: overflow flag corrects the sign
	bvs .ex2
.xl:								; left edge, negated
	lda.b d4						; left edge
	eor.w #$FFFF					; negate
	inc a
	sta.b d4
	lda.b d2						; against the left edge
	sec
	sbc.b d4
	bmi .neg2
	bvc .yh
.ex3:								; far branch to .rtl
	jmp.w .rtl
.neg2:								; signed compare: overflow flag corrects the sign
	bvc .ex3
.yh:								; goal depth 4 plus the radius
	lda.w #$0004					; goal depth 4
	clc
	adc.w wcradiusy					; plus the radius
	sta.b d5
	lda.b d3						; y of the object
	sec
	sbc.w Ypos,y					; minus the goal y
	sta.b d3
	sec								; within the back edge?
	sbc.b d5
	beq .yl
	bmi .neg3
	bvs .yl
.ex4:								; far branch to .rtl
	jmp.w .rtl
.neg3:								; signed compare: overflow flag corrects the sign
	bvs .ex4
.yl:								; front edge, negated
	lda.b d5						; front edge
	eor.w #$FFFF					; negate
	inc a
	sta.b d5
	lda.b d3						; against the front edge
	sec
	sbc.b d5
	bmi .neg4
	bvc .inside
.ex5:								; far branch to .rtl
	jmp.w .rtl
.neg4:								; signed compare: overflow flag corrects the sign
	bvc .ex5
.inside:							;inside the goal area now
	lda.w #$FFFF					; collflag
	sta.b collflag
	lda.w OldZpos+puckscnum			; height last frame
	sec
	sbc.w #$000D					; $0D
	bmi .neg5
	bvc .over
	bra .nod
.neg5:								; signed compare: overflow flag corrects the sign
	bvc .nod
.over:								;OldZpos >= 13: came over the top
	lda.w OldZpos+puckscnum			; restore the old height
	sta.w Zpos+puckscnum
	jmp.w .deflectz					; bounce off the top
.nod:								;pfgoal of the puck = the carrier shot into his own goal
	stz.w pfgoal+puckscnum			; clear pfgoal
	lda.w puckc						; carrier: loses the puck, nopuck 8
	bmi .nocon
	asl a							; carrier player
	tay
	lda.w #$FFFF					; puck is loose
	sta.w puckc
	lda.w #$0008
	sta.w nopuck,y					; lockout 8
	lda.w pucky						; puck y
	sta.b d1
	lda.w pfgoal,y					; carrier's end
	bne .an
	lda.b d1
	eor.w #$FFFF					; negate
	inc a
	sta.b d1
.an:								; puck on the right side of the goal line?
	lda.b d1
	bpl .nocon						; puck on the wrong side?
	lda.w #$0001
	sta.w pfgoal+puckscnum			; own goal by the carrier
.nocon:								;d0 = -256 (top entry: +256)
	lda.w #$FF00					; d1 = (Ypos - OldYpos) >> 8
	sta.b d0
	lda.w Yfrac,x					; y movement
	sec
	sbc.w OldYfrac,x
	sta.b d1
	lda.w Ypos,x					; new y
	sbc.w OldYpos,x					; minus old y
	sta.b d1+2
	lda.b d1+1						; high byte
	sta.b d1						; d1 = y movement
	bne .dy							; zero: side entry
	jmp.w .sideentry
.dy:								; direction of y: zero is a side entry
	bmi .0							; which way
	lda.b d0
	eor.w #$FFFF					; negate
	inc a
	sta.b d0
	lda.b d5						; and the depth
	eor.w #$FFFF					; negate
	inc a
	sta.b d5
.0:									;d5 = dy at entry; d2 -= dx*dy/vy: x where the puck crossed the goal line
	lda.b d5						; crossing depth
	clc
	adc.b d3
	sta.b d5
	sta.b mulb						; multiplier
	lda.w Xfrac,x					; d3 = (Xpos - OldXpos) >> 8; d5*d3
	sec
	sbc.w OldXfrac,x
	sta.b d3
	lda.w Xpos,x
	sbc.w OldXpos,x
	sta.b d3+2
	lda.b d3+1
	sta.b d3
	sta.b mula						; x movement high byte
	jsl.l muls32					; signed 32-bit multiply
	lda.b d1						; |d5*d3| < |d1|? else side entry
	bit.w #$8000
	beq .m1
	eor.w #$FFFF					; negate
	inc a
.m1:								; take the high word of the product
	sta.b mula
	lda.b mulres+2					; high word
	bit.w #$8000
	beq .m2
	eor.w #$FFFF					; negate
	inc a
.m2:								; compare with the y movement: side entry if smaller
	cmp.b mula						; compare with the y movement
	bcc .dv
	jmp.w .sideentry				; side entry
.dv:								; divide by the Y distance
	lda.b d1
	sta.b mula
	jsl.l divs						; d5 = d5*d3 / d1
	sta.b d5						; x where the puck crossed
	lda.b d2						; d2 = crossing x
	sec
	sbc.b d5						; minus
	sta.b d2
	sec
	sbc.b d4						; against the edge
	bmi .neg6
	bvc .xl2
.se1:								; far branch to .sideentry
	jmp.w .sideentry
.neg6:								; signed compare: overflow flag corrects the sign
	bvc .se1
.xl2:								; negate X for the other side
	lda.b d4
	eor.w #$FFFF					; negate
	inc a
	sta.b d4
	lda.b d2
	sec
	sbc.b d4
	beq .mouth						; between the posts?
	bmi .neg7
	bvs .mouth
.se2:								; far branch to .sideentry
	jmp.w .sideentry
.neg7:								; signed compare: overflow flag corrects the sign
	bvs .se2
.mouth:								;crossed between the posts
	stz.b d1						; crossed between the posts
	lda.w pucky						; puck on the back side: wallcoll
	eor.b d0
	bpl .pf
	jmp.w wallcoll					; bounce off the back
.pf:								; mirror (negate)
	lda.b d0						; mirror
	eor.w #$FFFF					; negate
	inc a
	sta.b d0
	lda.w pfgoal+puckscnum			; own goal by the carrier: wallcoll
	beq .z13
	jmp.w wallcoll					; bounce off
.z13:								;at the crossbar height: off the post
	lda.w Zpos+puckscnum				; puck height
	cmp.w #$000D
	beq .deflectsf					; crossbar height
	lda.b d4						; mouth = half width - 5
	sec
	sbc.w #$0005
	sta.b d4
	lda.b d2
	sec
	sbc.b d4
	beq .ml
	bmi .neg8
	bvs .ml
	bra .deflectsf					; off the post
.neg8:								; signed compare: overflow flag corrects the sign
	bvs .deflectsf
.ml:								; negate X for the other post
	lda.b d4
	eor.w #$FFFF					; negate
	inc a
	sta.b d4
	lda.b d2
	sec
	sbc.b d4
	bmi .neg9
	bvs .deflectsf
.goal:								; far branch to Goal
	jmp.w Goal
.neg9:								; signed compare: overflow flag corrects the sign
	bvs .goal
.deflectsf:							;off the post
	jsl.l ChkShotStat				; off the post: sfx and crowd +300
	lda.w #SFXpuckpost				; post sound
	pha
	jsl.l sfx						; play it
	lda.b Crowdlevel
	clc								; crowd level plus 300
	adc.w #$012C
	sta.b Crowdlevel
	lda.w #$1000					; random Yvel away from the goal, Xvel/Zvel +-$1000
	jsl.l randomd0A					; random number 0 to A-1
	sta.b d0
	lda.w pucky
	bmi .df0
	lda.b d0
	eor.w #$FFFF					; negate
	inc a
	sta.b d0
.df0:								; deflect: give the puck a new Y velocity
	lda.b d0
	sta.w puckvy					; puck y velocity
	lda.w #$2000					; random x velocity
	jsl.l randomd0A					; random number 0 to A-1
	sec
	sbc.w #$1000
	sta.w puckvx					; puck x velocity
	lda.w #$2000					; random z velocity
	jsl.l randomd0A					; random number 0 to A-1
	sec
	sbc.w #$1000
	sta.w puckvz					; puck z velocity
	jmp.w puckflip					; flip the puck
.deflectz:							;Zvel = |Zvel|
	lda.w puckvz					; puck z velocity
	bit.w #$8000
	beq .dz
	eor.w #$FFFF					; negate
	inc a
.dz:								; store puckvz
	sta.w puckvz					; store it
.rtl:								; return
	rtl
.sideentry:							;off the side: wallcoll with normal (0, +-256)
	stz.b d0						; normal x 0
	lda.w #$0100					; d1 = +-256 by the x movement
	sta.b d1
	lda.w puckx						; puck x
	sec
	sbc.w OldXpos+puckscnum			; minus the old x
	sta.b d2
	bmi .wc
	lda.w #$FF00					; other side: -256
	sta.b d1
.wc:								; bounce off the wall
	jmp.w wallcoll					; bounce
