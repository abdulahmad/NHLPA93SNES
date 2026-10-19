ReadPassBits:						;Turn the password bits back into the playoff state; a bad checksum marks
									;the password invalid
	lda.w #512						; checksum first (range 512)
	sta.b d0
	jsl.l SuperDiv					; take it from the password bits
	lda.b d0
	pha								; keep it for the end
	stz.b d7						; running sum of the values
	lda.w #7						; 8 series
	sta.b d2
	lda.w #14						; series index offset
	sta.b a1
.0:									;the 8 series scores, range 5
	ldy.b a1
	lda.w gsflags,y					; gsftf off
	and.w #~gsfso&$FFFF
	sta.w gsflags,y
	lda.w #5						; range 5 wins
	sta.b d0
	jsl.l .sd						; read one value
	lda.b d0
	ldy.b a1
	sta.w gspobwins,y				; gspobwins
	cmp.w #4						; 4 wins: gsftf (series over)
	bne .nsf0
	lda.w gsflags,y
	ora.w #gsfso					; series over
	sta.w gsflags,y
.nsf0:
	lda.w #5						; range 5 wins
	sta.b d0
	jsl.l .sd
	ldy.b a1
	lda.b d0
	sta.w gspotwins,y				; gspotwins
	cmp.w #4						; 4 wins?
	bne .nsf1
	lda.w gsflags,y
	ora.w #gsfso					; series over
	sta.w gsflags,y
.nsf1:
	dec.b a1						; next series
	dec.b a1
	dec.b d2
	bpl .0
	lda.w #$4000					; range 2^14
	sta.b d0
	jsl.l .sd						; read the win bits
	lda.b d0
	sta.w WinBits					; WinBits
	lda.w #4						; range 4
	sta.b d0
	jsl.l .sd
	lda.b d0
	sta.w pojoy						; pojoy
	lda.w #16						; range 16
	sta.b d0
	jsl.l .sd
	lda.b d0
	sta.w potreeteam				; potreeteam
	lda.w #4						; range 4
	sta.b d0
	jsl.l .sd
	lda.b d0
	sta.w gamelevel					; game level
	lda.w #8						; range 8
	sta.b d0
	jsl.l .sd
	lda.b d0
	sta.b bosgames					; bos games
	lda.w #32						; range 32
	sta.b d0
	jsl.l .sd
	lda.b d0
	sta.w postarts					; playoff starts
	lda.b d7						; checksum so far
	and.w #$01FF					; modulo 512
	sta.b tmp0
	pla								; the checksum from the password
	cmp.b tmp0						; compare
	beq .rtl
	lda.w #$FFFF					; bad password
	sta.w postarts					; mark it invalid
.rtl:								; return
	rtl
.sd:								;d0 = passbits mod d0 (SuperDiv), added to the checksum d7
	jsl.l SuperDiv					; read d0 values from the bits
	lda.b d7						; add to the checksum
	clc
	adc.b d0
	sta.b d7
	rtl
