updateplayers:						;Animation, speed, position, input and assignment for every object
	ldx.w #$0016					; 12 players
.spd:								;pspeed = max($1000, (|Xvel|+|Yvel|)*5/4) for the 12 players
	lda.w Xvel,x
	bit.w #$8000
	beq .vx
	eor.w #$FFFF					; negate
	inc a
.vx:								; |Xvel| in tmp0
	sta.b tmp0
	lda.w Yvel,x
	bit.w #$8000
	beq .vy
	eor.w #$FFFF					; negate
	inc a
.vy:								; speed = |Xvel|+|Yvel|
	clc
	adc.b tmp0
	sta.b tmp0
	lsr a
	lsr a
	adc.b tmp0
	cmp.w #$1000
	bcs .setspd
	lda.w #$1000
.setspd:							; store the speed limit for the object
	sta.w pspeed,x
	dex
	dex
	bpl .spd
	lda.w sfhormode					; vertical rink: PadControlBits |= $F
	bne .scload
	lda.w #$000F
	tsb.w PadControlBits
.scload:							; start the per-object loop with the first object
	ldx.w #$0000
	stx.b a3
.top:								;each object: old position = position
	lda.w Xpos,x
	sta.w OldXpos,x
	lda.w Xfrac,x
	sta.w OldXfrac,x
	lda.w Ypos,x
	sta.w OldYpos,x
	lda.w Yfrac,x
	sta.w OldYfrac,x
	lda.w Zpos,x
	sta.w OldZpos,x
	lda.w Zfrac,x
	sta.w OldZfrac,x
	lda.w position,x				; not on the ice
	bpl .onice
	jmp.w .nf1
.onice:
	jsl.l updateanim				; updateanim
	lda.w nopuck,x					; nopuck, nopuckb count down
	sec
	sbc.b d7
	bpl .np
	lda.w #$0000
.np:								; store the nopuck countdown
	sta.w nopuck,x
	lda.w nopuckb,x
	sec
	sbc.b d7
	bpl .np2
	lda.w #$0000
.np2:								; store the second nopuck countdown
	sta.w nopuckb,x
	lda.w sflags3					; sflags3 bit 5: count frames on ice (loadTeamStruct)
	bit.w #sf3icetime
	beq .vel
	lda.w pnum,x
	and.w #$00FF
	bit.w #$0080
	beq .pn
	ora.w #$FF00
.pn:								; sign-extend the player number
	sta.b d0
	cmp.w #$0000
	bmi .vel
	asl.b d0
	jsl.l loadTeamStruct			; a2 = team of X, a1 = the other
.vel:								; apply velocity to position
	lda.w SPA,x
	cmp.w #SPAinjury1				; SPAinjury1: no movement
	bne .slow
	jmp.w .done
.slow:
	lda.w Zpos,x					; on the ice: decelerate
	bne .x2
	ldx.b d7
.hang:								;d7 >= 10: hang
	cpx.w #$000A
	bcs .hang
	lda.l .decel-1,x				; per-frame factor
	and.w #$00FF
	sta.b d2
	lda.l .decel2-1,x
	sta.b d2+2
	ldx.b a3
	lda.w pflags,x
	bit.w #pfdoff					; pfdoff: less deceleration
	beq .off
	lda.b d2+2
	and.w #$00FF
	sta.b d2
.off:								; apply Xvel
	lda.w Xvel,x
	sta.b mula
	lda.b d2
	sta.b mulb
	jsl.l muls32					; signed 32-bit multiply
	lda.b mulres+1					; velocity = velocity * factor / 256
	sta.w Xvel,x
	lda.w Yvel,x
	sta.b mula
	lda.b d2
	sta.b mulb
	jsl.l muls32					; signed 32-bit multiply
	lda.b mulres+1
	sta.w Yvel,x
.x2:								;Xpos += Xvel*velstep (/4 in horizontal mode except in the penalty box)
	lda.w Xvel,x
	beq .y2
	sta.b mula
	lda.b velstep
	sta.b mulb
	lda.w sfhormode
	beq .x3
	txa
	asl a
	asl a
	adc.w assnum,x
	tay
	lda.w asslist,y
	and.w #$00FF
	cmp.w #apenalty					; apenalty: full speed
	beq .x3
	lsr.b mulb
	lsr.b mulb
.x3:
	jsl.l muls32					; signed 32-bit multiply
	adc.w Xfrac,x
	sta.w Xfrac,x
	lda.w Xpos,x
	adc.b mulres+2
	sta.w Xpos,x
.y2:								; apply Yvel
	lda.w Yvel,x
	beq .z
	sta.b mula
	lda.b velstep
	sta.b mulb
	lda.w sfhormode
	beq .y3
	txa
	asl a
	asl a
	adc.w assnum,x
	tay
	lda.w asslist,y
	and.w #$00FF
	cmp.w #apenalty
	beq .y3
	lsr.b mulb
	lsr.b mulb
.y3:
	jsl.l muls32					; signed 32-bit multiply
	adc.w Yfrac,x
	sta.w Yfrac,x
	lda.w Ypos,x
	adc.b mulres+2
	sta.w Ypos,x
.z:									;height: gravity and the bounce off the ice
	lda.w Zpos,x
	bmi .done
	bne .z1
	lda.w Zvel,x
	beq .done
.z1:								; apply gravity to Zvel
	lda.b velstep
	sta.b mula
	lda.w Zvel,x					; Zvel -= gravstep
	sec
	sbc.b gravstep
	sta.w Zvel,x
	sta.b mulb
	jsl.l muls32					; signed 32-bit multiply
	adc.w Zfrac,x
	sta.w Zfrac,x
	lda.w Zpos,x
	adc.b mulres+2
	sta.w Zpos,x
	bpl .done
	stz.w Zpos,x					; bounce off the ice: Zvel = -Zvel/2
	stz.w Zfrac,x
	lda.w Zvel,x
	eor.w #$FFFF					; negate
	inc a
	lsr a
	sta.w Zvel,x
	sec
	sbc.w #$0200					; bounce sound when Zvel >= $200
	bmi .neg
	bvc .bsnd
	bra .done
.neg:								; signed compare: overflow flag corrects the sign
	bvc .done
.bsnd:								; random sound for a wiffed shot
	lda.w seed
	and.w #$0003
	clc
	adc.w #SFXshotwiff
	pha
	jsl.l sfx
.done:								; done moving: set the controller for this object
	txa
	lsr a
	sta.b d6
	cmp.w puckc						; puck carrier (not fighting, vertical): setpads
	bne .tp
	lda.w pf2fight,x
	bne .tp
	lda.w sfhormode
	bne .tp
	lda.w #-2						; d4 = -2: pad index of the puck carrier
	sta.b d4
	jsl.l setpads
.tp:								; which pad controls this player?
	lda.b d6
	cmp.w c1playernum				; controller 1 player: doinput
	bne .t0
	jsl.l ReadJoy1					; read pad 1
	stz.b d4
	jsl.l doinput
	bra .t1
.decel:								;deceleration factor /256 per d7 (1-10): normal
	db $F7,$F5,$F2,$EF,$EC,$E9,$E6,$E3,$E1,$DE
.decel2:							;with pfdoff
	db $FF,$FF,$FE,$FE,$FE,$FD,$FD,$FD,$FC,$FC
.t0:								; controller 2 player?
	cmp.w c2playernum
	bne .t1
	jsl.l ReadJoy2					; read pad 2
	lda.w #$0002
	sta.b d4
	jsl.l doinput
.t1:								;call the assignment through asstab and jmlvector
	lda.w pfalock,x
	bne .cc
	txa
	asl a
	asl a
	adc.w assnum,x
	tay
	lda.w asslist,y					; current assignment
	and.w #$00FF
.hang2:
	cmp.w #$001D					; bad assignment: hang
	bcs .hang2
	asl a
	asl a
	tax
	lda.l asstab,x					; asstab entry into jmlvector
	sta.w jmlvector+1
	lda.l asstab+1,x
	sta.w jmlvector+2
	ldx.b a3
	jsl.l loadTeamStruct			; loadTeamStruct, then the assignment
	jsl.l jmlvector
.cc:								; wall collision values for this object
	lda.w Ypos,x
	sta.b d3
	stz.w Wallcos,x					; Wallcos = Wallsin = 0
	stz.w Wallsin,x
	lda.w Xpos,x
	sta.b d2
	cmp.w OldXpos,x
	bne .moved
	lda.b d3
	cmp.w OldYpos,x
	bne .moved
	jmp.w .nf
.moved:								;moved at least 1 pixel: checkcoll
	jsl.l checkcoll
	cpx.w #$0018					; only players
	bcs .nf
	lda.w position,x
	beq .nf
	lda.w pflags,x
	and.w #pf2npc					; pf2npc or horizontal: no goal check
	ora.w sfhormode
	bne .nf
	lda.w Xpos,x
	bit.w #$8000
	beq .ax
	eor.w #$FFFF					; negate
	inc a
.ax:
	cmp.w #$0019					; |x| < 25
	bcs .nf
	lda.w Ypos,x
	bit.w #$8000
	beq .ay
	eor.w #$FFFF					; negate
	inc a
.ay:								; goal line crossing in Y
	sec
	sbc.w #$010D					; crossing y = +-269 (the goal line)?
	sta.b tmp0
	lda.w OldYpos,x
	bit.w #$8000
	beq .oy
	eor.w #$FFFF					; negate
	inc a
.oy:								; compare with last frame's side
	sec
	sbc.w #$010D
	eor.b tmp0
	bmi .back
	lda.w Ypos,x
	bit.w #$8000
	beq .gl
	eor.w #$FFFF					; negate
	inc a
.gl:
	cmp.w #$0103					; 259 <= |y| < 279
	bcc .nf
	cmp.w #$0117
	bcs .nf
.back:								;do not skate into the goal: old position
	lda.w OldXpos,x
	sta.w Xpos,x
	lda.w OldYpos,x
	sta.w Ypos,x
.nf:								;impact decays; limpact = impact
	lda.w impact,x
	sec
	sbc.b impactstep
	bpl .nf1
	lda.w #$0000
.nf1:								; clear the impact values
	sta.w impact,x
	sta.w limpact,x
	lda.w frame,x					;injury frames: SPFfinjury inclusive, SPFPen
	;exclusive, and x kept within +-$60
	cmp.w #SPFfinjury
	bcc .next
	cmp.w #SPFPen
	bcs .next
	lda.w Xpos,x
	sec
	sbc.w #$FFA0
	beq .cl1
	bmi .neg1
	bvs .cl1
	bra .cx
.neg1:								; signed compare: overflow flag corrects the sign
	bvs .cx
.cl1:								; clamp injured player X at -$60
	lda.w #$FFA0
	sta.w Xpos,x
.cx:								; X limit check
	lda.w Xpos,x
	sec
	sbc.w #$0060
	bmi .neg2
	bvc .cl2
	bra .next
.neg2:								; signed compare: overflow flag corrects the sign
	bvc .next
.cl2:								; clamp X to $60
	lda.w #$0060
	sta.w Xpos,x
.next:								; next object
	inx
	inx
	stx.b a3
	cpx.w #$0020					; all 16 objects
	beq .lim
	jmp.w .top
.lim:								;players faster than pspeed are slowed to it
	ldx.w #$0016
.lim1:								; speed limit loop
	lda.w Xvel,x
	bit.w #$8000
	beq .lvx
	eor.w #$FFFF					; negate
	inc a
.lvx:								; |Yvel| next
	sta.b tmp0
	lda.w Yvel,x
	bit.w #$8000
	beq .lvy
	eor.w #$FFFF					; negate
	inc a
.lvy:								; add |Xvel| and |Yvel|
	clc
	adc.b tmp0
	cmp.w pspeed,x
	bcc .lnext
	sta.b tmp0
	lda.w Xvel,x
	sta.b mula
	lda.w pspeed,x
	sta.b mulb
	jsl.l muls32					; signed 32-bit multiply
	lda.b tmp0
	sta.b mula
	jsl.l divs						; signed divide
	sta.w Xvel,x
	lda.w Yvel,x
	sta.b mula
	lda.w pspeed,x
	sta.b mulb
	jsl.l muls32					; signed 32-bit multiply
	lda.b tmp0
	sta.b mula
	jsl.l divs						; signed divide
	sta.w Yvel,x
.lnext:								; next object
	dex
	dex
	bpl .lim1
	lda.w Zpos+puckobj				; puck below 24: keep it inside the boards
	cmp.w #$0018
	bcs .py
	lda.w puckx
	sec
	sbc.w #$FF78					; x >= -$88
	bmi .neg3
	bvs .px1
	bra .px2
.neg3:								; signed compare: overflow flag corrects the sign
	bvs .px2
.px1:								; clamp puck X to -sideline
	lda.w #$FF78
	sta.w puckx
.px2:								; puck X upper limit
	lda.w puckx
	sec
	sbc.w #sideline					; x <= $88
	beq .py
	bmi .neg4
	bvc .px3
	bra .py
.neg4:								; signed compare: overflow flag corrects the sign
	bvc .py
.px3:								; clamp puck X to sideline
	lda.w #sideline
	sta.w puckx
.py:								;puck on the ice within |y| < 318: keep it inside the boards
	lda.w Zpos+puckobj
	bne .cy
	lda.w pucky
	bit.w #$8000
	beq .py1
	eor.w #$FFFF					; negate
	inc a
.py1:								; puck Y lower limit
	cmp.w #$013E
	bcs .cy
	lda.w pucky
	sec
	sbc.w #$FEDB					; y >= -$125
	bmi .neg5
	bvs .py2
	bra .py3
.neg5:								; signed compare: overflow flag corrects the sign
	bvs .py3
.py2:								; clamp puck Y to the lower limit
	lda.w #$FEDB
	sta.w pucky
.py3:								; puck Y upper limit
	lda.w pucky
	sec
	sbc.w #$012A					; y <= $12A
	beq .cy
	bmi .neg6
	bvc .py4
	bra .cy
.neg6:								; signed compare: overflow flag corrects the sign
	bvc .cy
.py4:								; clamp puck Y to the upper limit
	lda.w #$012A
	sta.w pucky
.cy:								;carried: carriedy = pucky
	lda.w puckc
	bmi .rtl
	lda.w pucky
	sta.w carriedy
.rtl:								; return
	rtl
