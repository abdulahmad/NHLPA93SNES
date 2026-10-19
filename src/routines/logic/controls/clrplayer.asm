clrplayer:							;Take the controller off player X
	lda.w pflags,x
	bit.w #pfjoycon					; controlled?
	beq asspenalty_rtl				; no: nothing to do
;d4 = controller that holds this player (0 or 2); pick a new player for it
	stz.b d4						; d4 = 0: controller 1
	txa
	lsr a							; player number
	sta.b d0
	cmp.w c1playernum				; player of controller 1
	beq .ch
	inc.b d4						; controller 2: d4 = 4
	inc.b d4
.ch:								; far branch to changeplayer
	jml.l changeplayer
