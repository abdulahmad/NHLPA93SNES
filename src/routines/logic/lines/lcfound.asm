lcfound:							;Change team a2 to the chosen line
	ldx.b a3						; player
	ldy.b a2						; team
	lda.b d2						; chosen line
	sta.b d0
;save the chosen row in tmlcchoice: the box redraw shows only that row
	sta.w tmlcchoice,y				; remember the choice
	jsl.l getlchoice				; find the line
	lda.b d0
	bmi .rtl						; none found: leave
;accepted: leave line change mode, keep the joystick, set the new line and re-pick the players
	lda.w pflags,x
	and.w #~pf2lcm&$FFFF			; no longer in line change mode
	ora.w #pfjoycon					; human controlled
	sta.w pflags,x
	jsl.l loadTeamStruct			; team structure
	ldy.b a2
	lda.w tmflags,y
	and.w #~tmflcm&$FFFF			; team out of line change mode
	sta.w tmflags,y
	lda.b d0
	sta.w tmline,y					; new line
	jsl.l setpersonel				; new personnel
	jml.l lcfound_close					; redraw
.rtl:								; return
	rtl
