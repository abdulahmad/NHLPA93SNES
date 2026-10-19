setc2player:						;Give controller 2 to player d0
	lda.b d0
	cmp.w c2playernum				; already his
	beq .rtl
	lda.w c2playernum				; old player
	sta.b d1
	jsl.l restorepl					; give the old player back to the computer
	lda.b d0
	sta.w c2playernum				; new controlled player
.rtl:
	rtl
