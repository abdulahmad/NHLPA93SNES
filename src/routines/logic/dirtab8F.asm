dirtab8F:							;x, y acceleration for each direction (four times dirtab: runspeed*4)
	dw 0,runspeed*4
	dw runspeed*4*1000/1414,runspeed*4*1000/1414
	dw runspeed*4,0
	dw runspeed*4*1000/1414,-runspeed*4*1000/1414
	dw 0,-runspeed*4
	dw -runspeed*4*1000/1414,-runspeed*4*1000/1414
	dw -runspeed*4,0
	dw -runspeed*4*1000/1414,runspeed*4*1000/1414
