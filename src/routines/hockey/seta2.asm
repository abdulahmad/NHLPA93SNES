seta2:								;a2 = the team of the controller that paused
	stz.b a2						; team 0 unless changed
	lda.w cont1team					; controller 1 team
	beq .rtl						; none: leave
	lda.w sflags
	bit.w #sfpj						; pad 2 paused
	beq .cont1						; no: controller 1
	lda.w cont2team					; controller 2 team
	bra .gotteam
.cont1:
	lda.w cont1team					; controller 1 team
.gotteam:
	cmp.w #$0001					; team 1
	beq .rtl						; a2 stays 0
	inc.b a2						; team 2: a2 = 2
	inc.b a2
.rtl:								; return
	rtl
