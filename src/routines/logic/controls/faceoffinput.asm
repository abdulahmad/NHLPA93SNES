faceoffinput:						;Pad input for a player taking a face off
	txa								; faceoff player only
	asl a							; player * 4
	asl a
	adc.w assnum,x					; plus the assignment slot
	tay								; index
	lda.w asslist,y					; assignment
	and.w #$00FF
	cmp.w #afaceoffpl				; face off
	bne .rtl						; no: leave
	lda.w #fodir1					; team 0 direction
	sta.b a0
	lda.w #$0000
	sta.b a0+2
	lda.w pfgoal,x					; goal end
	beq .2							; top
	lda.w #fodir2					; team 1 direction
	sta.b a0
	lda.w #$0000
	sta.b a0+2
.2:
	lda.b d0						; pad direction
	sta.b [a0]						; store it
	lda.w pf2aip,x					; pf2aip set: already pulling
	bne .rtl
;B swings at the puck (once: pf2aip marks it); otherwise ready stance
	lda.b d1						; buttons
	bit.w #bbut						; B button
	beq .1							; no
	lda.w #SPAfaceoff				; normal pull
	sta.b d1
	lda.w #$0001					; set the flag
	sta.w pf2aip,x
	jmp.w SetSPA					; start it
.1:
	lda.w #SPAfaceoffr				; reverse pull
	sta.b d1
	jmp.w SetSPA					; start it
.rtl:								; return
	rtl
