assnothing:							;A computer player stands still
	lda.w pflags,x
	bit.w #pfjoycon					; human controlled: leave
	bne .rtl
	lda.w #$0008					; direction 8 = no direction
	sta.b d0
	jmp.w doplayeracc				; accelerate that way (stand still)
.rtl:								; return
	rtl
