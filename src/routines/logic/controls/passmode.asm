passmode:							;Pass mode: a pad direction sets the pass direction and passes; releasing
									;the button passes too
	lda.b d2						; button released
	bit.w #$8000					; yes: pass
	bne dopass
	lda.b d0						; direction
	bit.w #$0008					; bit 3 already set: leave
	bne .rtl
	and.w #$0007					; direction 0-7
	sta.w passdir					; pass direction
	ora.w #$0008					; set bit 3
	sta.b d0
	bra dopass						; pass
.rtl:								; return
	rtl
