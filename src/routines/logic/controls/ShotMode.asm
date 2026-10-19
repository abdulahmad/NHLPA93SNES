ShotMode:							;Pad input while shooting: aim with the pad and build shot power during
									;the windup; releasing the button
		;   swings through. Shoots at the end of the animation
	lda.w SPAnum,x					; animation frame
	cmp.w #$0018					; 7*4: end of the animation
	bcs doshot						; end: shoot
	lda.b d0						; pad direction
	bit.w #$0008					; bit 3 = no direction
	bne .ss0						; none
	and.w #$0007					; 0-7
	sta.w passdir					; pass direction
.ss0:
	lda.w SPAnum,x					; animation frame
	cmp.w #$0010					; 4*4: past full windup
	bcs .rts						; full windup: leave
;wind-up: shot power grows by elapsed frames
	lda.w passspeed					; shot speed
	clc
	adc.b d7
	sta.w passspeed					; grows with time
	lda.b d2						; buttons
	bit.w #cbut						; button released
	beq .rts						; held
	lda.w #$001C					; end the windup and swing through
	sec								; swing through
	sbc.w SPAnum,x
	sta.w SPAnum,x
	cmp.w #$0018					; already past the end
	bcc .rts
	lda.w #$0018					; clamp to the end
	sta.w SPAnum,x
	bra doshot						; shoot
.rts:								; return
	rtl
