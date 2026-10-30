randomd0_seed:								;Step the random number seed and return a new random number
	lda.w seed						; mula = seed (32-bit)
	sta.b mula
	lda.w seed+2
	sta.b mula+2
	lda.w #$E62D					; mulb = $BB40E62D
	sta.b mulb
	lda.w #$BB40
	sta.b mulb+2
	jsl.l mulu32					; seed * mula
	adc.w #$0001					; plus 1
	sta.w seed						; new seed
	lda.b mulres+2
	adc.w #$0000					; with carry
	sta.w seed+2
	xba								; rndb2 = seed byte 3, rndb1 = seed bytes 1-2
	and.w #$00FF
	sta.w rndb2						; random byte 2
	lda.w seed+1
	sta.w rndb1						; random word 1
	clc
	rtl
