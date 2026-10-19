sndqreset:							;Empty the sound command queue and stop the music cue
	lda.w #$0001					; sndlock while the queue is reset; cuetimer = 0
	sta.b sndlock					; lock the queue
	stz.w cursong					; no current song
	stz.w cuetimer					; cue timer 0
	stz.b sndqueue					; empty the queue
	stz.b sndqout
	lda.w #$0002					; queue in = 2
	sta.b sndqin
	stz.b sndlock					; unlock
	rtl
