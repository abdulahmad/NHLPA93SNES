newcheck:							;Play a body check sound
	lda.w seed+1					; one random bit
	and.w #$0001					; choose between the two
	clc
	adc.w #SFXcheck					; check sound 1 or 2
	pha
	jsl.l sfx						; play it
	rtl
