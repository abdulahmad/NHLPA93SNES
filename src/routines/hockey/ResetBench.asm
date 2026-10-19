ResetBench:							;Empty the penalty boxes and put every player on his own bench
	stz.w PBnum						; no penalty boxes
	lda.w #$0010					; home: +$10 per player
	sta.b d1
	stz.b a0						; team 0
	jsl.l .rb						; do it
	lda.w #$0001					; team 1
	sta.b d1						; step 1
	lda.w #$0002
	sta.b a0						; a0 = 2
.rb:								;team a0 (0/2), d1 = PBnum step
	lda.w #(maxros-1)*2				; (MaxRos-1)*2
	sta.b d0						; last player
.rb1:
	lda.w PBnum						; box count
	clc
	adc.b d1						; plus the step
	sta.w PBnum
	lda.b a0						; team
	beq .idx						; home
	lda.w #$0034					; away team offset $34
.idx:
	adc.b d0
	tay								; index
	lda.w tmpdst,y					; state
	bmi .nopen						; on the ice or bench
	beq .nopen						; empty
	bit.w #TMPDINJ					; TMPDINJ: stays in the box
	beq .next						; stays in the box
	and.w #$07FF					; no time left: not counted
	sta.b d2						; time left
	bne .next						; some: still in the box
	lda.w PBnum
	sec								; not counted
	sbc.b d1
	sta.w PBnum
	bra .next
.nopen:								; on the ice or bench
	lda.w PBnum						; box count
	sec
	sbc.b d1
	sta.w PBnum
	lda.w tmpdst,y					; state
	cmp.w #TMPDOUT					; TMPDOUT stays out
	beq .next						; stays out
	lda.w #TMPDBENCH				; TMPDBENCH
	sta.w tmpdst,y					; on the bench
.next:
	dec.b d0						; previous player
	dec.b d0
	bpl .rb1
	rtl
