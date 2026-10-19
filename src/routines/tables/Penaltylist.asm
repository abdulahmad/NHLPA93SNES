; The penalties. Penaltylist holds one word per penalty number (the number is the word offset): the offset
; of that penalty's data, which follows the list: slow-down time and minutes, text, animation delays.
; The Pen* equates sit beside their entries.

Penaltylist:						;The penalties, by penalty number (the word offset into this table)
	dw $0000
PenEOP	=	$02						;period over
	assert pc()-Penaltylist == PenEOP
	dw PenDataEOP-Penaltylist
PenEOG	=	$04						;game over
	assert pc()-Penaltylist == PenEOG
	dw PenDataEOG-Penaltylist
PenOOP	=	$06						;face off / out of play: puck still too long, puck over the glass
	assert pc()-Penaltylist == PenOOP
	dw PenDataGhold-Penaltylist
PenGhold	=	$08					;goalie held the puck / bump
	assert pc()-Penaltylist == PenGhold
	dw PenDataGhold-Penaltylist
PenWhistle	=	$0A					;whistle
	assert pc()-Penaltylist == PenWhistle
	dw PenDatawhistle-Penaltylist
PenIcing	=	$0C					;icing
	assert pc()-Penaltylist == PenIcing
	dw PenDataice-Penaltylist
PenGoal	=	$0E						;goal
	assert pc()-Penaltylist == PenGoal
	dw PenDataGoal-Penaltylist
PenOffsides	=	$10					;offsides
	assert pc()-Penaltylist == PenOffsides
	dw PenDataoffsides-Penaltylist
PenRoughing2	=	$12				;roughing with slow down time $A
	assert pc()-Penaltylist == PenRoughing2
	dw PenDatarough2-Penaltylist
PenNoText	=	$14					;injury stop, no text
	assert pc()-Penaltylist == PenNoText
	dw PenDataNoText-Penaltylist
PenCharging	=	$16					;charging
	assert pc()-Penaltylist == PenCharging
	dw PenDatacharge-Penaltylist
PenSlashing	=	$18					;slashing
	assert pc()-Penaltylist == PenSlashing
	dw PenDataslash-Penaltylist
PenRoughing	=	$1A					;roughing
	assert pc()-Penaltylist == PenRoughing
	dw PenDatarough-Penaltylist
PenCrossChk	=	$1C					;cross check
	assert pc()-Penaltylist == PenCrossChk
	dw PenDatacross-Penaltylist
PenHooking	=	$1E					;hooking
	assert pc()-Penaltylist == PenHooking
	dw PenDatahook-Penaltylist
PenTripping	=	$20					;tripping
	assert pc()-Penaltylist == PenTripping
	dw PenDatatrip-Penaltylist
PenInterference	=	$22				;interference
	assert pc()-Penaltylist == PenInterference
	dw PenDataint-Penaltylist
PenHolding	=	$24					;holding
	assert pc()-Penaltylist == PenHolding
	dw PenDataHold-Penaltylist
PenFighting	=	$26					;fighting, also the penalty byte of a fight in the list
	assert pc()-Penaltylist == PenFighting
	dw PenDatafight-Penaltylist
PenFighting2	=	$28				;fighting *
	assert pc()-Penaltylist == PenFighting2
	dw PenDatafight2-Penaltylist
PenInst	=	$2A						;fight instigator
	assert pc()-Penaltylist == PenInst
	dw PenDataInst-Penaltylist
PenDelay	=	$2C					;delayed penalty ref
	assert pc()-Penaltylist == PenDelay
	dw PenDatadelay-Penaltylist
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
