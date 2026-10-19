ClampNibble:						;Clamp A to 0-15
	bit.w #$0080					; negative: 0
	beq .hi							; non-negative: continue
	lda.w #$0000					; negative becomes 0
.hi:
	cmp.w #$000F					; already 0-14: done
	bcc .x
	lda.w #$000F					; cap at 15
.x:
	rtl
