asspassrec:							;Assignment: waiting for a pass. Ends when someone has the puck or the
									;wait runs out
	lda.w pfalock,x					; locked
	bne .rts						; locked
	lda.w gmclock					; clock stopped
	beq .joy						; stopped: stand still
	jml.l donothing				; stand still
.joy:								; joystick controlled?
	lda.w pflags,x					; player flags
	bit.w #pfjoycon					; joystick controlled
	beq .na
	jmp.w assexit					; joystick: the assignment is over
.na:								; new assignment?
	bit.w #pfna						; new assignment?
	beq .nna						; no
	and.w #~pfna&$FFFF				; clear pfna, set pfdoff
	ora.w #pfdoff
	sta.w pflags,x
	stz.w temp2,x					; temp2 = 8
	lda.w #$0008					; temp2 = 8
	sta.w temp2b,x
.nna:								; puck carried: assignment is over
	lda.w puckc						; puck loose: wait temp1 frames
	bpl .ex
	lda.w temp1,x					; frames left
	sec								; minus d7
	sbc.b d7
	sta.w temp1,x					; store them
	bpl .rts						; still waiting
.ex:								; deceleration back on
	lda.w pflags,x					; clear pfdoff
	and.w #~pfdoff&$FFFF
	sta.w pflags,x
	jmp.w assexit					; assignment over
.rts:								; return
	rtl
