UpdateTeamSprites:					;Draw the two roster players shown in the team blocks
	ldx.w #$0000					; team 0 player
	stx.b a3						; X
	jsl.l DrawScoutPlayer			; draw him
	ldx.w #$000C					; team 1 player
	stx.b a3						; X
DrawScoutPlayer:					;addframe for object X at (Xpos + OldXpos - 144, Ypos - 128)
	lda.w Xpos,x					; x
	clc
	adc.w OldXpos,x
	sec
	sbc.w #$0090					; minus 144
	sta.b sprx
	lda.w Ypos,x					; y
	sec
	sbc.w #$0080					; minus 128
	sta.b spry
	lda.w frame,x					; frame
	sta.b sprframe
	lda.w attribute,x				; attribute
	and.w #attrxflip
	sta.b sprhflip					; h flip
	lda.w attribute,x
	and.w #attryflip
	sta.b sprvflip					; v flip
	lda.w attribute,x
	lsr a							; bit 0
	bcc .add
	lda.w #$8000					; flag
	sta.b sprflag
.add:
	jml.l addframe					; draw it
