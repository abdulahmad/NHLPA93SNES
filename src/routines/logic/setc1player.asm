setc1player:						;Give controller 1 to player d0
	lda.b d0
	cmp.w c1playernum				; already his
	beq .rtl
	lda.w c1playernum				; old player
	sta.b d1
	jsl.l restorepl					; give the old player back to the computer
	lda.b d0
	sta.w c1playernum				; new controlled player
.rtl:								; return
	rtl
