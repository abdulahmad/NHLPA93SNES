linebar:							;Draw the energy bar of line d0
	jsl.l getlinee					; energy of the line
	lda.w printa					; print attributes
	pha								; keep them
	lda.w #$3000					; palette
	sta.w printa
	lda.b d0
	cmp.w #$1000					; cap
	bcc .max
	lda.w #$1000					; at $1000
.max:								; clamp the energy at $2F
	sta.b d0						; energy
	sta.b mula
	lda.w #$002F					; $2F
	sta.b mulb
	jsl.l mulu						; energy * $2F / 65536
	lda.b mulres+2					; bar length
	adc.w #$001D					; plus the first tile
	sta.w mesarea+2					; fill the text
	sta.w mesarea+3
	sta.w mesarea+4
	sta.w mesarea+5
	sta.w mesarea+6
	lda.w #mesarea					; a1 = text
	sta.b a1
	lda.w #mesarea>>16
	sta.b a1+2
	lda.b d0						; energy
	sta.b mula
	lda.w #$0054					; $54
	sta.b mulb
	jsl.l mulu						; multiply
	lda.b mulres+2					; high word
	inc a							; plus 2
	inc a
	sta.b [a1]						; string length
	jsl.l print						; print it
	pla								; restore print attributes
	sta.w printa
	rtl
