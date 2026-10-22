; In-game SPC upload: the sample directory and BRR samples that replace the boot set when a game starts
; (setupice sends it). The sound program stays loaded from the boot upload.

function ROMPOS(a) = (a>>16&$7F)*$8000+(a&$7FFF)	;file offset of a LoROM address (the samples
									;run across the bank $81/$82 boundary)
function GSAMP(l) = ROMPOS(l)-ROMPOS(GameSamples)+SPCSAMPLES	;APU address of a label in GameSamples

GameSoundUpload:					;in-game sample set for the SPC700 sound driver (the boot stream at
									;BootSoundUpload carries the driver itself)
	dw GameSampleDirEnd-GameSampleDir, SPCSAMPLEDIR	; block 1: 76 bytes, the sample directory

GameSampleDir:						;DSP sample directory: per sample the APU address of its start and of its
									;loop point
	dw GSAMP(sfx_whistle_brr),GSAMP(sfx_whistle_brr_loop)	; sample $00: whistle (loops)
	dw GSAMP(sfx_crowdcheer_brr),GSAMP(sfx_check_brr)	; sample $01: crowdcheer (no loop)
	dw GSAMP(sfx_check_brr),GSAMP(sfx_check2_brr)	; sample $02: check1 (no loop)
	dw GSAMP(sfx_check2_brr),GSAMP(sfx_oooh_brr)	; sample $03: check2 (no loop)
	dw GSAMP(sfx_oooh_brr),GSAMP(sfx_hithigh_brr)	; sample $04: oooh2 (no loop)
	dw GSAMP(sfx_hithigh_brr),GSAMP(sfx_shotfh_brr)	; sample $05: hithigh, hitlow (no loop)
	dw GSAMP(sfx_shotfh_brr),GSAMP(sfx_shotbh_brr)	; sample $06: shotfh (no loop)
	dw GSAMP(sfx_shotbh_brr),GSAMP(sfx_crowdboo_brr)	; sample $07: shotbh, shothard (no loop)
	dw GSAMP(sfx_crowdboo_brr),GSAMP(sfx_puckwall_brr)	; sample $08: crowdboo (no loop)
	dw GSAMP(sfx_puckwall_brr),GSAMP(sfx_puckpost_brr)	; sample $09: puckwall1-3, shothard (no loop)
	dw GSAMP(sfx_puckpost_brr),GSAMP(sfx_shotwiff_brr)	; sample $0A: puckpost (no loop)
	dw GSAMP(sfx_shotwiff_brr),GSAMP(sfx_shotwiff2_brr)	; sample $0B: shotwiff1, shotwiff3 (no loop)
	dw GSAMP(sfx_shotwiff2_brr),GSAMP(sfx_stop_brr)	; sample $0C: shotwiff2, shotwiff4 (no loop)
	dw GSAMP(sfx_stop_brr),GSAMP(sfx_playerwall_brr)	; sample $0D: stop1, stop2 (no loop)
	dw GSAMP(sfx_playerwall_brr),GSAMP(sfx_a1_brr)	; sample $0E: playerwall, playerwall2 (no loop)
	dw GSAMP(sfx_a1_brr),GSAMP(sfx_a1_brr_loop)	; sample $0F: sfx_a1 (loops)
	dw GSAMP(sfx_siren_brr),GSAMP(sfx_siren_brr_loop)	; sample $10: siren (loops)
	dw GSAMP(sample_11_brr),GSAMP(sample_11_brr_loop)	; sample $11: no effect uses it (loops)
	dw GSAMP(sample_12_brr),GSAMP(GameSamplesEnd)	; sample $12: no effect uses it (no loop)
GameSampleDirEnd:					; end of GameSampleDir
	dw GAMESAMPLESIZE, SPCSAMPLES	; block 2: the BRR samples

GameSamples:						;BRR samples (9-byte blocks)
sfx_whistle_brr:					;BRR sample $00 (GameSampleDir): whistle
	incbin "../../../Extracted/Sound/sfx_whistle_brr.bin":$0..$1B
sfx_whistle_brr_loop:				;loop point of sample $00
	incbin "../../../Extracted/Sound/sfx_whistle_brr.bin":$1B..$2D
sfx_crowdcheer_brr:					;BRR sample $01 (GameSampleDir): crowdcheer
	incbin "../../../Extracted/Sound/sfx_crowdcheer_brr.bin"
sfx_check_brr:						;BRR sample $02 (GameSampleDir): check1
	incbin "../../../Extracted/Sound/sfx_check_brr.bin"
sfx_check2_brr:						;BRR sample $03 (GameSampleDir): check2
	incbin "../../../Extracted/Sound/sfx_check2_brr.bin"
sfx_oooh_brr:						;BRR sample $04 (GameSampleDir): oooh2
	incbin "../../../Extracted/Sound/sfx_oooh_brr.bin"
sfx_hithigh_brr:					;BRR sample $05 (GameSampleDir): hithigh, hitlow
	incbin "../../../Extracted/Sound/sfx_hithigh_brr.bin"
sfx_shotfh_brr:						;BRR sample $06 (GameSampleDir): shotfh
	incbin "../../../Extracted/Sound/sfx_shotfh_brr.bin"
sfx_shotbh_brr:						;BRR sample $07 (GameSampleDir): shotbh, shothard
	incbin "../../../Extracted/Sound/sfx_shotbh_brr.bin"
sfx_crowdboo_brr:					;BRR sample $08 (GameSampleDir): crowdboo
	incbin "../../../Extracted/Sound/sfx_crowdboo_brr.bin"
sfx_puckwall_brr:					;BRR sample $09 (GameSampleDir): puckwall1-3, shothard
	incbin "../../../Extracted/Sound/sfx_puckwall_brr.bin"
sfx_puckpost_brr:					;BRR sample $0A (GameSampleDir): puckpost
	incbin "../../../Extracted/Sound/sfx_puckpost_brr.bin"
sfx_shotwiff_brr:					;BRR sample $0B (GameSampleDir): shotwiff1, shotwiff3
	incbin "../../../Extracted/Sound/sfx_shotwiff_brr.bin"
sfx_shotwiff2_brr:					;BRR sample $0C (GameSampleDir): shotwiff2, shotwiff4
	incbin "../../../Extracted/Sound/sfx_shotwiff2_brr.bin"
sfx_stop_brr:						;BRR sample $0D (GameSampleDir): stop1, stop2
	incbin "../../../Extracted/Sound/sfx_stop_brr.bin"
sfx_playerwall_brr:					;BRR sample $0E (GameSampleDir): playerwall, playerwall2
	incbin "../../../Extracted/Sound/sfx_playerwall_brr.bin"
sfx_a1_brr:							;BRR sample $0F (GameSampleDir): sfx_a1
	incbin "../../../Extracted/Sound/sfx_a1_brr.bin":$0..$1B
sfx_a1_brr_loop:					;loop point of sample $0F
	incbin "../../../Extracted/Sound/sfx_a1_brr.bin":$1B..$E1
sfx_siren_brr:						;BRR sample $10 (GameSampleDir): siren
	incbin "../../../Extracted/Sound/sfx_siren_brr.bin":$0..$7E
sfx_siren_brr_loop:					;loop point of sample $10
	incbin "../../../Extracted/Sound/sfx_siren_brr.bin":$7E..$E1
sample_11_brr:						;BRR sample $11 (GameSampleDir): no effect uses it
	incbin "../../../Extracted/Sound/sample_11_brr.bin":$0..$5A
sample_11_brr_loop:					;loop point of sample $11
	incbin "../../../Extracted/Sound/sample_11_brr.bin":$5A..$B4
sample_12_brr:						;BRR sample $12 (GameSampleDir): no effect uses it
	incbin "../../../Extracted/Sound/sample_12_brr.bin"
GameSamplesEnd:						; end of GameSamples
	dw $0000, SPCRESUME				; end block: length 0, start the driver at $0800
