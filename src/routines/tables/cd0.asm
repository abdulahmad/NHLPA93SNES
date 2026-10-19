cd0:								;$ffTT = frame/time for the levels of crowd excitement. Used by
									;updatecrowdf, indexed by crowd level and Crowdstep. 4 blocks of 16
									;words, one per crowd level range ((Crowdlevel/2) and $60 = byte offset
									;0,$20,$40,$60); each step (Crowdstep 0-$1E, word index) gives the crowd
									;frame (high byte) and its base duration (low byte). Block 0 is a calm
									;crowd (time $0C), blocks 1, 2 and 3 are livelier and faster (time 7, 7,
									;3)
	dw $010C,$020C,$030C,$040C,$050C,$0A0C,$090C,$080C
	dw $060C,$070C,$080C,$090C,$0A0C,$050C,$040C,$030C

	dw $0107,$0207,$0307,$0407,$0507,$0B07,$0C07,$0D07
	dw $0607,$0707,$0807,$0907,$0A07,$0B07,$0C07,$0D07

	dw $0E07,$0F07,$1007,$1107,$1207,$0B07,$0C07,$0D07
	dw $1207,$1107,$1007,$0F07,$0E07,$0D07,$0C07,$0B07

	dw $0E03,$0F03,$1003,$1103,$1203,$0B03,$0C03,$0D03
	dw $1203,$1103,$1003,$0F03,$0E03,$0D03,$0C03,$0B03
