assnearest:							;Assignment: the player nearest the puck who does not have it. Hands the
									;job to a teammate who is nearer,
		;   then skates to the puck or to a spot between the puck and his goal, looking for a check
	lda.w pflags,x					; player flags
	bit.w #pfna						; pfna
	beq .nna
	and.w #~pfna&$FFFF
	sta.w pflags,x
	stz.w temp3,x					; clear the timers
	stz.w temp2,x
	lda.w #$0008
	sta.w temp2b,x
	stz.w temp1,x
.nna:
	txa								; player number
	lsr a
	sta.b d1						; d1 = player number
	cmp.w puckc						; X has the puck?
	bne .nopc
	lda.w position,x				; goalie?
	bne .pc
	jmp.w assgoalie					; goalie assignment
.pc:
	lda.w #apuckc					; apuckc unless joystick controlled
	sta.b d0
	lda.w pflags,x
	bit.w #pfjoycon
	bne .rts
	jmp.w assinsert					; insert the assignment
.rts:								; return
	rtl
.nopc:								;every aioff frames: find the teammate nearest the (moving) puck
	lda.w temp1,x					; timer
	sec
	sbc.b d7						; minus the frame count
	sta.w temp1,x
	bmi .dec						; expired: look again
	jmp.w .nodec
.dec:
	adc.w aioff,x					; reload temp1 from aioff
	bpl .setcnt
	lda.w #$0000
.setcnt:
	sta.w temp1,x
	ldy.b a2						; team of this player
	lda.w #$0000					; tmnear = 0
	sta.w tmnear,y
	sta.w tmnear+4,y
	lda.w puckc
	bmi .np
	asl a							; puck carrier index
	sta.b a1
	tay
	lda.w pfteam,y					; puck carrier on my team?
	beq .pcteam
	lda.w #$0001
.pcteam:
	sta.b tmp0						; carrier team 0/1
	lda.w pfteam,x					; my team
	beq .myteam
	lda.w #$0001
.myteam:
	eor.b tmp0						; same team as the puck carrier?
	bne .np
	jmp.w .switch					; then switch
.np:
	lda.w #$FFFF					; d2 = best distance^2 = $FFFFFFFF
	sta.b d2
	sta.b d2+2
	lda.w #$0005					; 6 players
	sta.b d4
	ldy.b a2						; team of this player
	lda.w tmsort,y					; a0 = first object of the team
	sta.b a0
.de0:
	ldy.b a0
	lda.w position,y				; position
	bpl .pos						; skip empty slots
	jmp.w .next
.pos:
	bne .nop						; skip goalies
	jmp.w .next
.nop:
	lda.w nopuck,y					; puck lockout
	beq .unav
	jmp.w .next
.unav:
	lda.w pflags,y					; player flags
	bit.w #pf2unav					; unavailable?
	beq .pass
	jmp.w .next
.pass:
	tya								; assignment index
	asl a
	asl a
	adc.w assnum,y
	tay
	lda.w asslist,y					; his current assignment
	and.w #$00FF
	cmp.w #apassrec					; skip a player on apassrec
	bne .dist
	jmp.w .next
.dist:
	lda.b a0
	jsl.l GetHot					; hot spot offset
	ldy.b a0
	lda.b d0						; offset x
	clc
	adc.w Xpos,y
	sec
	sbc.w puckx						; minus the puck x
	sta.b d0
	lda.b d1						; offset y
	clc
	adc.w Ypos,y
	sec
	sbc.w pucky						; minus the puck y
	sta.b d1
	lda.w puckvx					; lead the puck: puckvx/64
	lsr a
	lsr a
	lsr a
	lsr a
	lsr a
	lsr a
	bit.w #$0200
	beq .vx
	ora.w #$FC00
.vx:
	sta.b d3						; puckvx / 64
	lda.b d0
	sec
	sbc.b d3						; minus the lead
	sta.b d0
	lda.w puckvy
	lsr a
	lsr a
	lsr a
	lsr a
	lsr a
	lsr a
	bit.w #$0200
	beq .vy
	ora.w #$FC00
.vy:
	sta.b d3						; puckvy / 64
	lda.b d1
	sec
	sbc.b d3						; minus the lead
	sta.b d1
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
	adc.b d0						; sum
	sta.b d0
	lda.b mulres+2
	adc.b d0+2
	sta.b d0+2
	lda.b d2						; nearer?
	cmp.b d0						; compare with the best
	lda.b d2+2
	sbc.b d0+2
	bcc .next						; farther: next
	lda.b d0
	sta.b d2
	lda.b d0+2
	sta.b d2+2
	lda.b a0						; new best player
	sta.b a1
.next:
	inc.b a0						; next player
	inc.b a0
	dec.b d4						; players left
	bmi .done
	jmp.w .de0
.done:
	lda.b d2+2						; found a player?
	bmi .de1
	ldy.b a2						; team of this player
	sta.w tmnear+4,y				; tmnear = nearest distance^2
	lda.b d2
	sta.w tmnear,y
.switch:							;if another player is nearer: give him anearest and leave
	cpx.b a1						; is X the nearest?
	beq .de1
	lda.w gmclock					; clock stopped
	bne .de1
	ldy.b a1						; candidate
	lda.w pflags,y
	bit.w #pf2unav					; unavailable?
	bne .de1
	ldx.b a1						; exg a1,a3 (X = a1)
	ldy.b a3
	stx.b a3
	sty.b a1
	lda.w pflags,x					; player flags
	and.w #~pfdoff&$FFFF			; clear pfdoff
	sta.w pflags,x
	lda.w #anearest					; anearest
	sta.b d0
	jsl.l assinsert					; insert assignment d0
	ldx.b a1						; exg back
	ldy.b a3
	stx.b a3
	sty.b a1
	jmp.w assexit					; leave the assignment
.de1:
	lda.w pfalock,x					; animation locked?
	beq .odds
	jmp.w .rts
.odds:
	lda.w #$0002					; default shift 2
	sta.b d1
	lda.b d2						; best distance
	cmp.w #$0191					; 20^2
	bcs .nfar
	stz.b d1						; shift 0
	lda.w position,x				; position
	cmp.w #$0003
	bcc .nodec
.nfar:
	lda.w sflags
	bit.w #sf2pwrplay				; sf2pwrplay
	beq .x
	dec.b d1
	dec.b d1
	jsl.l chkpk2					; check the puck
	bne .x
	inc.b d1
	inc.b d1
	inc.b d1
	inc.b d1
.x:
	lda.w #$0014					; ($14-aggress) << d1
	sec
	sbc.w aggress,x					; minus aggression
	sta.b d0
	lda.b d1						; shift count
	sta.b tmp0
.shl:
	dec.b tmp0
	bmi .rnd
	asl.b d0						; shift left
	bra .shl
.rnd:
	jsl.l randomd0					; random number 0 to d0-1
	lda.b d0
	cmp.w #$0002					; 2 or more: no change
	bcs .nodec
	lda.w #$00F0					; temp3 = 240
	sta.w temp3,x
.nodec:
	lda.w pfalock,x					; animation locked?
	beq .clk
	jmp.w .rts
.clk:
	lda.w gmclock					; clock stopped?
	beq .joy
	jml.l assnothing
.joy:
	lda.w pflags,x					; player flags
	bit.w #pfjoycon					; joystick controlled?
	beq .mode
	jmp.w .rts
.mode:
	ldy.b a2
	lda.w tmflags,y					; tmfmid: always the in-between spot
	bit.w #tmfmid
	bne .mid
	lda.w puckc						; puck carrier
	bpl .cnt
	jmp.w .topuck
.cnt:
	lda.w temp3,x					; temp3 timer
	sec
	sbc.b d7						; minus the frame count
	sta.w temp3,x
	bmi .clr						; expired: clear it
	jmp.w .topuck
.clr:
	stz.w temp3,x					; clear it
.mid:								;skate to halfway between the puck spot and the own goal mouth (0,+-$F4)
	jsl.l skatetopuckinit			; d0/d1 = puck spot
	lda.b d1
	pha
	lda.b d0
	pha
	eor.w #$FFFF					; negate
	inc a
	sta.b d0
	lda.b d1
	eor.w #$FFFF					; negate
	inc a
	clc
	adc.w #$00F4					; own goal mouth y $F4
	sta.b d1
	lda.w pfgoal,x					; which end
	beq .nd0
	lda.b d1
	sec
	sbc.w #$01E8					; $1E8 = 2*$F4 for the top goal
	sta.b d1
.nd0:
	lda.b d0
	pha
	asl a							; asr #1
	pla
	ror a
	sta.b d0
	lda.b d1
	pha
	asl a
	pla
	ror a
	sta.b d1
	pla
	clc								; add the puck spot
	adc.b d0
	sta.b d0
	pla
	clc
	adc.b d1
	sta.b d1
	ldy.b a2
	lda.w tmflags,y					; team flags
	bit.w #tmfmid
	beq .go
	lda.w pfgoal,x					; which end
	beq .neg
	lda.b d1
	sec
	sbc.w #$0053					; limit y
	bmi .neg1
	bvc .clamp1
	bra .go
.neg1:								; signed compare: overflow flag corrects the sign
	bvc .go
.clamp1:
	lda.w #$0044					; clamp y
	sta.b d1
	bra .go
.neg:
	lda.b d1						; y
	sec
	sbc.w #$FFAD					; limit
	beq .clamp2
	bmi .neg2
	bvs .clamp2
	bra .go
.neg2:								; signed compare: overflow flag corrects the sign
	bvs .go
.clamp2:
	lda.w #$FFBC					; clamp y
	sta.b d1
.go:
	lda.w #rtss						; a0 = rtss: nothing to do on arrival
	sta.b a0
	lda.w #rtss>>16
	sta.b a0+2
	jsl.l skateto					; d0/d1 = spot, [a0] = arrival routine
	jmp.w check4check				; then check for a check
.topuck:
	jsl.l skatetopuck				; skate to the puck
	jmp.w check4check				; then check for a check
