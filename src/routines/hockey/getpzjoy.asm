getpzjoy:							;Read the pad of the controller that paused
	lda.w sflags
	bit.w #sfpj						; pause joystick flag
	beq .p1							; controller 1 paused
	jml.l ReadJoy2					; read pad 2
.p1:
	jml.l ReadJoy1					; read pad 1
