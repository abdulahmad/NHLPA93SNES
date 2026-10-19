ResetAndSelectPlayers:				;Clear the human controlled players, then give each human team its player
									;again
	lda.w #$FFFF					; no controlled players
	sta.w c1playernum
	sta.w c2playernum
	lda.w cont1team					; controller 1 on a team
	beq .nt1
	stz.b d4						; controller 1
	jsl.l changeplayer				; select his player
.nt1:
	lda.w cont2team
	beq .rtl						; controller 2 on a team
	lda.w #$0002
	sta.b d4						; controller 2
	jsl.l changeplayer				; select his player
.rtl:								; return
	rtl
