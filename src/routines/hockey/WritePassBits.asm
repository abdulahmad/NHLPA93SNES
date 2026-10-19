WritePassBits:						;Turn the playoff state into the password bits, with a checksum
	jsl.l ClrPassBits				; clear the password bits
	stz.b d7						; checksum sum = 0
	lda.w postarts					;PushBits ranges: postarts 32, bosgames 8, gamelevel 4, potreeteam 16,
									;pojoy 4, WinBits $4000
	sta.b d0						; postarts
	lda.w #32						; range 32
	sta.b d1
	jsl.l .pb
	lda.b bosgames					; bosgames
	sta.b d0
	lda.w #8						; range 8
	sta.b d1
	jsl.l .pb
	lda.w gamelevel					; gamelevel
	sta.b d0
	lda.w #4						; range 4
	sta.b d1
	jsl.l .pb
	lda.w potreeteam				; potreeteam
	sta.b d0
	lda.w #16						; range 16
	sta.b d1
	jsl.l .pb
	lda.w pojoy						; pojoy
	sta.b d0
	lda.w #4						; range 4
	sta.b d1
	jsl.l .pb
	lda.w WinBits					; WinBits
	sta.b d0
	lda.w #$4000					; range 2^14
	sta.b d1
	jsl.l .pb
	lda.w #5						; series values have range 5
	sta.b d1
	lda.w #7						; 8 series
	sta.b d2
	stz.b a1						; series offset
.0:									;the 8 series scores, range 5
	ldy.b a1
	lda.w gspotwins,y				; gspotwins
	sta.b d0
	jsl.l .pb
	ldy.b a1
	lda.w gspobwins,y				; gspobwins
	sta.b d0
	jsl.l .pb
	inc.b a1						; next series
	inc.b a1
	dec.b d2
	bpl .0
	lda.b d7						; checksum
	and.w #$01FF					; modulo 512
	sta.b d0
	lda.w #512						; range 512
	sta.b d1
	jsl.l PushBits					; push it
	rtl
.pb:								;d7 += d0, then PushBits
	lda.b d7						; add the value to the checksum
	clc
	adc.b d0
	sta.b d7
	jml.l PushBits					; push the bits
