asspenalty:							;Assignment: player X skates to the penalty box, glides in and faces the
									;ice
	lda.w pfalock,x					; assignment locked?
	beq .na
	jmp.w .rtl
.na:								; new assignment?
	lda.w pflags,x					; new assignment
	bit.w #pfna
	beq .nna
;first time: unavailable, joystick off him, target = box slot y, x = Sideline
	and.w #~pfna&$FFFF
	ora.w #pf2unav
	sta.w pflags,x
	jsl.l clrplayer					; clear the player
	lda.w #-2						; setpads -2: number on the leaving player
	sta.b d4
	jsl.l setpads					; set up the pads
	stz.w temp2,x					; clear the timers
	lda.w #8
	sta.w temp2b,x
	lda.w #11						; temp4 = 11 * (n + 3), n = players in the box (0-2)
	sta.b d0
	lda.w PBnum
	sta.b d1
	lda.w pfteam,x					; which team
	bne .0
	lda.b d1
	lsr a							; high nibble for the first team
	lsr a
	lsr a
	lsr a
	sta.b d1
	lda.w #-11
	sta.b d0
.0:									; low nibble for the second
	lda.b d1
	and.w #$000F					; low nibble for the second
	sta.b d1
	cmp.w #3
	bcc .1
	lda.w #2						; at most 2
	sta.b d1
.1:									; slot number + 3
	inc.b d1						; plus 3
	inc.b d1
	inc.b d1
	lda.b d0
	sta.b mula
	lda.b d1
	sta.b mulb
	jsl.l muls16					; signed multiply
	sta.b d1
	sta.w temp4,x					; box y
	lda.w #Sideline					; temp3 = $88: the Sideline
	sta.w temp3,x					; Sideline x
	stz.w temp1,x					; clear the timer
	lda.w pflags,x					; pf2npc: no player collision
	ora.w #pf2npc					; no player collisions
	sta.w pflags,x
	stz.w Wallcos,x					; clear the wall normal
	stz.w Wallsin,x
.nna:								; near the box door
	lda.w Ypos,x					; player y
	sec
	sbc.w temp4,x					; minus the box y
	bit.w #$8000
	beq .ay
	eor.w #$FFFF					; negate
	inc a
.ay:								; within 13 of the box y?
	cmp.w #13						; within 13 of the box y?
	bcc .in
	jmp.w .st
.in:								; distance from the box in x
	lda.w Xpos,x					; player x
	sec
	sbc.w temp3,x					; minus the box x
	sta.b d0
	sec
	sbc.w #-24						; within 24 of the box x?
	bmi .neg
	bvc .near
.st0:								; far branch to .st
	jmp.w .st
.neg:								; signed compare: overflow flag corrects the sign
	bvc .st0
.near:								; wait out temp1 in steps of 8
;wait out temp1 in steps of 8
	lda.w temp1,x					; timer
	sec
	sbc.b d7						; minus the frame count
	sta.w temp1,x
	bmi .step
	jmp.w .rtl
.step:								; reload the timer
	adc.w #8						; reload it
	sta.w temp1,x
;glide in, turn toward d2: right handed faces 6 (left, away from the box), left handed faces 2
;(right, toward the box). Righty faces 6 (mirrored to frame dir 2), lefty faces 2: both show the
;same glide frame, the righty x-flipped
	lda.w #SPAglide					; SPAglide, pfnc
	sta.b d1
	sta.w pfnc,x					; no collisions
	jsl.l SetSPA					; start animation d1
	lda.w #6						; face 6 = left (2 = right for a left handed player)
	sta.b d2						; face 6
	lda.w handed,x
	beq .left						; right handed (handed = 0)
	lda.w #2						; left handed: face 2 = right
	sta.b d2
.left:								; label name is 92G's; the branch is taken by right handed players
									; (handed 0), who keep d2 = 6 (face left); left handed set d2 = 2
									; turn one step toward d2
	lda.w facedir,x					; facing direction
	cmp.b d2						; there yet?
	beq .ok
	inc a							; turn one step
	and.w #$0007
	sta.w facedir,x
.ok:								; skate right
	stz.w Yvel,x					; stop in y
	lda.w #$1000					; slide in x
	sta.w Xvel,x
	lda.b d0
	sec
	sbc.w #-8						; within 8 of the box?
	bmi .neg1
	bvc .stop
	bra .rtl
.neg1:								; signed compare: overflow flag corrects the sign
	bvc .rtl
.stop:								; facing the right way?
	stz.w Xvel,x					; stop sliding
	lda.w facedir,x					; facing the right way?
	cmp.b d2
	bne .rtl
	lda.w #2						; face 2
	sta.w facedir,x
	sta.w pfalock,x					; lock the assignment
	lda.w #SPAwallright				; SPAwallright
	sta.b d1						; wall animation
	jsl.l SetSPA					; start animation d1
	lda.w pflags,x
	and.w #~pf2pen&$FFFF			; pf2pen off
	sta.w pflags,x
	lda.w #$0D						; adopen
	sta.b d0
	jml.l assreplace				; replace the assignment with d0
.rtl:								; return
	rtl
.st:								;skate to the box
	lda.w temp3,x					; box x
	sta.b d0
	lda.w temp4,x					; box y
	sta.b d1
	lda.w #rtss						; a0 = rtss: no avoidance
	sta.b a0
	lda.w #rtss>>16
	sta.b a0+2
	jml.l skateto					; skate to the box
