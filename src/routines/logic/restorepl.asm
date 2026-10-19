restorepl:							;Take the controller off player d1 and give it to player d0; a player in a
									;line change keeps the controller
	stz.b a0
	lda.b d1						; old player
	bmi .spd						; none
	cmp.w #$000C					; only players 0-11
	bcs .spd
	asl.b d1						; player offset
	ldy.b d1						; index
	lda.w pflags,y					; flags
	bit.w #pf2lcm					; pf2lcm: he keeps the joystick
	beq .rel						; not in line change: release
	lsr.b d1						; player number
	lda.b d1
	sta.b d0						; d0 = him
	rtl
.rel:								;release the old player: clear pfjoycon, set pfna
	and.w #~pfjoycon&$FFFF			; clear pfjoycon, set pfna
	ora.w #pfna
	sta.w pflags,y
.spd:								;set pfjoycon on the new player
	lda.b d0						; new player
	bmi .rtl						; none
	cmp.w #$000C					; only players 0-11
	bcs .rtl
	sta.b d1						; offset
	asl.b d1
	ldy.b d1
	lda.w pflags,y					; flags
	ora.w #pfjoycon					; controller on
	sta.w pflags,y
.rtl:
	rtl
