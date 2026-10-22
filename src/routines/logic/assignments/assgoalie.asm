assgoalie:							;Assignment: the goalie. Back to the crease, hold or pass the puck (a
									;penalty if he holds it too long),
									;follow and lead the puck, make saves, hug the post and rush a loose puck
	lda.w pfalock,x					; anim locked: nothing
	beq .go
	jmp.w .rtl
.go:								; check for bench change, then handle a new assignment
	jsl.l check4bench				; bench change check
	lda.w pflags,x					; new assignment: temp1/temp2 = 0, temp2b = 8, temp4 = -1
	bit.w #pfna
	beq .nna
	and.w #~pfna&$FFFF
	sta.w pflags,x
	stz.w temp1,x
	stz.w temp2,x
	lda.w #$0008
	sta.w temp2b,x
	lda.w #$FFFF
	sta.w temp4,x
.nna:								; outside the crease area?
	lda.w Xpos,x					; outside the crease area: skate back
	bit.w #$8000
	beq .crx
	eor.w #$FFFF					; negate
	inc a
.crx:								; crease X limit
	cmp.w #$0035
	bcs .skate
	lda.w Ypos,x
	bit.w #$8000
	beq .cry
	eor.w #$FFFF					; negate
	inc a
.cry:								; crease Y limits: past $10F is out of position, under $D3 is in position
	cmp.w #$010F
	bcs .skate
	cmp.w #$00D3
	bcs .noskate
.skate:								;skate back to the net (callback rtss)
	lda.w #rtss
	sta.b a0
	lda.w #rtss>>16
	sta.b a0+2
	lda.w #$0004
	sta.b d0
	lda.w Xpos,x
	bpl .0
	lda.w #$FFFC
	sta.b d0
.0:									; target y in front of the net, negated for the other goal
	lda.w #$00E4
	sta.b d1
	lda.w pfgoal,x
	beq .sk
	lda.w #$FF1C
	sta.b d1
.sk:								; skate there
	jml.l skateto					; d0/d1 = target, a0 = callback
.noskate:							; in position: stand ready unless an animation runs
	lda.w pf2aip,x					; pf2aip: nothing
	beq .gready
	jmp.w .rtl
.gready:							; in position: stand ready
	lda.w #SPAgready
	sta.b d1
	jsl.l SetSPA					; start animation d1
	lda.w gmclock					; clock stopped: nothing
	beq .clk
	jmp.w .rtl
.clk:								; temp5 = holding time
	lda.w temp5,x					; temp5 = holding time
	bmi .nofo
	lda.w SCnum,x
	sta.b d0
	cmp.w puckc
	beq .mbfo
	lda.w #$FFFF
	sta.w temp5,x
	bra .nofo
.mbfo:								;holding the puck: PenGhold when temp5 runs out
	lda.w temp5,x
	sec
	sbc.b d7
	sta.w temp5,x
	bpl .nofo
	lda.w #PenGhold
	sta.b d0
	jsl.l AddPenalty2				; goalie held the puck too long: holding penalty
.nofo:								; re-think every aidef/4 frames
	lda.w temp1,x					; every aidef/4 frames
	sec
	sbc.b d7
	sta.w temp1,x
	bmi .dec
	jmp.w .nodec					; skip the re-think
.dec:								; re-think every aidef/4 frames
	lda.w aidef,x
	lsr a
	lsr a
	clc
	adc.w temp1,x
	bpl .st1
	lda.w #$0000
.st1:								; store the countdown
	sta.w temp1,x
	lda.w pflags,x					; joystick goalie: only .cover
	bit.w #pfjoycon
	beq .half
	jmp.w .cover					; cover the puck
.half:								; puck in the other half: stay at the goal
	lda.w pucky						; puck in the other half: stay at the top of the crease (y +-$F4)
	sta.b d0
	lda.w Ypos,x
	eor.b d0
	sta.b d1
	bpl .cnt
	stz.b d0
	lda.w #$00F4
	sta.b d2
	lda.w pfgoal,x
	bne .other
	jmp.w .de5
.other:								; puck in the other half: stay at the top of the crease
	lda.w #$FF0C
	sta.b d2
	jmp.w .de5
.cnt:								;puck in my half
	dec.w temp4,x
	bpl .pc
	lda.w #$FFFF
	sta.w temp4,x
.pc:								; does the goalie hold the puck?
	lda.w SCnum,x
	cmp.w puckc
	beq .hold0
	jmp.w .cover
.hold0:								; 90 frames before the holding
	lda.w temp5,x					; 90 frames before the holding penalty
	bpl .hold
	lda.w #$005A
	sta.w temp5,x
.hold:								; holding: arm the hold timer
	lda.w #$FFFF
	sta.w temp4,x
	lda.w temp5,x
	sec
	sbc.w #$005A
	beq .roll
	bmi .neg
	bvs .roll
.de1j:								; out of branch range: jump to .de1
	jmp.w .de1
.neg:								; signed compare: overflow flag corrects the sign
	bvs .de1j
.roll:								; random chance to pass
	lda.w #$0064					; 1 in 4: pass
	jsl.l randoma					; random number 0 to A-1
	cmp.w #$004B
	bcs .pass
	jmp.w .de1
.pass:								; pass only if no opponent is near the puck: check the 6 opponents
	lda.w #$0005
	sta.b d0
	stz.b a0
	lda.w pfteam,x
	bne .tl
	lda.w #$000C
	sta.b a0
.tl:								;pass only if no opponent is near the puck
	ldy.b a0
	lda.w pflags,y
	bit.w #pf2unav
	bne .tn
	lda.w pucky
	sec
	sbc.w Ypos,y
	bit.w #$8000
	beq .tly
	eor.w #$FFFF					; negate
	inc a
.tly:								; opponent Y within 28 of the puck?
	cmp.w #$001D
	bcs .tn
	lda.w puckx
	sec
	sbc.w Xpos,y
	bit.w #$8000
	beq .tlx
	eor.w #$FFFF					; negate
	inc a
.tlx:								; opponent X within 25 of the puck?
	cmp.w #$001A
	bcs .tn
	jmp.w .de1
.tn:								; next opponent
	inc.b a0
	inc.b a0
	dec.b d0
	bpl .tl
	lda.w #$0001					; threat = 1, chk4pass
	sta.w threat
	jsl.l chk4pass					; pass the puck out
	bra .de1
.cover:								;cover a loose puck at the crease
	lda.w temp4,x
	bne .de1
	lda.w puckc
	bpl .de1
	lda.w puckx
	sec
	sbc.w Xpos,x
	sta.b d0
	bit.w #$8000
	beq .cvx
	eor.w #$FFFF					; negate
	inc a
.cvx:								; loose puck X near the goalie?
	cmp.w #$0015
	bcs .de1
	lda.w pucky
	sta.b d1
	bit.w #$8000
	beq .cvy
	eor.w #$FFFF					; negate
	inc a
.cvy:								; loose puck Y inside the goal line limits?
	cmp.w #$0109
	bcs .de1
	lda.b d1
	sec
	sbc.w Ypos,x
	sta.b d1
	bit.w #$8000
	beq .cvd
	eor.w #$FFFF					; negate
	inc a
.cvd:								; puck within reach in Y: dive on it
	cmp.w #$001F
	bcs .de1
	jsl.l vtoa						; vector to direction
	lda.b d0
	sta.w facedir,x					; facedir to the puck, nopuck 8, cover anim, pf2aip, crowd +150
	lda.w #$0008
	sta.w nopuck,x
	lda.w #SPAgdive
	sta.b d1
	jsl.l SetSPA					; start animation d1
	lda.w #$0096
	sta.w pf2aip,x
	clc
	adc.b Crowdlevel
	sta.b Crowdlevel
.rtl:								; return
	rtl
.de1:								;a0 = puckcross entry of my goal, d3 = goal line
	lda.w #puckcross
	sta.b a0
	lda.w #$0000
	sta.b a0+2
	lda.w #$0104
	sta.b d3
	lda.w pfgoal,x
	beq .de2
	lda.w #puckcross+pcsize
	sta.b a0
	lda.w #$FEFC
	sta.b d3
.de2:								; behind the goal line -> .out, else .in
	lda.w Ypos,x					; out of the crease in y: behind the goal line
	bit.w #$8000
	beq .de2y
	eor.w #$FFFF					; negate
	inc a
.de2y:								; compare Y against the goal line limit
	cmp.w #$0105
	bcs .out
	lda.w puckx						; face the puck: ClampYPosition, vtoa, AdjustFacingDirection
	sta.b d0
	lda.w pucky
	sta.b d1
	jsl.l ClampYPosition			; clamp the puck Y
	lda.b d1
	bit.w #$8000
	beq .near
	eor.w #$FFFF					; negate
	inc a
.near:								; puck close to the net in Y: face the puck, else .in
	cmp.w #$002E
	bcs .in
	lda.b d1
	pha								; $03,s = d1
	lda.b d0
	pha								; $01,s = d0
	jsl.l vtoa						; vector to direction
	jsl.l AdjustFacingDirection		; turn toward the puck
	lda.b $01,s
	sta.b d0
	lda.b $03,s
	sta.b d1
	jmp.w .sq						; go square the distance
.out:								;behind the goal line
	stz.b d2
	stz.b d0
	lda.w Xpos,x
	bit.w #$8000
	beq .outx
	eor.w #$FFFF					; negate
	inc a
.outx:								; behind the goal line: X distance from the net center
	cmp.w #$002D
	bcc .out2
	jmp.w .de5
.out2:								; near the post: go to the sideline spot
	lda.w #sideline
	sta.b d0
	lda.w Xpos,x
	bmi .outn
	jmp.w .de5
.outn:								; negative side
	lda.w #$FF78
	sta.b d0
	jmp.w .de5
.in:								;face the puck, lead it by its velocity
	jsl.l vtoa						; vector to direction
	jsl.l AdjustFacingDirection		; turn toward the puck
	lda.w puckvy					; lead the puck by its velocity (/2 near the ends)
	xba
	lsr a
	and.w #$007F
	bit.w #$0040
	beq .iy
	ora.w #$FF80
.iy:								; lead in Y
	clc
	adc.w pucky
	sta.b d1
	lda.w puckvx
	xba
	and.w #$00FF
	bit.w #$0080
	beq .ix
	ora.w #$FF00
.ix:								; lead in X
	sta.b d0
	lda.b d1
	sec
	sbc.w #$00E0
	beq .lo
	bmi .neg1
	bvs .lo
	bra .lead2
.neg1:								; signed compare: overflow flag corrects the sign
	bvs .lead2
.lo:								; lower limit of the lead
	lda.b d1
	sec
	sbc.w #$FF20
	beq .lead2
	bmi .neg2
	bvs .lead2
	bra .lead
.neg2:								; signed compare: overflow flag corrects the sign
	bvs .lead
.lead2:								; smaller lead outside the crease region
	lda.b d0
	pha
	asl a
	pla
	ror a
	sta.b d0
.lead:								; lead the puck by its velocity
	lda.b d0
	clc
	adc.w puckx
	sta.b d0
	jsl.l ClampYPosition			; clamp the lead target Y
	lda.b d1
	pha
	lda.b d0
	pha
.sq:								; square the target distance
	lda.b d0
	sta.b mula
	sta.b mulb
	jsl.l muls32					; signed 32-bit multiply
	sta.b d0
	lda.b mulres+2
	sta.b d0+2
	lda.b d1
	sta.b mula
	sta.b mulb
	jsl.l muls32					; signed 32-bit multiply
	sta.b d1
	lda.b mulres+2
	sta.b d1+2
	lda.b d0
	adc.b d1
	sta.b d0
	lda.b d0+2
	adc.b d1+2
	sta.b d0+2
	lda.b d0						; distance^2 < 30*30: stay
	cmp.w #$0385
	lda.b d0+2
	sbc.w #$0000
	bcs .far
	pla
	sta.b d0
	pla
	sta.b d1
	bra .de4
.far:								;scale to a 20 (28 if shooting) pixel arc
	jsl.l sroot						; distance to the target
	lda.b d0
	inc a
	sta.b d2
	lda.w #$0014
	sta.b d4
	lda.w sflags
	bit.w #sfssdir
	beq .f0
	lda.w #$001C
	sta.b d4
.f0:								; scale the target to a short arc
	pla
	sta.b d0
	pla
	sta.b d1
	sta.b mulb
	lda.b d4
	sta.b mula
	jsl.l muls32					; signed 32-bit multiply
	lda.b d2
	sta.b mula
	jsl.l divs						; signed divide
	sta.b d1
	lda.b d4
	adc.w #$0006
	sta.b d4
	sta.b mula
	lda.b d0
	sta.b mulb
	jsl.l muls32					; signed 32-bit multiply
	lda.b d2
	sta.b mula
	jsl.l divs						; signed divide
	sta.b d0
.de4:								; absolute target y
	lda.b d1
	clc
	adc.b d3
	sta.b d1
	sta.b d2
	ldy.w #$0002					; puckcross frames til crossing < $14?
	lda.b [a0],y
	cmp.w #$0014
	bcc .cross
	jmp.w .de5
.cross:								;puck crossing the goal line soon?
	lda.b [a0]
	bit.w #$8000
	beq .cx
	eor.w #$FFFF					; negate
	inc a
.cx:								; crossing X within reach?
	cmp.w #$0019
	bcc .cz
	jmp.w .rush
.cz:								; frames until crossing small enough?
	lda.b [a0],y
	cmp.w #$000C
	bcc .cy
	jmp.w .de8
.cy:								; puck Y within the goal limits?
	lda.w pucky
	bit.w #$8000
	beq .cy2
	eor.w #$FFFF					; negate
	inc a
.cy2:								; puck Y limit
	cmp.w #$0109
	bcc .aip
	jmp.w .de8
.aip:								; no animation in progress: start a save
	lda.w pf2aip,x
	beq .saveanim
	jmp.w .de8
.saveanim:							;pick the save anim: glove side by the direction, stick when low and slow,
									;stack
	inc.w pf2aip,x
	lda.b [a0]
	sec
	sbc.w Xpos,x
	sta.b d0
	lda.b d3
	sec
	sbc.w Ypos,x
	sta.b d1
	jsl.l vtoa						; vector to direction
	lda.b d0
	sec
	sbc.w facedir,x
	and.w #$0007
	sta.b d3
	lsr a
	lsr a
	sta.b d0
	lda.w attribute,x
	bit.w #attrxflip
	beq .noflip
	lda.b d0
	eor.w #$0001
	sta.b d0
.noflip:							; save type: +4 stick, -2 stack when conditions hold
	lda.w Zpos+puckobj				; puck low (Zpos <= 8) and slow: stick (+4)
	sec
	sbc.w #$0008
	beq .pz
	bmi .neg3
	bvs .pz
	bra .de7
.neg3:								; signed compare: overflow flag corrects the sign
	bvs .de7
.pz:								; puck height and speed select a stick save
	lda.w puckvz
	sec
	sbc.w #$0800
	beq .stick
	bmi .neg4
	bvs .stick
	bra .de7
.neg4:								; signed compare: overflow flag corrects the sign
	bvs .de7
.stick:								; stick save
	lda.b d0
	clc
	adc.w #$0004
	sta.b d0
	ldy.w #$0002					; more than 8 frames, facing up/down, puck carried: stack (-2)
	lda.b [a0],y
	cmp.w #$0009
	bcc .de7
	lda.w facedir,x
	cmp.w #$0002
	beq .de7
	cmp.w #$0006
	beq .de7
	lda.w puckc
	bmi .de7
	dec.b d0
	dec.b d0
.de7:								; index the save list
	asl.b d0
	lda.w #GoalieSaveList
	sta.b a1
	lda.w #GoalieSaveList>>16
	sta.b a1+2
	ldy.b d0
	lda.b [a1],y
	sta.b d1
	jsl.l SetSPA					; start animation d1
	lda.b Crowdlevel				; crowd +150
	clc
	adc.w #$0096
	sta.b Crowdlevel
.de8:								; target x = crossing x, or hug the post when the puck is wide
	lda.b [a0]
	sta.b d0
	lda.w pucky						; puck near the goal line: hug the post (+-$18)
	sec
	sbc.w #$00FC
	beq .p2
	bmi .neg5
	bvs .p2
	bra .post
.neg5:								; signed compare: overflow flag corrects the sign
	bvs .post
.p2:								; puck wide of the net?
	lda.w pucky
	sec
	sbc.w #$FF04
	beq .post
	bmi .neg6
	bvs .post
	bra .de5
.neg6:								; signed compare: overflow flag corrects the sign
	bvs .de5
.post:								;hug the post
	lda.w #$0018
	sta.b d0
	lda.w puckx
	bpl .de5
	lda.w #$FFE8
	sta.b d0
.de5:								;skate toward d0/d2 minus the velocity
	lda.b d2
	sta.b d1
	pha
	lda.b d0
	pha
	lda.w Xvel,x
	xba
	and.w #$00FF
	bit.w #$0080
	beq .vx
	ora.w #$FF00
.vx:								; negate x
	eor.w #$FFFF					; negate
	inc a
	sta.b d0
	pla
	clc
	adc.b d0
	sec
	sbc.w Xpos,x
	sta.b d0
	lda.w Yvel,x
	xba
	and.w #$00FF
	bit.w #$0080
	beq .vy
	ora.w #$FF00
.vy:								; negate y
	eor.w #$FFFF					; negate
	inc a
	sta.b d1
	pla
	clc
	adc.b d1
	sec
	sbc.w Ypos,x
	sta.b d1
	lda.w #$0005					; within 5 (10 with the puck): stop
	sta.b tmp0
	txa
	lsr a
	cmp.w puckc
	bne .near2
	asl.b tmp0
.near2:								; distance to the target
	lda.b d0
	bit.w #$8000
	beq .nx
	eor.w #$FFFF					; negate
	inc a
.nx:								; X distance under 4?
	cmp.b tmp0
	bcs .vt
	lda.b d1
	bit.w #$8000
	beq .ny
	eor.w #$FFFF					; negate
	inc a
.ny:								; Y distance under 4?
	cmp.b tmp0
	bcs .vt
	stz.b d0
	stz.b d1
.vt:								; within 4 pixels: stop, else move
	jsl.l vtoa						; vector to direction
	lda.b d0
	sta.w temp2b,x
.nodec:								; accelerate or stop
	lda.w temp2b,x					; direction > 7: StopNA, else playeracc
	sta.b d2
	sec
	sbc.w #$0007
	beq .acc
	bmi .neg7
	bvc .stop
.acc:								; accelerate the player
	jml.l playeracc					; accelerate the player
.neg7:								; signed compare: overflow flag corrects the sign
	bvc .acc
.stop:								; stop
	jmp.w StopNA					; stop the goalie
.rush:								;rush a loose puck when the tmnear stats say so
	lda.w puckc
	bmi .r1
	jmp.w .de5
.r1:								; icing possible: no rush
	lda.w iflags					; icing possible: no rush
	bit.w #ifok
	beq .r2
	jmp.w .de5
.r2:								; find own and opponent team stats
	stz.b a1
	lda.w #$0002
	sta.b a2
	lda.w pfteam,x
	beq .t0
	stz.b a2
	lda.w #$0002
	sta.b a1
.t0:								; own and other team stats thresholds
	ldy.b a1						; tmnear of my team >= $1324 and of the other >= $9C4
	lda.w tmnear,y
	cmp.w #$1324
	lda.w tmnear+4,y
	sbc.w #$0000
	bcs .t1
	jmp.w .de5
.t1:								; opponent team stat threshold
	ldy.b a2
	lda.w tmnear,y
	cmp.w #$09C4
	lda.w tmnear+4,y
	sbc.w #$0000
	bcs .r3
	jmp.w .de5
.r3:								; puck near my end, moving towards it
	lda.w pucky						; puck near my end, moving toward me, mostly in y
	sbc.w #$00E0
	beq .r4
	bmi .neg8
	bvs .r4
	bra .dir
.neg8:								; signed compare: overflow flag corrects the sign
	bvs .dir
.r4:								; puck Y beyond the rush limit?
	lda.w pucky
	sec
	sbc.w #$FF20
	beq .dir
	bmi .neg9
	bvs .dir
.de5j:								; out of branch range: jump to .de5
	jmp.w .de5
.neg9:								; signed compare: overflow flag corrects the sign
	bvs .de5j
.dir:								; puck moving toward this goal?
	lda.w puckvy
	sta.b tmp0
	lda.w pfgoal,x
	beq .dir2
	lda.b tmp0
	eor.w #$FFFF					; negate
	inc a
	sta.b tmp0
.dir2:								; puck moving away: do not rush
	lda.b tmp0
	bpl .toward
	jmp.w .de5
.toward:							; compare |vx| against |vy|
	lda.w puckvx
	bit.w #$8000
	beq .ax
	eor.w #$FFFF					; negate
	inc a
.ax:								; |vx| in d0
	sta.b d0
	lda.w puckvy
	bit.w #$8000
	beq .ay
	eor.w #$FFFF					; negate
	inc a
.ay:								; |vy| in d1, sideways puck: do not rush
	sta.b d1
	lda.b d1
	cmp.b d0
	bcs .ins
	jmp.w .de5
.ins:								; insert agoalietopuck
	lda.w #agoalietopuck			; agoalietopuck
	sta.b d0
	jmp.w assinsert
