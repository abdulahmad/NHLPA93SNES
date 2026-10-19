Penaltylist:						;The penalties, by penalty number
	dw $0000						; 0
	dw PenDataEOP-Penaltylist		; $02 period over
	dw PenDataEOG-Penaltylist		; $04 game over
	dw PenDataGhold-Penaltylist		; $06 out of play
	dw PenDataGhold-Penaltylist		; $08 goalie holding
	dw PenDatawhistle-Penaltylist	; $0A whistle
	dw PenDataice-Penaltylist		; $0C icing
	dw PenDataGoal-Penaltylist		; $0E goal
	dw PenDataoffsides-Penaltylist	; $10 offsides
	dw PenDatarough2-Penaltylist	; $12 roughing, slow down time $A
	dw PenDataNoText-Penaltylist	; $14 no text
	dw PenDatacharge-Penaltylist	; $16 charging
	dw PenDataslash-Penaltylist		; $18 slashing
	dw PenDatarough-Penaltylist		; $1A roughing
	dw PenDatacross-Penaltylist		; $1C cross check
	dw PenDatahook-Penaltylist		; $1E hooking
	dw PenDatatrip-Penaltylist		; $20 tripping
	dw PenDataint-Penaltylist		; $22 interference
	dw PenDataHold-Penaltylist		; $24 holding
	dw PenDatafight-Penaltylist		; $26 fighting
	dw PenDatafight2-Penaltylist	; $28 fighting *
	dw PenDataInst-Penaltylist		; $2A fight instigator
	dw PenDatadelay-Penaltylist		; $2C delay
;format: dw $ttmm (tt = slow down time in half secs, mm = penalty min.); string (length word counting itself,
;text) then dw $ffdd,... (ff = frame, dd = delay; negative ends)
PenDataEOP:							;period over
	dw $0100
	dw 13
	db "Period Over"
	dw -$0510
PenDataEOG:							;game over
	dw $0100
	dw 11
	db "Game Over"
	dw $0510,-$4030
PenDataGoal:						;goal
	dw $0100
	dw 2
	dw $050A,-$4010
PenDataNoText:						;no text
	dw $0100
	dw 2
	dw $0510,-$4018
PenDataice:							;icing
	dw $0100
	dw 7
	db "Icing"
	dw $0002,$0101,-$0206
PenDataoffsides:					;offsides
	dw $0100
	dw 10
	db "Off-side"
	dw $0002,$0301,-$040F
PenDataGhold:						;face off (PenOOP, PenGhold)
	dw $0100
	dw 10
	db "Face Off"
	dw -$050A
PenDatadelay:						;delay
	dw $0000
	dw 9
	db "Penalty"
	dw $0003,$0301,-$040F
PenDatawhistle:						;whistle
	dw $0000
	dw 2
	dw -$050A
PenDatacharge:						;charging
	dw $0402
	dw 10
	db "Charging"
	dw $0004,$0101,$0A01,$0B01,$0A01,$0B01,$0A01,$0B01,$0A01,$0B01,-$0101
PenDataslash:						;slashing
	dw $0402
	dw 10
	db "Slashing"
	dw $0004,$0101,$0201,$0301,$0201,$0301,$0201,$0301,$0201,$0301,-$0101
PenDatatrip:						;tripping
	dw $0402
	dw 10
	db "Tripping"
	dw $0004,$0401,$0501,$0401,$0501,$0401,$0501,$0401,$0501,-$0101
PenDatarough2:						;roughing, slow down time $A
	dw $0A02
	dw 10
	db "Roughing"
	dw $0004,$0D01,$0E01,$0D01,$0E01,$0D01,$0E01,$0D01,$0E01,-$0101
PenDatarough:						;roughing
	dw $0402
	dw 10
	db "Roughing"
	dw $0004,$0D01,$0E01,$0D01,$0E01,$0D01,$0E01,$0D01,$0E01,-$0101
PenDatahook:						;hooking
	dw $0402
	dw 9
	db "Hooking"
	dw $0004,$0101,$0901,$0801,$0901,$0801,$0901,$0801,$0901,$0801,-$0101
PenDatacross:						;cross check
	dw $0402
	dw 13
	db "Cross Check"
	dw $0004,$0601,$0F01,$1001,$0F01,$1001,$0F01,$1001,$0F01,$1001,-$0101
PenDataint:							;interference
	dw $0402
	dw 14
	db "Interference"
	dw $0004,$0101,$0C06,-$0101
PenDataHold:						;holding
	dw $0402
	dw 9
	db "Holding"
	dw $0004,$0101,$0706,-$0101
PenDatafight:						;fighting
	dw $2805
	dw 10
	db "Fighting"
	dw $0004,$0D01,$0E01,$0D01,$0E01,$0D01,$0E01,$0D01,$0E01,-$0101
PenDatafight2:						;fighting *
	dw $2805
	dw 12
	db "Fighting *"
	dw $0004,$0D01,$0E01,$0D01,$0E01,$0D01,$0E01,$0D01,$0E01,-$0101
PenDataInst:						;fight instigator
	dw $2802
	dw 18
	db "Fight Instigator"
	dw $0004,$0D01,$0E01,$0D01,$0E01,$0D01,$0E01,$0D01,$0E01,-$0101
