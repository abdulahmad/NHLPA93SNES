; The 93S sound CPU driver: the SPC700 program of the boot upload (block 1), $0400-$0EA4 in sound RAM,
; followed in the upload by the songs and sound effect programs (bootsound.asm). Assembled with asar in
; arch spc700 at base SPCDRIVER from bootsound.asm; tools/build.js checks the bytes against
; Extracted/Sound/driver.spc700.
;
; What it does: the main CPU writes a cue to port 0 and a counter to port 1. Cues 1-9 start a song
; (CueTable -> an order list of patterns, each 8 voice command streams: notes $80-$C7, tie $C8, rest $C9,
; percussion $CA-$DF, commands $E0-$FA through CommandTable, length bytes $01-$7F). Cues $80 and up
; start a sound effect (sfx_table) when the counter changes; $F8 takes a new upload. Timer 0 paces
; everything: effects every 8 ticks, the music by the tempo.
;
; Names are descriptive, from what the code does; "unclear" marks what is not understood. Direct page
; bytes without a name are not identified; per voice state lives at $0200-$03BF indexed by voice * 2.

; sound CPU I/O registers
SPC_CONTROL		=	$F1
SPC_DSPADDR		=	$F2
SPC_DSPDATA		=	$F3
SPC_PORT0		=	$F4
SPC_PORT1		=	$F5
SPC_PORT2		=	$F6
SPC_PORT3		=	$F7
SPC_T0TARGET	=	$FA
SPC_T0OUT		=	$FD

; direct page
port_in			=	$00				; ports 0-1 as last read (stable)
port_out		=	$04				; sent on ports 2-3
port_in_last	=	$08				; ports 0-1 at the previous music tick
sfx_voices		=	$1A				; voices held by sound effects (the music leaves them alone)
order_ptr		=	$1C				; order list pointer
order_loop		=	$1E				; order list loop count
key_on			=	$2F				; DSP KON shadow
key_off			=	$30				; DSP KOF shadow
voice_bit		=	$31				; bit of the voice being processed
voice_x			=	$32				; its index (voice * 2)
dsp_flg			=	$33				; DSP FLG shadow
noise_on		=	$34				; DSP NON shadow
echo_on			=	$35				; DSP EON shadow
pitch_mod		=	$36				; DSP PMON shadow
echo_feedback	=	$39				; DSP EFB shadow
global_transpose =	$3A
tempo			=	$3C				; 16 bits, high byte used
master_volume	=	$42				; 16 bits, high byte used
percussion_base	=	$49				; first instrument of the percussion notes
echo_volume_l	=	$4A				; 16 bits, high byte to DSP EVOLL
echo_volume_r	=	$4C				; 16 bits, high byte to DSP EVOLR

function spcaddr(x) = x-SPCDriver+SPCDRIVER	; sound RAM address of a label in the upload

; Start (the boot upload jumps here): direct page 0, stack at $01CF, clear $00-$EF and $0100-$03FF,
; echo off (delay 1), main volume L/R $60, sample directory $2C00, timer 0 every $10 ticks (2 ms)
SpcInit:
	clrp
	mov x,#$CF
	mov sp,x
	mov a,#$00
	mov x,a
.l1:
	mov (x+),a
	cmp x,#$F0
	bne .l1
	mov x,a
.l2:
	mov.w $0100+x,a
	mov.w $0200+x,a
	mov.w $0300+x,a
	inc x
	bne .l2
	inc a
	call SetEchoDelay
	set1 dsp_flg.5
	mov a,#$60
	mov y,#$0C
	call WriteDsp
	mov y,#$1C
	call WriteDsp
	mov a,#$2C
	mov y,#$5D
	call WriteDsp
	mov a,#$90
	mov.w SPC_CONTROL,a
	mov a,#$10
	mov.w SPC_T0TARGET,a
	mov.b tempo+1,a
	mov a,#$81
	mov.w SPC_CONTROL,a

; Each pass: write the DSP shadow registers (the key off / key on ones only when $37 = $38,
; unclear), step the noise generator seed $18-$19, then wait for timer 0
MainLoop:
	mov y,#$0A
.l1:
	cmp y,#$05
	beq .l2
	bcs .l3
	cmp.b $37,$38
	bne .l4
.l2:
	bbs $37.7,.l4
.l3:
	mov.w a,DspShadowRegs-1+y
	mov.w SPC_DSPADDR,a
	mov.w a,DspShadowSources-1+y
	mov x,a
	mov a,(x)
	mov.w SPC_DSPDATA,a
.l4:
	dbnz y,.l1
	mov.b key_on,y
	mov.b key_off,y
	mov.b a,$18
	eor.b a,$19
	lsr a
	lsr a
	notc
	ror.b $18
	ror.b $19

; Wait for timer 0. Every 8 ticks ($1B += $20 per tick): update the sound effects. Then
; the music: $3B += ticks * tempo; on a carry, a music tick (MusicTick) and the port exchange
MainLoop_wait_timer:
	mov.w y,SPC_T0OUT
	beq MainLoop_wait_timer
	push y
	mov a,#$20
	mul ya
	clrc
	adc.b a,$1B
	mov.b $1B,a
	bcc .l1
	call SfxUpdate
	cmp.b $37,$38
	beq .l1
	inc.b $37
.l1:
	pop y
	mov.b a,tempo+1
	mul ya
	clrc
	adc.b a,$3B
	mov.b $3B,a
	bcc MainLoop_subtick
	call MusicTick
	mov x,#$00
	call ExchangePort
	mov x,#$01
	call ExchangePort
MainLoop_next:
	bra MainLoop

; No music tick this pass: if a cue plays, update each voice between ticks (VoiceSubTick)
MainLoop_subtick:
	mov.b a,port_out
	beq MainLoop_next
	mov x,#$00
	mov.b voice_bit,#$01
.l1:
	mov.b a,$20+x
	beq .l2
	call VoiceSubTick
.l2:
	inc x
	inc x
	asl.b voice_bit
	bne .l1
	bra MainLoop_next

; DSP register written by MainLoop, from the bottom up
DspShadowRegs:
	db $2C,$3C,$0D,$4D,$6C,$4C,$5C,$3D
	db $2D,$5C

; Its direct page source
DspShadowSources:
	db $4B,$4D,$39,$35,$33,$2F,$0E,$34
	db $36,$30

; Port X (0 or 1): send port_out+X on port 2+X, then read port X until two reads agree into
; port_in+X
ExchangePort:
	mov.b a,port_out+x
	mov.w SPC_PORT2+x,a
.l1:
	mov.w a,SPC_PORT0+x
	cmp.w a,SPC_PORT0+x
	bne .l1
	mov.b port_in+x,a
	ret
StartNote_done:
	ret

; Y = a note byte of voice X: $80-$C7 a note, $C8 tie, $C9 rest, $CA-$DF a percussion note (instrument
; percussion base + Y - $CA, note $A4). Not for a voice an effect holds ($1A). Sets the pitch, the
; pitch envelope, and the key on bit
StartNote:
	cmp y,#$CA
	bcc .l1
	call CmdInstrument
	mov y,#$A4
.l1:
	cmp y,#$C8
	bcs StartNote_done
	mov.b a,sfx_voices
	and.b a,voice_bit
	bne StartNote_done
	mov a,y
	and a,#$7F
	clrc
	adc.b a,global_transpose
	clrc
	adc.w a,$0341+x
	mov.w $02B1+x,a
	mov.w a,$02D1+x
	mov.w $02B0+x,a
	mov.w a,$0311+x
	lsr a
	mov a,#$00
	ror a
	mov.w $0300+x,a
	mov a,#$00
	mov.b $95+x,a
	mov.w $0066+x,a
	mov.w $0330+x,a
	mov.b $A5+x,a
	or.b $48,voice_bit
	or.b key_on,voice_bit
	mov.w a,$02E0+x
	mov.b $85+x,a
	beq .l3
	mov.w a,$02E1+x
	mov.b $86+x,a
	mov.w a,$02F0+x
	bne .l2
	mov.w a,$02B1+x
	setc
	sbc.w a,$02F1+x
	mov.w $02B1+x,a
.l2:
	mov.w a,$02F1+x
	clrc
	adc.w a,$02B1+x
	call SetPitchSlideTarget
.l3:
	call GetVoicePitch

; Pitch $10-$11 (note, fraction) of voice X -> DSP pitch registers: the pitch table entry
; interpolated, octave shift, times the instrument pitch multiplier ($0220-$0221)
WriteVoicePitch:
	push x
	mov.b a,$11
	asl a
	mov y,#$00
	mov x,#$18
	div ya,x
	mov x,a
	mov.w a,PitchTable+1+y
	mov.b $15,a
	mov.w a,PitchTable+y
	mov.b $14,a
	mov.w a,PitchTable+3+y
	push a
	mov.w a,PitchTable+2+y
	pop y
	subw ya,$14
	mov.b y,$10
	mul ya
	mov a,y
	mov y,#$00
	addw ya,$14
	mov.b $15,y
	asl a
	rol.b $15
	mov.b $14,a
	bra .l2
.l1:
	lsr.b $15
	ror a
	inc x
.l2:
	cmp x,#$06
	bne .l1
	mov.b $14,a
	pop x
	mov.w a,$0220+x
	mov.b y,$15
	mul ya
	movw $16,ya
	mov.w a,$0220+x
	mov.b y,$14
	mul ya
	push y
	mov.w a,$0221+x
	mov.b y,$14
	mul ya
	addw ya,$16
	movw $16,ya
	mov.w a,$0221+x
	mov.b y,$15
	mul ya
	mov y,a
	pop a
	addw ya,$16
	movw $16,ya
	mov a,x
	xcn a
	lsr a
	or a,#$02
	mov y,a
	mov.b a,$16
	call WriteVoiceDsp
	inc y
	mov.b a,$17

; A -> DSP register Y, unless voice bit $31 is held by a sound effect ($1A)
WriteVoiceDsp:
	push a
	mov.b a,voice_bit
	and.b a,sfx_voices
	pop a
	bne WriteDsp_done

; A -> DSP register Y
WriteDsp:
	mov.w SPC_DSPADDR,y
	mov.w SPC_DSPDATA,a
WriteDsp_done:
	ret

; DSP pitch of the 13 semitones of the base octave
PitchTable:
	dw $085F,$08DE,$0965,$09F4,$0A8C,$0B2C,$0BD6,$0C8B,$0D4A,$0E14,$0EEA,$0FCD,$10BE

; YA = the next word of the order list at $1C; $1C += 2
ReadOrderWord:
	mov y,#$00
	mov.b a,(order_ptr)+y
	incw order_ptr
	push a
	mov.b a,(order_ptr)+y
	incw order_ptr
	mov y,a
	pop a
	ret

; Port 0 = $80-$FF: $F8 = take a new upload (ReceiveUpload); otherwise, when port 1 (the counter)
; changed, start sound effect port0 & $7F and echo port 0/1 on ports 2/3
PortCommandHigh:
	cmp a,#$F8
	bne .l1
	jmp ReceiveUpload
.l1:
	mov.b a,port_in+1
	cmp.b a,port_in_last+1
	beq .l2
	mov.b port_in_last+1,a
	mov.b port_out+1,a
	mov.b a,port_in
	mov.b port_out,a
	and a,#$7F
	call StartSfx
.l2:
	ret

; A = a music cue (0 = stop): order list pointer from CueTable, two ticks of set up, effect state
; reset, key off the voices no effect holds
StartCue:
	mov.b port_out,a
	asl a
	beq .l1
	mov x,a
	mov.w a,CueTable+1+x
	mov y,a
	mov.w a,CueTable+x
	movw order_ptr,ya
	mov.b $0C,#$02
.l1:
	call ClearSfx
	mov.b a,sfx_voices
	eor a,#$FF
	tset key_off,a
	ret

; Set up all 8 voices for a new cue: volume $FF, pan $0A, instrument 0, transpose, effects off;
; global transpose 0, master volume $C0, tempo $20
InitVoices:
	mov x,#$0E
	mov.b voice_bit,#$80
.l1:
	mov a,#$FF
	mov.w $0251+x,a
	mov a,#$0A
	call CmdPan
	mov.w $0211+x,a
	mov.w $02D1+x,a
	mov.w $0341+x,a
	mov.w $02E0+x,a
	mov.b $96+x,a
	mov.b $A6+x,a
	mov.w $03A1+x,a
	dec x
	dec x
	lsr.b voice_bit
	bne .l1
	mov.b $44,a
	mov.b $52,a
	mov.b $3E,a
	mov.b global_transpose,a
	mov.b order_loop,a
	mov.b percussion_base,a
	mov.b master_volume+1,#$C0
	mov.b tempo+1,#$20
InitVoices_done:
	ret

; One music tick: read port 0 (a new cue or a command), then step the order list and each voice
MusicTick:
	mov.b y,port_in_last
	mov.b a,port_in
	mov.b port_in_last,a
	bmi PortCommandHigh
	cmp.b y,port_in
	bne StartCue
	mov.b a,port_out
	beq InitVoices_done
	mov.b a,$0C
	beq MusicTick_voices
	dbnz $0C,InitVoices

; Next order list entry: a pattern (8 stream pointers), $00xx = loop count then target, 0 = end
MusicTick_next_pattern:
	call ReadOrderWord
	bne .l2
	mov y,a
	beq StartCue
	dec.b order_loop
	bpl .l1
	mov.b order_loop,a
.l1:
	call ReadOrderWord
	mov.b x,order_loop
	beq MusicTick_next_pattern
	movw order_ptr,ya
	bra MusicTick_next_pattern
.l2:
	movw $16,ya
	mov y,#$0F
.l3:
	mov.b a,($16)+y
	mov.w $001F+y,a
	dec y
	bpl .l3
	mov x,#$00
	mov.b voice_bit,#$01
.l4:
	mov.b a,$20+x
	beq .l5
	mov.w a,$0211+x
	bne .l5
	mov a,#$00
	call CmdInstrument
.l5:
	mov a,#$00
	mov.b $65+x,a
	mov.b $75+x,a
	mov.b $76+x,a
	inc a
	mov.b $55+x,a
	inc x
	inc x
	asl.b voice_bit
	bne .l4

; Each voice with a stream: count down its note; at 0 read commands and the next note
MusicTick_voices:
	mov x,#$00
	mov.b $48,x
	mov.b voice_bit,#$01
.l1:
	mov.b voice_x,x
	mov.b a,$20+x
	beq .l9
	dec.b $55+x
	bne .l7
.l2:
	call ReadStreamByte
	bne .l3
	mov.b a,$65+x
	beq MusicTick_next_pattern
	call RestartSub
	dec.b $65+x
	bne .l2
	mov.w a,$0230+x
	mov.b $1F+x,a
	mov.w a,$0231+x
	mov.b $20+x,a
	bra .l2
.l3:
	bmi .l4
	mov.w $0200+x,a
	call ReadStreamByte
	bmi .l4
	push a
	xcn a
	and a,#$07
	mov y,a
	mov.w a,NoteLengthTable+y
	mov.w $0201+x,a
	pop a
	and a,#$0F
	mov y,a
	mov.w a,VelocityTable+y
	mov.w $0210+x,a
	bra .l2
.l4:
	cmp a,#$E0
	bcc .l5
	call DispatchCommand
	bra .l2
.l5:
	call StartNote
	mov.w a,$0200+x
	mov.b $55+x,a
	mov y,a
	mov.w a,$0201+x
	mul ya
	mov a,y
	bne .l6
	inc a
.l6:
	mov.b $56+x,a
	bra .l8
.l7:
	call CheckNoteEnd
.l8:
	call CheckPitchSlide
.l9:
	inc x
	inc x
	asl.b voice_bit
	bne .l1
	mov.b a,$3E
	beq .l11
	movw ya,$40
	addw ya,tempo
	dbnz $3E,.l10
	movw ya,$3E
.l10:
	movw tempo,ya
.l11:
	mov.b a,$52
	beq .l13
	movw ya,$4E
	addw ya,echo_volume_l
	movw echo_volume_l,ya
	movw ya,$50
	addw ya,echo_volume_r
	dbnz $52,.l12
	movw ya,$52
	movw echo_volume_l,ya
	mov.b y,$54
.l12:
	movw echo_volume_r,ya
.l13:
	mov.b a,$44
	beq .l15
	movw ya,$46
	addw ya,master_volume
	dbnz $44,.l14
	movw ya,$44
.l14:
	movw master_volume,ya
	mov.b $48,#$FF
.l15:
	mov x,#$00
	mov.b voice_bit,#$01
.l16:
	mov.b a,$20+x
	beq .l17
	call UpdateVoiceFades
.l17:
	inc x
	inc x
	asl.b voice_bit
	bne .l16
	ret

; If the next stream byte of voice X is $F9 (pitch slide), take its delay, length and target now
CheckPitchSlide:
	mov.b a,$85+x
	bne SetPitchSlideTarget_done
	mov.b a,($1F+x)
	cmp a,#$F9
	bne SetPitchSlideTarget_done
	call SkipStreamByte
	call ReadStreamByte

; Command $F9: pitch slide (delay, length, target note)
CmdPitchSlide:
	mov.b $86+x,a
	call ReadStreamByte
	mov.b $85+x,a
	call ReadStreamByte
	clrc
	adc.b a,global_transpose
	adc.w a,$0341+x

; A = the target note: per tick step of the slide ($02C0-$02C1)
SetPitchSlideTarget:
	and a,#$7F
	mov.w $02D0+x,a
	setc
	sbc.w a,$02B1+x
	mov.b y,$85+x
	push y
	pop x
	call CalcFadeStep
	mov.w $02C0+x,a
	mov a,y
	mov.w $02C1+x,a
SetPitchSlideTarget_done:
	ret

; $10-$11 = the pitch (fraction, note) of voice X
GetVoicePitch:
	mov.w a,$02B1+x
	mov.b $11,a
	mov.w a,$02B0+x
	mov.b $10,a
	ret

; Handlers of commands $E0-$FA
CommandTable:
	dw CmdInstrument,CmdPan,CmdPanFade,CmdVibrato,CmdVibratoOff,CmdMasterVolume,CmdMasterVolumeFade,CmdTempo,CmdTempoFade,CmdGlobalTranspose,CmdTranspose,CmdTremolo,CmdTremoloOff,CmdVolume,CmdVolumeFade,CmdCallSub,CmdVibratoFade,CmdPitchEnvelopeTo,CmdPitchEnvelopeFrom,CmdPitchEnvelopeOff,CmdTuning,CmdEchoOn,CmdEchoOff,CmdEchoParams,CmdEchoVolumeFade,CmdPitchSlide,CmdPercussionBase

; Parameter bytes of commands $E0-$FA
CommandLengths:
	db $01,$01,$02,$03,$00,$01,$02,$01
	db $02,$01,$01,$03,$00,$01,$02,$03
	db $01,$03,$03,$00,$01,$03,$00,$03
	db $03,$03,$01

; A = a command byte $E0-$FA: push its handler (CommandTable), and read its first parameter
DispatchCommand:
	asl a
	mov y,a
	mov.w a,CommandTable-$BF+y
	push a
	mov.w a,CommandTable-$C0+y
	push a
	mov a,y
	lsr a
	mov y,a
	mov.w a,CommandLengths-$60+y
	beq SkipStreamByte_done

; A = Y = the next byte of voice X's stream; pointer += 1
ReadStreamByte:
	mov.b a,($1F+x)
SkipStreamByte:
	inc.b $1F+x
	bne SkipStreamByte_done
	inc.b $20+x
SkipStreamByte_done:
	mov y,a
	ret

; Command $E0 (and percussion notes): instrument A: DSP SRCN, ADSR1, ADSR2, GAIN of voice X from
; the instrument table at $2B00 (6 bytes each; bit 7 of the sample number = noise), then the pitch
; multiplier
CmdInstrument:
	mov.w $0211+x,a
	mov y,a
	bpl .l1
	setc
	sbc a,#$CA
	clrc
	adc.b a,percussion_base
.l1:
	mov y,#$06
	mul ya
	movw $14,ya
	clrc
	adc.b $14,#$00
	adc.b $15,#$2B
	mov.b a,sfx_voices
	and.b a,voice_bit
	bne .l5
	push x
	mov a,x
	xcn a
	lsr a
	or a,#$04
	mov x,a
	mov y,#$00
	mov.b a,($14)+y
	bpl .l2
	and a,#$1F
	and.b dsp_flg,#$20
	tset dsp_flg,a
	or.b noise_on,voice_bit
	mov a,y
	bra .l4
.l2:
	mov.b a,voice_bit
	tclr noise_on,a
.l3:
	mov.b a,($14)+y
.l4:
	mov.w SPC_DSPADDR,x
	mov.w SPC_DSPDATA,a
	inc x
	inc y
	cmp y,#$04
	bne .l3
	pop x
	mov.b a,($14)+y
	mov.w $0221+x,a
	inc y
	mov.b a,($14)+y
	mov.w $0220+x,a
.l5:
	ret

; Command $E1: pan A (bits 0-4; bits 6-7 kept in $02A1, unclear)
CmdPan:
	mov.w $02A1+x,a
	and a,#$1F
	mov.w $0281+x,a
	mov a,#$00
	mov.w $0280+x,a
	ret

; Command $E2: pan fade (length, target)
CmdPanFade:
	mov.b $76+x,a
	push a
	call ReadStreamByte
	mov.w $02A0+x,a
	setc
	sbc.w a,$0281+x
	pop x
	call CalcFadeStep
	mov.w $0290+x,a
	mov a,y
	mov.w $0291+x,a
	ret

; Command $E3: vibrato (delay, rate, depth)
CmdVibrato:
	mov.w $0310+x,a
	call ReadStreamByte
	mov.w $0301+x,a
	call ReadStreamByte

; Command $E4: vibrato off
CmdVibratoOff:
	mov.b $96+x,a
	mov.w $0321+x,a
	mov a,#$00
	mov.w $0311+x,a
	ret

; Command $F0: vibrato depth fade (length)
CmdVibratoFade:
	mov.w $0311+x,a
	push a
	mov y,#$00
	mov.b a,$96+x
	pop x
	div ya,x
	mov.b x,voice_x
	mov.w $0320+x,a
	ret

; Command $E5: master volume
CmdMasterVolume:
	mov a,#$00
	movw master_volume,ya
	ret

; Command $E6: master volume fade (length, target)
CmdMasterVolumeFade:
	mov.b $44,a
	call ReadStreamByte
	mov.b $45,a
	setc
	sbc.b a,master_volume+1
	mov.b x,$44
	call CalcFadeStep
	movw $46,ya
	ret

; Command $E7: tempo
CmdTempo:
	mov a,#$00
	movw tempo,ya
	ret

; Command $E8: tempo fade (length, target)
CmdTempoFade:
	mov.b $3E,a
	call ReadStreamByte
	mov.b $3F,a
	setc
	sbc.b a,tempo+1
	mov.b x,$3E
	call CalcFadeStep
	movw $40,ya
	ret

; Command $E9: transpose of every voice
CmdGlobalTranspose:
	mov.b global_transpose,a
	ret

; Command $EA: transpose of voice X
CmdTranspose:
	mov.w $0341+x,a
	ret

; Command $EB: tremolo (delay, rate, depth)
CmdTremolo:
	mov.w $0340+x,a
	call ReadStreamByte
	mov.w $0331+x,a
	call ReadStreamByte

; Command $EC: tremolo off
CmdTremoloOff:
	mov.b $A6+x,a
	ret

; Command $F1: pitch envelope (delay, length, semitones) towards the note
CmdPitchEnvelopeTo:
	mov a,#$01
	bra CmdPitchEnvelope_set

; Command $F2: pitch envelope (delay, length, semitones) away from the note
CmdPitchEnvelopeFrom:
	mov a,#$00
CmdPitchEnvelope_set:
	mov.w $02F0+x,a
	mov a,y
	mov.w $02E1+x,a
	call ReadStreamByte
	mov.w $02E0+x,a
	call ReadStreamByte
	mov.w $02F1+x,a
	ret

; Command $F3: pitch envelope off
CmdPitchEnvelopeOff:
	mov.w $02E0+x,a
	ret

; Command $ED: volume of voice X
CmdVolume:
	mov.w $0251+x,a
	mov a,#$00
	mov.w $0250+x,a
	ret

; Command $EE: volume fade (length, target)
CmdVolumeFade:
	mov.b $75+x,a
	push a
	call ReadStreamByte
	mov.w $0270+x,a
	setc
	sbc.w a,$0251+x
	pop x
	call CalcFadeStep
	mov.w $0260+x,a
	mov a,y
	mov.w $0261+x,a
	ret

; Command $FA: first instrument of the percussion notes
CmdPercussionBase:
	mov.b percussion_base,a
	ret

; Command $F4: fine tuning of voice X
CmdTuning:
	mov.w $02D1+x,a
	ret

; Command $EF: call a stream subroutine (address, count); the return is the byte after it
CmdCallSub:
	mov.w $0240+x,a
	call ReadStreamByte
	mov.w $0241+x,a
	call ReadStreamByte
	mov.b $65+x,a
	mov.b a,$1F+x
	mov.w $0230+x,a
	mov.b a,$20+x
	mov.w $0231+x,a

; Voice X's stream pointer = the start of its subroutine
RestartSub:
	mov.w a,$0240+x
	mov.b $1F+x,a
	mov.w a,$0241+x
	mov.b $20+x,a
	ret

; Command $F5: echo on: voices (EON), echo volume left, right
CmdEchoOn:
	mov.b echo_on,a
	call ReadStreamByte
	mov a,#$00
	movw echo_volume_l,ya
	call ReadStreamByte
	mov a,#$00
	movw echo_volume_r,ya
	clr1 dsp_flg.5
	ret

; Command $F8: echo volume fade (length, left, right)
CmdEchoVolumeFade:
	mov.b $52,a
	call ReadStreamByte
	mov.b $53,a
	setc
	sbc.b a,echo_volume_l+1
	mov.b x,$52
	call CalcFadeStep
	movw $4E,ya
	call ReadStreamByte
	mov.b $54,a
	setc
	sbc.b a,echo_volume_r+1
	mov.b x,$52
	call CalcFadeStep
	movw $50,ya
	ret

; Command $F6: echo off (echo volume 0, echo writes off)
CmdEchoOff:
	movw echo_volume_l,ya
	movw echo_volume_r,ya
	set1 dsp_flg.5
	ret

; Command $F7: echo delay, feedback, filter set (EchoFilters)
CmdEchoParams:
	call SetEchoDelay
	call ReadStreamByte
	mov.b echo_feedback,a
	call ReadStreamByte
	mov y,#$08
	mul ya
	mov x,a
	mov y,#$0F
.l1:
	mov.w a,EchoFilters+x
	call WriteDsp
	inc x
	mov a,y
	clrc
	adc a,#$10
	mov y,a
	bpl .l1
	mov.b x,voice_x
	ret

; A = the echo delay (EDL): if it changed, echo off, wait out the old delay (unclear), then the new
; delay and the echo buffer address (ESA = -(A * 8) - 1 pages from the top)
SetEchoDelay:
	mov.b $38,a
	mov y,#$7D
	mov.w SPC_DSPADDR,y
	mov.w a,SPC_DSPDATA
	cmp.b a,$38
	beq .l3
	and a,#$0F
	eor a,#$FF
	bbc $37.7,.l1
	clrc
	adc.b a,$37
.l1:
	mov.b $37,a
	mov y,#$04
.l2:
	mov.w a,DspShadowRegs-1+y
	mov.w SPC_DSPADDR,a
	mov a,#$00
	mov.w SPC_DSPDATA,a
	dbnz y,.l2
	mov.b a,dsp_flg
	or a,#$20
	mov y,#$6C
	call WriteDsp
	mov.b a,$38
	mov y,#$7D
	call WriteDsp
.l3:
	asl a
	asl a
	asl a
	eor a,#$FF
	setc
	adc a,#$FF
	mov y,#$6D
	jmp WriteDsp

; YA = A (signed difference) / X: the per tick step of a fade (16 bits)
CalcFadeStep:
	notc
	ror.b $12
	bpl .l1
	eor a,#$FF
	inc a
.l1:
	mov y,#$00
	div ya,x
	push a
	mov a,#$00
	div ya,x
	pop y
	mov.b x,voice_x

; If bit 7 of $12: YA = -YA
NegateIfMinus:
	bbc $12.7,.l1
	movw $14,ya
	movw ya,$0E
	subw ya,$14
.l1:
	ret

; Per tick, voice X: volume fade, tremolo, pan fade; then the DSP volume if anything changed
UpdateVoiceFades:
	mov.b a,$75+x
	beq .l1
	mov a,#$50
	mov y,#$02
	dec.b $75+x
	call StepFadeMark
.l1:
	mov.b y,$A6+x
	beq .l5
	mov.w a,$0340+x
	cbne $A5+x,.l4
	or.b $48,voice_bit
	mov.w a,$0330+x
	bpl .l2
	inc y
	bne .l2
	mov a,#$80
	bra .l3
.l2:
	clrc
	adc.w a,$0331+x
.l3:
	mov.w $0330+x,a
	call CalcVolumeWithTremolo
	bra .l6
.l4:
	inc.b $A5+x
.l5:
	mov a,#$FF
	call CalcVoiceVolume
.l6:
	mov.b a,$76+x
	beq .l7
	mov a,#$80
	mov y,#$02
	dec.b $76+x
	call StepFadeMark
.l7:
	mov.b a,voice_bit
	and.b a,$48
	beq WriteVoiceVolume_done
	mov.w a,$0281+x
	mov y,a
	mov.w a,$0280+x
	movw $10,ya

; Voice X: left and right DSP volume from the pan ($10-$11) through PanTable and the volume ($0271)
WriteVoiceVolume:
	mov a,x
	xcn a
	lsr a
	mov.b $12,a
.l1:
	mov.b y,$11
	mov.w a,PanTable+1+y
	setc
	sbc.w a,PanTable+y
	mov.b y,$10
	mul ya
	mov a,y
	mov.b y,$11
	clrc
	adc.w a,PanTable+y
	mov y,a
	mov.w a,$0271+x
	mul ya
	mov.w a,$02A1+x
	asl a
	bbc $12.0,.l2
	asl a
.l2:
	mov a,y
	bcc .l3
	eor a,#$FF
	inc a
.l3:
	mov.b y,$12
	call WriteVoiceDsp
	mov y,#$14
	mov a,#$00
	subw ya,$10
	movw $10,ya
	inc.b $12
	bbc $12.1,.l1
WriteVoiceVolume_done:
	ret

; Volume curve by pan position 0-20
PanTable:
	db $00,$01,$03,$07,$0D,$15,$1E,$29
	db $34,$42,$51,$5E,$67,$6E,$73,$77
	db $7A,$7C,$7D,$7E,$7F

; Mark voice X's volume changed ($48), then StepFade
StepFadeMark:
	or.b $48,voice_bit

; Add the 16 bit step at $0200+A+$10 / $20 (unclear) to the value at $0200+A+X
StepFade:
	movw $14,ya
	movw $16,ya
	push x
	pop y
	clrc
	bne .l1
	adc.b $16,#$1F
	mov a,#$00
	mov.b ($14)+y,a
	inc y
	bra StepFadeByte_add
.l1:
	adc.b $16,#$10
	call StepFadeByte
	inc y
StepFadeByte:
	mov.b a,($14)+y
StepFadeByte_add:
	adc.b a,($16)+y
	mov.b ($14)+y,a
	ret

; Voice X: when its note is about to end, look ahead in the stream: key off unless the next
; note is a tie ($C8); then the pitch slide, vibrato
CheckNoteEnd:
	mov.b a,$56+x
	beq .l10
	dec.b $56+x
	beq .l1
	mov a,#$02
	cbne $55+x,.l10
.l1:
	mov.b a,$65+x
	mov.b $17,a
	mov.b a,$1F+x
	mov.b y,$20+x
.l2:
	movw $14,ya
	mov y,#$00
.l3:
	mov.b a,($14)+y
	beq .l6
	bmi .l5
.l4:
	inc y
	mov.b a,($14)+y
	bpl .l4
.l5:
	cmp a,#$C8
	beq .l10
	cmp a,#$EF
	beq .l8
	cmp a,#$E0
	bcc .l9
	push y
	mov y,a
	pop a
	adc.w a,CommandLengths-$E0+y
	mov y,a
	bra .l3
.l6:
	mov.b a,$17
	beq .l9
	dec.b $17
	bne .l7
	mov.w a,$0231+x
	push a
	mov.w a,$0230+x
	pop y
	bra .l2
.l7:
	mov.w a,$0241+x
	push a
	mov.w a,$0240+x
	pop y
	bra .l2
.l8:
	inc y
	mov.b a,($14)+y
	push a
	inc y
	mov.b a,($14)+y
	mov y,a
	pop a
	bra .l2
.l9:
	mov.b a,voice_bit
	mov y,#$5C
	call WriteVoiceDsp
.l10:
	clr1 $13.7
	mov.b a,$85+x
	beq .l12
	mov.b a,$86+x
	beq .l11
	dec.b $86+x
	bra .l12
.l11:
	set1 $13.7
	mov a,#$B0
	mov y,#$02
	dec.b $85+x
	call StepFade
.l12:
	call GetVoicePitch
	mov.b a,$96+x
	beq CheckNoteEnd_done
	mov.w a,$0310+x
	cbne $95+x,CheckNoteEnd_vibrato_wait
	mov.w a,$0066+x
	cmp.w a,$0311+x
	bne .l13
	mov.w a,$0321+x
	bra .l15
.l13:
	inc.b $66+x
	mov y,a
	beq .l14
	mov.b a,$96+x
.l14:
	clrc
	adc.w a,$0320+x
.l15:
	mov.b $96+x,a
	mov.w a,$0300+x
	clrc
	adc.w a,$0301+x
	mov.w $0300+x,a
CheckNoteEnd_vibrato:
	mov.b $12,a
	asl a
	asl a
	bcc .l1
	eor a,#$FF
.l1:
	mov y,a
	mov.b a,$96+x
	cmp a,#$F1
	bcc .l2
	and a,#$0F
	mul ya
	bra .l3
.l2:
	mul ya
	mov a,y
	mov y,#$00
.l3:
	call AddPitchDelta
CheckNoteEnd_pitch:
	jmp WriteVoicePitch
CheckNoteEnd_vibrato_wait:
	inc.b $95+x
CheckNoteEnd_done:
	bbs $13.7,CheckNoteEnd_pitch
	ret

; Between music ticks: interpolate voice X's tremolo, pan fade, pitch slide and vibrato by the
; fraction $3B of the tick
VoiceSubTick:
	clr1 $13.7
	mov.b a,$A6+x
	beq .l1
	mov.w a,$0340+x
	cbne $A5+x,.l1
	call CalcTremoloVolume
.l1:
	mov.w a,$0281+x
	mov y,a
	mov.w a,$0280+x
	movw $10,ya
	mov.b a,$76+x
	beq .l2
	mov.w a,$0291+x
	mov y,a
	mov.w a,$0290+x
	call AddScaledStep
.l2:
	bbc $13.7,.l3
	call WriteVoiceVolume
.l3:
	clr1 $13.7
	call GetVoicePitch
	mov.b a,$85+x
	beq .l4
	mov.b a,$86+x
	bne .l4
	mov.w a,$02C1+x
	mov y,a
	mov.w a,$02C0+x
	call AddScaledStep
.l4:
	mov.b a,$96+x
	beq CheckNoteEnd_done
	mov.w a,$0310+x
	cbne $95+x,CheckNoteEnd_done
	mov.b y,$3B
	mov.w a,$0301+x
	mul ya
	mov a,y
	clrc
	adc.w a,$0300+x
	jmp CheckNoteEnd_vibrato
AddScaledStep:
	set1 $13.7
	mov.b $12,y
	call NegateIfMinus
	push y
	mov.b y,$3B
	mul ya
	mov.b $14,y
	mov.b $15,#$00
	mov.b y,$3B
	pop a
	mul ya
	addw ya,$14

; $10-$11 += YA (negated if bit 7 of $12)
AddPitchDelta:
	call NegateIfMinus
	addw ya,$10
	movw $10,ya
	ret
CalcTremoloVolume:
	set1 $13.7
	mov.b y,$3B
	mov.w a,$0331+x
	mul ya
	mov a,y
	clrc
	adc.w a,$0330+x
CalcVolumeWithTremolo:
	asl a
	bcc .l1
	eor a,#$FF
.l1:
	mov.b y,$A6+x
	mul ya
	mov a,y
	eor a,#$FF

; A = the tremolo factor: $0271 = master volume * note velocity ($0210) * voice volume ($0251)
CalcVoiceVolume:
	mov.b y,master_volume+1
	mul ya
	mov.w a,$0210+x
	mul ya
	mov.w a,$0251+x
	mul ya
	mov a,y
	mul ya
	mov a,y
	mov.w $0271+x,a
	ret

; Command $F8: key off everything, signal $AA $BB on ports 0-1 and take a new upload in the
; boot ROM's block format (address on ports 2-3, bytes on port 1 with the count on port 0)
ReceiveUpload:
	mov a,#$FF
	mov y,#$5C
	call WriteDsp
	mov.b SPC_PORT0,#$AA
	mov.b SPC_PORT1,#$BB
.l1:
	cmp.b SPC_PORT0,#$CC
	bne .l1
	bra .l5
.l2:
	mov.b y,SPC_PORT0
	bne .l2
.l3:
	cmp.b y,SPC_PORT0
	bne .l4
	mov.b a,SPC_PORT1
	mov.b SPC_PORT0,y
	mov.b ($14)+y,a
	inc y
	bne .l3
	inc.b $15
	bra .l3
.l4:
	bpl .l3
	cmp.b y,SPC_PORT0
	bpl .l3
.l5:
	movw ya,SPC_PORT2
	movw $14,ya
	movw ya,SPC_PORT0
	mov.b SPC_PORT0,a
	mov a,y
	bne .l2
	mov a,#$31
	mov.w SPC_CONTROL,a
	ret

; Echo filter coefficient sets (8 bytes each) for CmdEchoParams
EchoFilters:
	db $7F,$00,$00,$00,$00,$00,$00,$00
	db $58,$BF,$DB,$F0,$FE,$07,$0C,$0C
	db $0C,$21,$2B,$2B,$13,$FE,$F3,$F9
	db $34,$33,$00,$D9,$E5,$01,$FC,$EB

; A = an effect number (cue & $7F): its voice from the effect table ($FF = the first free of
; voices 0-1), its program pointer; echo off, main volume $60, mark it running
StartSfx:
	mov y,a
	push a
	mov.w a,spcaddr(sfx_table)+$44+y
	mov x,a
	bpl .l1
	mov x,#$00
	mov.w a,$03A1+x
	beq .l1
	inc x
	inc x
	mov.w a,$03A1+x
	beq .l1
	mov x,#$00
.l1:
	pop a
	asl a
	mov y,a
	mov.w a,spcaddr(sfx_table)+y
	mov.w $0350+x,a
	mov.w $03B0+x,a
	mov.w a,spcaddr(sfx_table)+1+y
	mov.w $0351+x,a
	mov.w $03B1+x,a
	mov a,#$00
	mov.w $0391+x,a
	mov.w $03A0+x,a
	inc a
	call SetEchoDelay
	set1 dsp_flg.5
	mov a,#$60
	mov y,#$0C
	call WriteDsp
	mov y,#$1C
	call WriteDsp
	mov a,#$02
	mov.w $03A1+x,a
	mov a,#$00
	mov.w $02E0+x,a
	mov.b $96+x,a
	mov.b $A6+x,a
	ret

; Stop every sound effect
ClearSfx:
	mov x,#$00
	mov.b voice_bit,#$01
	mov a,#$00
.l1:
	mov.w $03A1+x,a
	inc x
	inc x
	asl.b voice_bit
	bne .l1
	ret

; Every 8 timer ticks: step each running effect program: $80 note, $81 wait, $82 pitch sweep,
; $83 end, $84 back to the start
SfxUpdate:
	mov x,#$00
	mov.b voice_bit,#$01
.l1:
	mov.w a,$0350+x
	mov.b $16,a
	mov.w a,$0351+x
	mov.b $17,a
	mov.w a,$03A1+x
	bne .l2
	jmp .l14
.l2:
	cmp a,#$01
	beq .l3
	mov.b a,voice_bit
	mov y,#$5C
	call WriteDsp
	mov a,#$01
	mov.w $03A1+x,a
.l3:
	mov.w a,$0391+x
	beq .l4
	jmp .l12
.l4:
	mov.w a,$03A0+x
	beq .l5
	jmp .l11
.l5:
	mov y,#$00
	call ReadSfxByte
	cmp a,#$80
	beq .l9
	cmp a,#$82
	beq .l7
	cmp a,#$81
	beq .l8
	cmp a,#$83
	beq .l6
	cmp a,#$84
	beq .l10
	bra .l5
.l6:
	mov.b a,voice_bit
	mov y,#$5C
	call WriteDsp
	mov a,#$00
	mov.w $03A1+x,a
	jmp .l14
.l7:
	call ReadSfxByte
	mov.w $0391+x,a
	mov.w $0390+x,a
	call ReadSfxByte
	mov.w $0370+x,a
	mov.w $0360+x,a
	call ReadSfxByte
	mov.w $0371+x,a
	mov.w $0361+x,a
	call ReadSfxByte
	mov.w $0380+x,a
	call ReadSfxByte
	mov.w $0381+x,a
	mov.b a,$16
	mov.w $0350+x,a
	mov.b a,$17
	mov.w $0351+x,a
	bra .l13
.l8:
	call ReadSfxByte
	mov.w $03A0+x,a
	jmp .l5
.l9:
	call ReadSfxByte
	call CmdInstrument
	mov y,#$00
	call ReadSfxByte
	push a
	mov a,x
	xcn a
	lsr a
	mov y,a
	pop a
	call WriteDsp
	inc y
	call WriteDsp
	or.b key_on,voice_bit
	jmp .l5
.l10:
	mov.w a,$03B0+x
	mov.w $0016,a
	mov.w a,$03B1+x
	mov.w $0017,a
	jmp .l5
.l11:
	mov.w a,$03A0+x
	dec a
	mov.w $03A0+x,a
	mov.w a,$0370+x
	mov.w $0360+x,a
	mov.w a,$0371+x
	mov.w $0361+x,a
	mov.w a,$0390+x
	mov.w $0391+x,a
	bra .l13
.l12:
	clrc
	mov.w a,$0380+x
	adc.w a,$0360+x
	mov.w $0360+x,a
	mov.w a,$0381+x
	adc.w a,$0361+x
	and a,#$3F
	mov.w $0361+x,a
	mov.w a,$0391+x
	dec a
	mov.w $0391+x,a
.l13:
	mov a,x
	xcn a
	lsr a
	or a,#$02
	mov y,a
	mov.w a,$0360+x
	call WriteDsp
	inc y
	mov.w a,$0361+x
	call WriteDsp
.l14:
	inc x
	inc x
	asl.b voice_bit
	beq .l15
	jmp .l1
.l15:
	ret

; A = the next byte of the effect program at $16
ReadSfxByte:
	mov.b a,($16)+y
	incw $16
	ret

; Note on length (of 256) by the high nibble of a length byte
NoteLengthTable:
	db $32,$65,$7F,$98,$B2,$CB,$E5,$FF

; Note velocity by the low nibble of a length byte
VelocityTable:
	db $19,$32,$4C,$65,$72,$7F,$8C,$98
	db $A5,$B2,$BF,$CB,$D8,$E5

; Order list of music cues 1-9 (entry 0 unused)
CueTable:
	dw $FCF2						; entry 0: not used (cue 0 = stop)
	dw spcaddr(fmtune_playoff_order)
	dw spcaddr(fmtune_unused2_order)
	dw spcaddr(fmtune_title_order)
	dw spcaddr(fmtune_goal_order)
	dw spcaddr(fmtune_periodstart_order)
	dw spcaddr(fmtune_lategame_order)
	dw spcaddr(fmtune_unused7_order)
	dw spcaddr(fmtune_midperiod_order)
	dw spcaddr(fmtune_unused9_order)
