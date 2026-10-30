assfaceoffpl:						;Assignment: the players taking the face off
	lda.w pfalock,x					; locked
	beq .go							; no
	jmp.w .rts						; yes: leave
.go:								; is the faceoff over?
	lda.w sflags					; flags
	bit.w #sf2faceoff				; faceoff over
	beq .exit						; over: exit
	lda.w pflags,x					; player flags
	bit.w #pfna
	beq .nna						; not new
	and.w #~pfna&$FFFF				; clear the new flag
	sta.w pflags,x
;first time: clear temp1
	stz.w temp1,x					; temp1 = 0
.nna:								; a0 = fofdata2 (home) or +4 (visitor): big faceoff data
	lda.w #fofdata2					; a0 = fofdata2, +4 for the visitors
	sta.b a0
	lda.w #$0000					; bank 0
	sta.b a0+2
	lda.w pfteam,x					; team
	beq .0							; team 0
	lda.w #fofdata2+fosize			; visitors
	sta.b a0
.0:									; d0 = SPAnum/4 + 1, +3 for right handed: frame code
	lda.w SPAnum,x					; frame = SPAnum/4 + 1, +3 for a righty
	lsr a
	lsr a
	inc a
	sta.b d0						; frame
	lda.w handed,x					; handedness
	bne .lefty						; left
	inc.b d0
	inc.b d0
	inc.b d0
.lefty:								; store frame code
	lda.b d0						; frame
	sta.b [a0]						; store it
	lda.w pflags,x					; flags
	bit.w #pfjoycon					; joystick: the player pulls
	bne .rts						; human: leave
;computer: start the swing only once
	lda.w pf2aip,x					; set pf2aip, test the old value
	pha
	lda.w #$0001					; new value
	sta.w pf2aip,x
	pla
	cmp.w #$0000
	bne .rts						; already pulling: leave
	lda.w #SPAfaceoff				; face off animation
	sta.b d1
	lda.w temp1+puckscnum				; puck temp1 > $10: 7 in 8 reverse pull
	cmp.w #$0011
	bcc .d
	lda.w #$0008
	sta.b d0						; 1 in 8
	jsl.l randomd0					; random
	lda.b d0
	beq .d							; zero: normal
	lda.w #SPAfaceoffr				; reverse animation
	sta.b d1
.d:									; swing animation started
	lda.w #$0001					; flag
	sta.w pf2aip,x
	jmp.w SetSPA					; start it
.rts:								; return
	rtl
.exit:								; nopuck = 20
	lda.w #$0014					; nopuck = 20
	sta.w nopuck,x					; no puck for 20 frames
	jmp.w assexit					; assignment over
