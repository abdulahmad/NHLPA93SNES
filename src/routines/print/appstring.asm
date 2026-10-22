appstring:							;Append string [a1] to string [a3]
	lda.w #strtext					; read from the 3rd byte on (after the length)
	sta.b tmp0
	lda.b [a3]						; length of the target string
	sta.b tmp1
.loop:								; copy loop
	lda.b tmp0						; source index
	cmp.b [a1]						; end of the source string
	beq .done						; done
	tay
	lda.b [a1],y					; source byte
	ldy.b tmp1						; target index
	sta.b [a3],y					; append it
	inc.b tmp0						; next source byte
	inc.b tmp1						; next target position
	bra .loop
.done:								; new target length
	lda.b tmp1						; new target length
	sta.b [a3]
	rtl
