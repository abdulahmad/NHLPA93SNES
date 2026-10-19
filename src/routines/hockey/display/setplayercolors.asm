setplayercolors:					;Set both teams' colors and send the palette
	stz.w ffoframe+6				; pad 3 frame = 0
	stz.w colorflag1				; no color change pending (team 1)
	stz.w colorflag2				; (team 2)
	jsl.l setplayercolors_palbuffer	; convert the colors
	lda.w #DMA_CGRAM				; whole CGRAM from palbuffer
	sta.w DMAP7						; DMA to CGRAM
	lda.w #palbuffer
	sta.w A1T7L						; source palbuffer
	lda.w #$0200
	sta.w DAS7L						; $200 bytes
	sep #$20						; 8-bit A
	stz.w CGADD						; CGRAM address 0
	lda.b #palbuffer>>16
	sta.w A1B7
	lda.b #MDMAEN_CH7
	sta.w MDMAEN					; go
	rep #$30						; 16-bit registers
	rtl
