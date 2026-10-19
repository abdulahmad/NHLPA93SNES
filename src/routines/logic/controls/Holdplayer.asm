Holdplayer:							;Hold button: hook, or with an impact hold the player who last hit X
	lda.w #SPAhook					; pfalock
	sta.b d1
	sta.w pfalock,x					; player is locked in the hook animation
	lda.w impact,x					; hit by someone
	bne .imp
	jmp.w SetSPA					; no: start the hook
.imp:								; a hit: hold that player
	lda.w impactp,x					; a0 = d0 = impactp*2
	asl a							; a hit: hold that player
	sta.b d0
	sta.b a0
	jml.l Acheck					; check him
