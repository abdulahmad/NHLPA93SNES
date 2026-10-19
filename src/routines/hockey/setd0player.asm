setd0player:						;Give player d0 to his team's controller, unless a controller already has
									;him
	lda.b d0
	cmp.w c1playernum				; already controller 1
	beq .rtl
	cmp.w c2playernum				; or 2
	beq .rtl
	stz.b d1						; team 1 (home)
	cmp.w #$0006					; players 0-5 are home
	bcs .away						; away
	dec.b d1						; home: 0
.away:
	inc.b d1						; away: 2
	inc.b d1
	lda.w lastplayer				; last player
	cmp.w c2playernum				; controller 2
	beq .c2
	lda.b d1						; team
	cmp.w cont1team					; controller 1 team
	bne .c2							; no
	jml.l setc1player				; give it to controller 1
.c2:
	lda.b d1
	cmp.w cont2team					; controller 2 team
	bne .c1
	jml.l setc2player				; give it to controller 2
.c1:
	cmp.w cont1team					; controller 1 team
	bne .rtl						; no: nobody
	jml.l setc1player
.rtl:
	rtl
