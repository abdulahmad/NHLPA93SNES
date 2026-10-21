clearTeamStats:						;Clear the team stats (but the goalie choice) and both penalty box lists,
									;then set up the teams
	lda.w tmgoalie					; keep tmgoalie (2 words)
	pha
	lda.w tmgoalie+2
	pha
	ldx.w #$0000					; stats area $1CC bytes
.clr:								; clear a word
	stz.w tmshots,x					; clear a word
	inx
	inx
	cpx.w #$01CC
	bne .clr
	pla								; restore tmgoalie
	sta.w tmgoalie+2
	pla
	sta.w tmgoalie
	lda.w #$FFFF					; both penalty box lists empty
	sta.w tmboxlist					; empty
	sta.w tmboxlist+maxros			; second list
	jml.l setteams					; set up the teams
