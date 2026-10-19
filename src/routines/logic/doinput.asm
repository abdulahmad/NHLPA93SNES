doinput:							;Pad input for player X. d0 = pad directions, d1 = new buttons, d4 =
									;controller
	jsl.l setpads					; setpads; Start: pause
	lda.b d1						; new buttons
	bit.w #JOYSTART					; Start pressed?
	beq .0
	lda.b d4						; controller number
	bne .pause2
	jml.l startpause1				; pause for controller 1
.pause2:
	jml.l startpause2				; pause for controller 2
.0:
	lda.w sfhormode					; horizontal mode: dpad +90 degrees
	beq .nhor
	lda.b d0						; pad direction
	bit.w #$0008					; bit 3: no direction
	bne .nhor
	inc a							; turn the direction by 2 (90 degrees)
	inc a
	and.w #$0007
	sta.b d0
.nhor:
	lda.w sflags					; faceoff in progress
	bit.w #sf2faceoff				; faceoff in progress?
	beq .nofo
	jmp.w faceoffinput				; face off input
.nofo:
	lda.w pflags,x					; line change interface
	bit.w #pf2lcm					; line change menu active?
	beq .nolcm
	jml.l lineinput					; line change input
.nolcm:
	bit.w #pfjoycon					; not joystick controlled: exit
	bne .joy
	jmp.w .rtl
.joy:
	lda.w pfalock,x					; animation locked?
	beq .nolock
	jmp.w .islocked
.nolock:
	lda.w pf2fight,x				; fighting?
	beq .nofight
	jml.l fightinput				; fight input
.nofight:
	lda.w puckc						; carrier?
	sta.b d5						; puck carrier
	txa
	lsr a
	cmp.b d5						; is X the carrier?
	beq .ispc
	lda.b d1
	bit.w #abut						; A: hold
	beq .nohold
	jmp.w Holdplayer				; hold the player
.nohold:
	bit.w #bbut						; B: change player
	beq .nob
	jmp.w changeplayer				; switch to the nearest player
.nob:								;goalie cannot check
	lda.w position,x				; goalie?
	beq .rtl
	lda.b d1
	bit.w #cbut						; C: burst
	beq .acc
	jmp.w burst						; burst of speed
.acc:
	jml.l doplayeracc				; skate
.ispc:								;player is the puck carrier
	jsl.l checkob					; goalie with pf2aip: exit
	lda.w position,x
	bne .pc1
	lda.w pf2aip,x					; animation in progress
	bne .rtl
.pc1:
	lda.w sflags
	bit.w #sfspdir					; pass direction pending?
	beq .nopass
	jml.l passmode					; pass mode
.nopass:
	bit.w #sfssdir					; shot direction pending?
	beq .noshot
	jmp.w ShotMode					; shot mode
.noshot:
	lda.b d1
	bit.w #bbut						; B: pass
	bne .setpassmode
	lda.w sflags					; Y without a faceoff: line change mode
	bit.w #sf2faceoff
	bne .shoot
	lda.b d1
	bit.w #abut						; A: line change
	bne .lc
.shoot:
	lda.w position,x				; goalie?
	beq .rtl
	lda.b d1
	bit.w #cbut						; C: shoot
	beq .acc2
	jmp.w SetShotMode				; start the shot
.acc2:
	jml.l doplayeracc				; skate
.lc:
	lda.w lcplayer					; lcplayer $FFFF -> $FFFE
	cmp.w #$FFFF
	bne .setlc
	lda.w #$FFFE					; reset it
	sta.w lcplayer
.setlc:
	jmp.w SetLCmode					; line change mode
.islocked:							;anim locked: only B (switch player) when not the carrier
	txa
	lsr a
	cmp.w puckc						; puck carrier?
	beq .rtl
	lda.b d1
	bit.w #$8000					; B pressed?
	beq .rtl
	jmp.w changeplayer				; switch player
.rtl:
	rtl
.setpassmode:						;the goalie keeps the puck behind the net (|x| < 16, |y| $108-$10F)
	lda.w position,x				; goalie?
	bne .set
	lda.w puckx
	bit.w #$8000
	beq .px
	eor.w #$FFFF					; negate
	inc a
.px:
	cmp.w #$0010					; |x| under 16
	bcs .set
	lda.w pucky
	bit.w #$8000
	beq .py
	eor.w #$FFFF					; negate
	inc a
.py:
	cmp.w #$0108					; |y| under $108
	bcc .set
	cmp.w #$0110					; or under $110
	bcc .rtl2
.set:
	lda.w facedir,x					; passdir = facedir; sfspdir
	and.w #$0007
	sta.w passdir
	lda.w #sfspdir					; pass direction pending
	tsb.w sflags
.rtl2:
	rtl
