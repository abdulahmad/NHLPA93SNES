SetLCmode:							;Open the line change box for player X's team, when line changes are on
									;and the box is not already open
	lda.w OptLine					; line changes off?
	bne .rtl						; yes: leave
	jsl.l loadTeamStruct			; loadTeamStruct: a2 = team of X
	ldy.b a2						; team structure offset
	lda.w tmflags,y
	bit.w #tmflcm					; tmflcm: team already in lc mode
	bne .rtl
	ora.w #tmflcm					; mark it
	sta.w tmflags,y
	lda.w #sfspdir|sfssdir			; clear sfspdir/sfssdir
	trb.w sflags
	lda.w pflags,x					; player flags
	ora.w #pf2lcm					; pf2lcm
	sta.w pflags,x
	lda.w lcplayer					; remember the player when lcplayer = $FFFE
	cmp.w #$FFFE
	bne .show
	txa								; player number
	lsr a
	sta.w lcplayer
.show:
	jmp.w SetLCmode2				; show the box
.rtl:
	rtl
