updatepentime:						;Once a second, count down the penalty box times of both teams and release
									;players whose time is up
	lda.w #$0020					; clear flag $20
	trb.w sflags3
	lda.w gmclock					; clock stopped
	bne .rtl						; yes: leave
	lda.w pentimer					; second countdown
	sec								; minus d7
	sbc.b d7
	sta.w pentimer
	bpl .rtl						; not a second yet
	adc.w #jps						; reload with jps
	sta.w pentimer
	lda.w #$0020					; set flag $20
	tsb.w sflags3
	jsl.l chkatop					; attack zone time
	stz.b a2						; team 0
	jsl.l .team						; do it
	lda.w #$0002					; team 1
	sta.b a2
.team:								;team a2
	lda.b a2
	beq .noa2						; team 0
	lda.w #$001A					; team 1 list offset
.noa2:								; a0 = list offset
	sta.b a0						; a0 = list offset
	lda.w #mesarea					; message buffer
	sta.b a1
	lda.w #mesarea>>16
	sta.b a1+2
	lda.w #$0002					; two slots
	sta.b d1
	sta.b d3
.next:								; next list entry
	ldy.b a0						; list byte
	lda.w tmboxlist,y
	inc.b a0						; next entry
	and.w #$00FF					; player number
	sta.b d0
	bit.w #$0080					; end marker
	bne .done						; done
	lda.b a2
	beq .noa22						; team
	lda.w #$0034					; away team offset
.noa22:								; index the penalty entry
	clc
	adc.b d0
	tay
	lda.w tmpdst,y					; state
	bit.w #$4000					; coincidental penalty
	bne .coinpen
	dec.b d1						; one slot less
	bmi .next						; no more slots
	lda.b d0
	sta.b [a1]						; store the player
	inc.b a1
	inc.b a1
	lda.w tmpdst,y					; state
	dec a							; one second less
	sta.w tmpdst,y
	bne .stay						; still in the box
	jsl.l RemovePlayerFromList		; out: remove from the list
.stay:								; still in the box
	bra .next						; next entry
.rtl:								; return
	rtl
.done:								; first player
	lda.w mesarea					; first player
	sta.b d0
	lda.b d1
	cmp.w #$0001					; only one player
	beq .chk
	lda.b d1						; slots left
	bne .n1
	jsl.l .chk						; check the first
	bra .two
.n1:								; any penalty time left?
	lda.b d1
	cmp.w #$FFFF					; none left
	bne .rtl
.two:								; second player
	lda.w mesarea+2					; second player
	sta.b d0
.chk:								;release player d0 when his time is <= 5 (RemovePlayerFromList)
	lda.b a2						; team
	beq .noa23
	lda.w #$0034					; away team offset
.noa23:								; index the penalty entry
	clc
	adc.b d0
	tay
	lda.w tmpdst,y					; state
	sec
	sbc.w #$0005					; minus 5
	beq .le5						; time up
	bmi .neg
	bvs .le5
	bra .rtl
.neg:								; signed compare: overflow flag corrects the sign
	bvs .rtl
.le5:								; time up: release him
	lda.w tmpdst,y					; state
	bne .rtl2						; time left
	jsl.l releasepl					; release him
.rtl2:								; return
	rtl
.coinpen:							; one second less
	dec a							; one second less
	sta.w tmpdst,y
	bit.w #$0800					; coincidental time over
	bne .coindone					; not yet
	jmp.w .next						; next
.coindone:							; second part over?
	bit.w #$1000					; second part over
	bne .clr
	lda.w #$1000					; state
	sta.w tmpdst,y
	jmp.w RemovePlayerFromList		; remove from the list
.clr:								; penalty over: clear the state and remove the player
	lda.w #$0000
	sta.w tmpdst,y					; clear the state
	jmp.w RemovePlayerFromList		; remove from the list
