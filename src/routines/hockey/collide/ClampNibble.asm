ClampNibble:						;Clamp A to 0-15
	bit.w #$0080					; negative: 0
	beq .hi							; non-negative: continue
	lda.w #$0000					; negative becomes 0
.hi:								; above 15: clamp to 15
	cmp.w #$000F					; already 0-14: done
	bcc .x
	lda.w #$000F					; cap at 15
.x:									; return
	rtl
