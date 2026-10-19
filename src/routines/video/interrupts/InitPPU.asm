InitPPU:							;Set all video and I/O registers to their reset
									;values, with the screen off
	sep #$20						; 8-bit A
	lda.b #INIDISP_FBLANK|$0F		; forced blank, full brightness
	sta.w INIDISP
	stz.w OBSEL						; sprite size and base
	stz.w OAMADDL					; OAM address 0
	stz.w OAMADDH
	stz.w BGMODE					; BG mode 0
	stz.w MOSAIC					; no mosaic
	stz.w BG1SC						; BG screen addresses
	stz.w BG2SC
	stz.w BG3SC
	stz.w BG4SC
	stz.w BG12NBA					; BG character addresses
	stz.w BG34NBA
	stz.w BG1HOFS					; BG scroll offsets
	stz.w BG1HOFS
	stz.w BG1VOFS
	stz.w BG1VOFS
	stz.w BG2HOFS
	stz.w BG2HOFS
	stz.w BG2VOFS
	stz.w BG2VOFS
	stz.w BG3HOFS
	stz.w BG3HOFS
	stz.w BG3VOFS
	stz.w BG3VOFS
	stz.w BG4HOFS
	stz.w BG4HOFS
	stz.w BG4VOFS
	stz.w BG4VOFS
	lda.b #VMAIN_INCHI				; VRAM increment mode
	sta.w VMAIN
	stz.w VMADDL					; VRAM address 0
	stz.w VMADDH
	stz.w M7SEL						; mode 7
	stz.w M7A
	lda.b #$01
	sta.w M7A
	stz.w M7B
	stz.w M7B
	stz.w M7C
	stz.w M7C
	stz.w M7D
	sta.w M7D
	stz.w M7X
	stz.w M7X
	stz.w M7Y
	stz.w M7Y
	stz.w CGADD						; CGRAM address 0
	stz.w W12SEL					; window settings
	stz.w W34SEL
	stz.w WOBJSEL
	stz.w WH0
	stz.w WH1
	stz.w WH2
	stz.w WH3
	stz.w WBGLOG
	stz.w WOBJLOG
	stz.w TM						; screen designation
	stz.w TS
	stz.w TMW
	stz.w TSW
	lda.b #$30						; color math
	sta.w CGWSEL
	stz.w CGADSUB
	lda.b #$E0
	sta.w COLDATA
	stz.w SETINI
	stz.w NMITIMEN					; no interrupts
	lda.b #$FF						; I/O port
	sta.w WRIO
	stz.w WRMPYA					; multiply and divide registers
	stz.w WRMPYB
	stz.w WRDIVL
	stz.w WRDIVH
	stz.w WRDIVB
	stz.w HTIMEL					; IRQ timers
	stz.w HTIMEH
	stz.w VTIMEL
	stz.w VTIMEH
	stz.w MDMAEN					; DMA channels off
	stz.w HDMAEN
	lda.b #$01						; ROM speed
	sta.w MEMSEL
	rep #$30						; 16-bit
	rtl
