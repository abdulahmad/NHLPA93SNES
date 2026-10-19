; ---- BootSoundUpload ----
BootSoundUpload:					;boot SPC upload: the sound driver and its sample set (sndbank 2)
	dw SPCDRIVERSIZE, SPCDRIVER		; block 1: the driver code

; ---- SPCDriver ----
SPCDriver:							;SPC700 sound program, loaded at APU $0400: the N-SPC sequencer code and
									;tables, then the songs (order lists, channel sets, command streams) and
									;the sound effect programs (steps $80 note, $81 repeat, $82 pitch sweep,
									;$83 end, $84 loop). One file per song/effect in Extracted/Sound, named
									;like the 93G fmtune_* / sfx_* command streams. The SPC700 code is not
									;disassembled.
SPCCode:							;N-SPC sequencer code, note tables and the cue pointer table ($0400-$0EA4)
	incbin "../../../Extracted/Sound/driver.spc700"
fmtune_playoff_order:				;cue 1 order list: set pointer, jump and end markers
	incbin "../../../Extracted/Sound/fmtune_playoff_cmdstream.bin":$0..$8
fmtune_title_order:					;cue 3 order list: set pointer, jump and end markers
	incbin "../../../Extracted/Sound/fmtune_title_cmdstream.bin":$0..$8
fmtune_unused2_order:				;cue 2 order list: set pointer, jump and end markers
	incbin "../../../Extracted/Sound/fmtune_unused2_cmdstream.bin":$0..$8
fmtune_goal_order:					;cue 4 order list: set pointer, jump and end markers
	incbin "../../../Extracted/Sound/fmtune_goal_cmdstream.bin":$0..$8
fmtune_periodstart_order:			;cue 5 order list: set pointer, jump and end markers
	incbin "../../../Extracted/Sound/fmtune_periodstart_cmdstream.bin":$0..$8
fmtune_lategame_order:				;cue 6 order list: set pointer, jump and end markers
	incbin "../../../Extracted/Sound/fmtune_lategame_cmdstream.bin":$0..$8
fmtune_unused7_order:				;cue 7 order list: set pointer, jump and end markers
	incbin "../../../Extracted/Sound/fmtune_unused7_cmdstream.bin":$0..$8
fmtune_midperiod_order:				;cue 8 order list: set pointer, jump and end markers
	incbin "../../../Extracted/Sound/fmtune_midperiod_cmdstream.bin":$0..$8
fmtune_unused9_order:				;cue 9 order list: set pointer, jump and end markers
	incbin "../../../Extracted/Sound/fmtune_unused9_cmdstream.bin":$0..$8
fmtune_playoff_set:					;cue 1 set: pointers to the 8 channel streams
	incbin "../../../Extracted/Sound/fmtune_playoff_cmdstream.bin":$8..$18
fmtune_title_set:					;cue 3 set: pointers to the 8 channel streams
	incbin "../../../Extracted/Sound/fmtune_title_cmdstream.bin":$8..$18
fmtune_unused2_set:					;cue 2 set: pointers to the 8 channel streams
	incbin "../../../Extracted/Sound/fmtune_unused2_cmdstream.bin":$8..$18
fmtune_goal_set:					;cue 4 set: pointers to the 8 channel streams
	incbin "../../../Extracted/Sound/fmtune_goal_cmdstream.bin":$8..$18
fmtune_periodstart_set:				;cue 5 set: pointers to the 8 channel streams
	incbin "../../../Extracted/Sound/fmtune_periodstart_cmdstream.bin":$8..$18
fmtune_lategame_set:				;cue 6 set: pointers to the 8 channel streams
	incbin "../../../Extracted/Sound/fmtune_lategame_cmdstream.bin":$8..$18
fmtune_unused7_set:					;cue 7 set: pointers to the 8 channel streams
	incbin "../../../Extracted/Sound/fmtune_unused7_cmdstream.bin":$8..$18
fmtune_midperiod_set:				;cue 8 set: pointers to the 8 channel streams
	incbin "../../../Extracted/Sound/fmtune_midperiod_cmdstream.bin":$8..$18
fmtune_unused9_set:					;cue 9 set: pointers to the 8 channel streams
	incbin "../../../Extracted/Sound/fmtune_unused9_cmdstream.bin":$8..$18
fmtune_playoff_stream:				;cue 1 channel command streams ($0F7D-$1020)
	incbin "../../../Extracted/Sound/fmtune_playoff_cmdstream.bin":$18..$BC
fmtune_unused2_stream:				;cue 2 channel command streams ($1021-$10F6)
	incbin "../../../Extracted/Sound/fmtune_unused2_cmdstream.bin":$18..$EE
fmtune_unused9_stream:				;cue 9 channel command streams ($10F7-$127E)
	incbin "../../../Extracted/Sound/fmtune_unused9_cmdstream.bin":$18..$1A0
fmtune_title_stream:				;cue 3 channel command streams ($127F-$13E0)
	incbin "../../../Extracted/Sound/fmtune_title_cmdstream.bin":$18..$17A
fmtune_goal_stream:					;cue 4 channel command streams ($13E1-$144C)
	incbin "../../../Extracted/Sound/fmtune_goal_cmdstream.bin":$18..$84
fmtune_lategame_stream:				;cue 6 channel command streams ($144D-$14B2)
	incbin "../../../Extracted/Sound/fmtune_lategame_cmdstream.bin":$18..$7E
fmtune_periodstart_stream:			;cue 5 channel command streams ($14B3-$1536)
	incbin "../../../Extracted/Sound/fmtune_periodstart_cmdstream.bin":$18..$9C
fmtune_unused7_stream:				;cue 7 channel command streams ($1537-$1623)
	incbin "../../../Extracted/Sound/fmtune_unused7_cmdstream.bin":$18..$105
fmtune_midperiod_stream:			;cue 8 channel command streams ($1624-$16B1)
	incbin "../../../Extracted/Sound/fmtune_midperiod_cmdstream.bin":$18..$A6
fmtune_title_stream2:				;cue 3 channel command streams ($16B2-$16BB)
	incbin "../../../Extracted/Sound/fmtune_title_cmdstream.bin":$17A..$184
fmtune_unused2_stream2:				;cue 2 channel command streams ($16BC-$16C1)
	incbin "../../../Extracted/Sound/fmtune_unused2_cmdstream.bin":$EE..$F4
fmtune_unused9_stream2:				;cue 9 channel command streams ($16C2-$1926)
	incbin "../../../Extracted/Sound/fmtune_unused9_cmdstream.bin":$1A0..$405
fmtune_goal_stream2:				;cue 4 channel command streams ($1927-$193D)
	incbin "../../../Extracted/Sound/fmtune_goal_cmdstream.bin":$84..$9B
fmtune_midperiod_stream2:			;cue 8 channel command streams ($193E-$1A18)
	incbin "../../../Extracted/Sound/fmtune_midperiod_cmdstream.bin":$A6..$181
fmtune_unused7_stream2:				;cue 7 channel command streams ($1A19-$1A45)
	incbin "../../../Extracted/Sound/fmtune_unused7_cmdstream.bin":$105..$132
fmtune_periodstart_stream2:			;cue 5 channel command streams ($1A46-$1A96)
	incbin "../../../Extracted/Sound/fmtune_periodstart_cmdstream.bin":$9C..$ED
fmtune_lategame_stream2:			;cue 6 channel command streams ($1A97-$1BBD)
	incbin "../../../Extracted/Sound/fmtune_lategame_cmdstream.bin":$7E..$1A5
fmtune_goal_stream3:				;cue 4 channel command streams ($1BBE-$1C45)
	incbin "../../../Extracted/Sound/fmtune_goal_cmdstream.bin":$9B..$123
fmtune_title_stream3:				;cue 3 channel command streams ($1C46-$2174)
	incbin "../../../Extracted/Sound/fmtune_title_cmdstream.bin":$184..$6B3
fmtune_playoff_stream2:				;cue 1 channel command streams ($2175-$24A1)
	incbin "../../../Extracted/Sound/fmtune_playoff_cmdstream.bin":$BC..$3E9
fmtune_unused2_stream3:				;cue 2 channel command streams ($24A2-$28BA)
	incbin "../../../Extracted/Sound/fmtune_unused2_cmdstream.bin":$F4..$50D
sfx_table:							;sound effect tables: program pointer per cue $80-$A1, voice per effect
	incbin "../../../Extracted/Sound/sfx_table.bin"
sfx_a1:								;sound effect program, cue $A1
	incbin "../../../Extracted/Sound/sfx_a1_cmdstream.bin"
sfx_siren:							;sound effect program, cue $A0
	incbin "../../../Extracted/Sound/sfx_siren_cmdstream.bin"
sfx_crowd0:							;sound effect program, cue $80
	incbin "../../../Extracted/Sound/sfx_crowd0_cmdstream.bin"
sfx_crowd1:							;sound effect program, cue $81
	incbin "../../../Extracted/Sound/sfx_crowd1_cmdstream.bin"
sfx_crowd2:							;sound effect program, cue $82
	incbin "../../../Extracted/Sound/sfx_crowd2_cmdstream.bin"
sfx_crowd3:							;sound effect program, cue $83
	incbin "../../../Extracted/Sound/sfx_crowd3_cmdstream.bin"
sfx_crowd4:							;sound effect program, cue $84
	incbin "../../../Extracted/Sound/sfx_crowd4_cmdstream.bin"
sfx_crowd5:							;sound effect program, cue $85
	incbin "../../../Extracted/Sound/sfx_crowd5_cmdstream.bin"
sfx_crowd6:							;sound effect program, cue $86
	incbin "../../../Extracted/Sound/sfx_crowd6_cmdstream.bin"
sfx_crowd7:							;sound effect program, cue $87
	incbin "../../../Extracted/Sound/sfx_crowd7_cmdstream.bin"
sfx_crowdoff:						;sound effect program, cue $88
	incbin "../../../Extracted/Sound/sfx_crowdoff_cmdstream.bin"
sfx_check1:							;sound effect program, cue $90
	incbin "../../../Extracted/Sound/sfx_check1_cmdstream.bin"
sfx_check2:							;sound effect program, cue $91
	incbin "../../../Extracted/Sound/sfx_check2_cmdstream.bin"
sfx_playerwall:						;sound effect program, cue $9E
	incbin "../../../Extracted/Sound/sfx_playerwall_cmdstream.bin"
sfx_playerwall2:					;sound effect program, cue $9F
	incbin "../../../Extracted/Sound/sfx_playerwall2_cmdstream.bin"
sfx_shothard:						;sound effect program, cue $8F
	incbin "../../../Extracted/Sound/sfx_shothard_cmdstream.bin"
sfx_puckwall1:						;sound effect program, cue $95
	incbin "../../../Extracted/Sound/sfx_puckwall1_cmdstream.bin"
sfx_puckwall2:						;sound effect program, cue $96
	incbin "../../../Extracted/Sound/sfx_puckwall2_cmdstream.bin"
sfx_puckwall3:						;sound effect program, cue $97
	incbin "../../../Extracted/Sound/sfx_puckwall3_cmdstream.bin"
sfx_hithigh:						;sound effect program, cue $92
	incbin "../../../Extracted/Sound/sfx_hithigh_cmdstream.bin"
sfx_hitlow:							;sound effect program, cue $93
	incbin "../../../Extracted/Sound/sfx_hitlow_cmdstream.bin"
sfx_shotfh:							;sound effect program, cue $8D
	incbin "../../../Extracted/Sound/sfx_shotfh_cmdstream.bin"
sfx_shotbh:							;sound effect program, cue $8E
	incbin "../../../Extracted/Sound/sfx_shotbh_cmdstream.bin"
sfx_puckpost:						;sound effect program, cue $94
	incbin "../../../Extracted/Sound/sfx_puckpost_cmdstream.bin"
sfx_stop1:							;sound effect program, cue $9C
	incbin "../../../Extracted/Sound/sfx_stop1_cmdstream.bin"
sfx_stop2:							;sound effect program, cue $9D
	incbin "../../../Extracted/Sound/sfx_stop2_cmdstream.bin"
sfx_shotwiff2:						;sound effect program, cue $99
	incbin "../../../Extracted/Sound/sfx_shotwiff2_cmdstream.bin"
sfx_shotwiff1:						;sound effect program, cue $98
	incbin "../../../Extracted/Sound/sfx_shotwiff1_cmdstream.bin"
sfx_shotwiff4:						;sound effect program, cue $9B
	incbin "../../../Extracted/Sound/sfx_shotwiff4_cmdstream.bin"
sfx_shotwiff3:						;sound effect program, cue $9A
	incbin "../../../Extracted/Sound/sfx_shotwiff3_cmdstream.bin"
sfx_crowdboo:						;sound effect program, cue $8B
	incbin "../../../Extracted/Sound/sfx_crowdboo_cmdstream.bin"
sfx_oooh2:							;sound effect program, cue $8C
	incbin "../../../Extracted/Sound/sfx_oooh2_cmdstream.bin"
sfx_crowdcheer:						;sound effect program, cue $8A
	incbin "../../../Extracted/Sound/sfx_crowdcheer_cmdstream.bin"
sfx_whistle:						;sound effect program, cue $89
	incbin "../../../Extracted/Sound/sfx_whistle_cmdstream.bin"
SPCDriverEnd:
	assert SPCDriverEnd-SPCDriver == SPCDRIVERSIZE
	dw BootInstrumentsEnd-BootInstruments, SPCINSTR	; block 2: the instrument table

; ---- BootInstruments ----
BootInstruments:					;29 instruments: sample number, ADSR1, ADSR2, GAIN, then 2 pitch bytes
									;(SNES DSP values)
	db $00, $8F,$E0,$B8, $07,$A0	; instrument $00
	db $01, $8F,$E0,$B8, $07,$A0	; instrument $01
	db $02, $8F,$E0,$B8, $07,$A0	; instrument $02
	db $03, $8F,$E0,$B8, $04,$00	; instrument $03
	db $04, $8F,$E0,$B8, $07,$A0	; instrument $04
	db $05, $8F,$E0,$B8, $07,$A0	; instrument $05
	db $06, $8F,$E0,$B8, $02,$00	; instrument $06
	db $07, $8F,$E0,$B8, $06,$F0	; instrument $07
	db $08, $FF,$E0,$B8, $07,$A0	; instrument $08
	db $9A, $8F,$E0,$B8, $04,$70	; instrument $09
	db $00, $8F,$E0,$B8, $04,$70	; instrument $0A
	db $01, $8F,$E0,$B8, $07,$A0	; instrument $0B
	db $02, $8F,$E0,$B8, $07,$A0	; instrument $0C
	db $03, $8F,$E0,$B8, $07,$A0	; instrument $0D
	db $04, $8F,$E0,$B8, $07,$A0	; instrument $0E
	db $05, $8F,$E0,$B8, $07,$A0	; instrument $0F
	db $06, $8F,$E0,$B8, $07,$A0	; instrument $10
	db $07, $8F,$E0,$B8, $07,$A0	; instrument $11
	db $08, $8F,$E0,$B8, $07,$A0	; instrument $12
	db $09, $8F,$E0,$B8, $07,$A0	; instrument $13
	db $0A, $8F,$E0,$B8, $07,$A0	; instrument $14
	db $0B, $8F,$E0,$B8, $07,$A0	; instrument $15
	db $0C, $8F,$E0,$B8, $07,$A0	; instrument $16
	db $0D, $8F,$E0,$B8, $07,$A0	; instrument $17
	db $0E, $8F,$E0,$B8, $07,$A0	; instrument $18
	db $0F, $FF,$E0,$B8, $0A,$F0	; instrument $19
	db $10, $8F,$E0,$B8, $0A,$F0	; instrument $1A
	db $11, $8F,$E0,$B8, $09,$F0	; instrument $1B
	db $12, $8F,$E0,$B8, $07,$A0	; instrument $1C
BootInstrumentsEnd:
	dw BootSampleDirEnd-BootSampleDir, SPCSAMPLEDIR	; block 3: the sample directory

; ---- BootSampleDir ----
BootSampleDir:						;DSP sample directory: per sample the APU address of its start and of its
									;loop point
	dw SPCBOOTSAMPLES+$0000,SPCBOOTSAMPLES+$0DD1	; sample $00: start, loop (offsets in bootsamples.brr)
	dw SPCBOOTSAMPLES+$0DD1,SPCBOOTSAMPLES+$1689	; sample $01: start, loop (offsets in bootsamples.brr)
	dw SPCBOOTSAMPLES+$1689,SPCBOOTSAMPLES+$2757	; sample $02: start, loop (offsets in bootsamples.brr)
	dw SPCBOOTSAMPLES+$2757,SPCBOOTSAMPLES+$2796	; sample $03: start, loop (offsets in bootsamples.brr)
	dw SPCBOOTSAMPLES+$27BA,SPCBOOTSAMPLES+$4233	; sample $04: start, loop (offsets in bootsamples.brr)
	dw SPCBOOTSAMPLES+$4233,SPCBOOTSAMPLES+$4530	; sample $05: start, loop (offsets in bootsamples.brr)
	dw SPCBOOTSAMPLES+$4530,SPCBOOTSAMPLES+$455D	; sample $06: start, loop (offsets in bootsamples.brr)
	dw SPCBOOTSAMPLES+$456F,SPCBOOTSAMPLES+$4968	; sample $07: start, loop (offsets in bootsamples.brr)
	dw SPCBOOTSAMPLES+$49A7,SPCBOOTSAMPLES+$5271	; sample $08: start, loop (offsets in bootsamples.brr)
BootSampleDirEnd:
	dw BOOTSAMPLESIZE, SPCBOOTSAMPLES	; block 4: the BRR samples

; ---- BootSamples ----
BootSamples:						;BRR samples of the boot set (9-byte blocks)
	incbin "../../../Extracted/Sound/bootsamples.brr"
BootSamplesEnd:
	assert BootSamplesEnd-BootSamples == BOOTSAMPLESIZE
	dw $0000, SPCDRIVER				; end block: length 0, start the driver at $0400
