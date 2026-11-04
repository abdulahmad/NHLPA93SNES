PauseResume:						;Pause menu Resume Game: A or Start leaves
	lda.b d1
	bit.w #sbut|cbut
	bne PauseLeave
	jmp.w Pausemode_menu_gj
