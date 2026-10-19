restoreteams:						;Put both teams' players on the bench
	stz.b a2						; team 0
	jsl.l .r						; do it
	lda.w #$0002					; team 1
	sta.b a2
.r:									;one team (a2)
	ldy.b a2						; team
	lda.w #6						; lines used
	sta.w tmap,y
	lda.w #$32						; last player
	sta.b d0
.0:
	lda.b a2						; team
	beq .home
	lda.w #$34						; away team offset
.home:								; index the team table
	clc
	adc.b d0
	tay								; index
	lda.w #TMPDBENCH				; TMPDBENCH
	sta.w tmpdst,y					; on the bench
	dec.b d0						; previous player
	dec.b d0
	bpl .0
	rtl
