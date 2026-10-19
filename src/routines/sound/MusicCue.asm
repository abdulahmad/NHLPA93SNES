MusicCue:							;Play music cue A: the sound queue is cleared to just this command
	pha								; keep the cue
	lda.w #$0001
	sta.b sndlock					; lock the queue
	pla
	sta.b sndqueue					; queue = the cue
	stz.b sndqout					; queue out = 0
	lda.w #$0002
	sta.b sndqin					; queue in = 2
	stz.b sndlock					; unlock
	rtl
