runspeed = 200						; acc speed equate for the table below

dirtab:								;x, y speed for each direction
	dw 0,runspeed, runspeed*1000/1414,runspeed*1000/1414, runspeed,0, runspeed*1000/1414,-runspeed*1000/1414
	dw 0,-runspeed, -runspeed*1000/1414,-runspeed*1000/1414, -runspeed,0, -runspeed*1000/1414,runspeed*1000/1414
