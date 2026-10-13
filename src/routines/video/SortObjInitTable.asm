SortObjInitTable:		;Start positions, frames and assignments of the players
	; x, y, height, frame, attribute (bit 0 = visiting palette), collision width, collision height, assignment, flags
	dw $0160,$00C0,$0000,SPFskatewp,$0000,$0008,$0004,$0000,$0000
	dw $FF38,$FF9C,$0000,SPFskatewp,$0000,$0008,$0004,$0000,$0000
	dw $FF38,$FFB0,$0000,SPFskatewp,$0000,$0008,$0004,$0000,$0000
	dw $FF38,$FFC4,$0000,SPFskatewp,$0000,$0008,$0004,$0000,$0000
	dw $FF38,$FFD8,$0000,SPFskatewp,$0000,$0008,$0004,$0000,$0000
	dw $FF38,$FFEC,$0000,SPFskatewp,$0000,$0008,$0004,$0000,$0000
	dw $00C0,$00C0,$0000,SPFskatewp,$0001,$0008,$0004,$0000,$0000
	dw $FF38,$0028,$0000,SPFskatewp,$0001,$0008,$0004,$0000,$0000
	dw $FF38,$003C,$0000,SPFskatewp,$0001,$0008,$0004,$0000,$0000
	dw $FF38,$0050,$0000,SPFskatewp,$0001,$0008,$0004,$0000,$0000
	dw $FF38,$0064,$0000,SPFskatewp,$0001,$0008,$0004,$0000,$0000
	dw $FF38,$0078,$0000,SPFskatewp,$0001,$0008,$0004,$0000,$0000
	dw $0000,$010C,$0000,SPFgoal,$0000,$0014,$0006,$0000,$0000		; goal net
	dw $0000,$FEF4,$0000,SPFgoal+1,$0000,$0014,$0006,$0000,$0000		; other goal net
	dw $0000,$0000,$0000,SPFpuck+1,$0000,$0005,$0005,$0018,$0001		; puck
	dw $0000,$0000,$0000,SPFpuck,$0000,$0003,$0003,$0019,$0000		; puck shadow
