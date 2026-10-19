assepen:							;Assignment: player X leaves the penalty box and comes onto the ice
	lda.w pflags,x					; flags
	bit.w #pfna
	beq .nna						; not new
	and.w #~pfna&$FFFF				; clear the new flag
	sta.w pflags,x
;first time: leave the box (PBnum -= 1 for this team), place at the sideline x, y = -60/+60, and climb out
	ldy.w #$0010					; $10 for team 0
	lda.w pfteam,x
	beq .1							; team 0
	ldy.w #$0001					; 1 for team 1
.1:
	sty.b d0						; d0 = step
	lda.w PBnum						; box count
	sec
	sbc.b d0						; minus the step
	sta.w PBnum						; store it
	stz.w Xvel,x					; no speed
	stz.w Yvel,x
	lda.w #60						; y of the box exit
	sta.b d0
	lda.w pfteam,x
	bne .ypos						; team 0: y = 60
	lda.w #-60						; else y = -60
	sta.b d0
.ypos:
	lda.b d0						; y
	sta.w Ypos,x
	lda.w #sideline					; x = the sideline
	sta.w Xpos,x
	lda.w #$0002					; facing
	sta.w facedir,x
	sta.w pfalock,x					; lock the animation
	lda.w #SPAwallleft				; wall animation
	sta.b d1
	jsl.l SetSPA					; start it
	jml.l SprSort					; sort the sprites
.nna:
	lda.w #$0004					; facing
	sta.w facedir,x
	lda.w #$FFFF					; no request
	sta.w newpnum,x
	sta.w newpos,x
	lda.w pflags,x					; flags
	and.w #$6FF7
	sta.w pflags,x
	stz.w pfnc,x					; collision on
	lda.w #$F000					; speed
	sta.w Xvel,x
	jml.l assexit					; assignment over
unusedFF87:							;unused, $FF fill to the end of the bank
	db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
