; Bank $84: scouting. Files in ROM order (docs/file-map.md).

if pc() < $848000
	org $848000
endif

SpriteSet9:							;frame set 9: frames 406-461
	dw 56							; frames
	dw 365							; pieces
	dw 640							; tiles
	dw .pieces-SpriteSet9
	dw .tiles-SpriteSet9
.frames:							;first piece of each frame (frame n = SPFGoalie+n)
	dw 0,8,15,24,28,35,40,43
	dw 49,53,60,67,73,83,90,99
	dw 108,114,121,124,127,133,139,146
	dw 155,158,163,172,180,186,191,196
	dw 202,209,218,224,229,235,244,249
	dw 255,263,268,275,281,288,293,302
	dw 310,318,326,332,338,343,351,356
	dw 365
.pieces:							;x, y, tile, attributes per piece
	incbin "../../Extracted/Graphics/Sprites/set09.pieces"
	assert .tiles-.pieces == 4*365
.tiles:								;640 4bpp tiles (32 bytes each)
	incbin "../../Extracted/Graphics/Sprites/set09.chr"
SpriteSet9End:						; end of SpriteSet9
	assert SpriteSet9End-SpriteSet9 == $630+640*32

ScoutingReportText:					;scouting report strings (read by UpdateScoutingDisplay)
	incbin "../../Extracted/Text/ScoutingReportText.bin"
ScoutingReportTextEnd:				; end of ScoutingReportText

FaceOffMap:							;the 12 x 10 faceoff box map (tiles from FaceOffTiles, attribute $20),
									;copied into textmap by puckfaceoff2
	incbin "../../Extracted/Graphics/FaceOff.snesmap"
FaceOffMapEnd:						; end of FaceOffMap
	assert FaceOffMapEnd-FaceOffMap == 240

incsrc "../routines/middle/ConvertByteToDigits.asm"
incsrc "../routines/hockey/UpdateRosterPlayers.asm"
incsrc "../routines/hockey/UpdateRosterPlayer.asm"
incsrc "../routines/hockey/SlideOutRosterPlayer.asm"
incsrc "../routines/hockey/SetupNextPlayer.asm"
incsrc "../routines/hockey/PickRosterAnim.asm"
incsrc "../routines/hockey/GetRosterEntry.asm"
incsrc "../routines/hockey/SkaterRosterAnims.asm"
incsrc "../routines/hockey/GoalieRosterAnims.asm"
incsrc "../routines/hockey/RosterAnimScripts.asm"
incsrc "../routines/hockey/RosterOrderTable.asm"
incsrc "../routines/hockey/UpdateTeamSprites.asm"

HotList:							;hot spot (stick blade) x, y bytes for every sprite frame, read by GetHot
	incbin "../../Extracted/Graphics/HotList.bin"
HotListEnd:							; end of HotList

RinkLogoTiles:						;packed rink logo tiles (14 tiles, $1C0 bytes unpacked), sent to
									;vram after FaceOffTiles by setupice
	incbin "../../Extracted/Graphics/RinkLogoTiles.chr.pak"
RinkLogoTilesEnd:					; end of RinkLogoTiles

incsrc "../routines/hockey/UpdateScoutingDisplay.asm"
incsrc "../routines/hockey/ScrollDisplayUp.asm"

PlayoffTiles:						;packed playoff screen palette and tiles (decompressor
									;DecompressBytecode): 128 colors, then 6 tiles; PlayoffScreen sends them
									;to vram $1000
	incbin "../../Extracted/Graphics/PlayoffTiles.chr.pak"

incsrc "../routines/video/InitSortObjects.asm"
incsrc "../routines/video/SsoInitTable.asm"
incsrc "../routines/video/FfoInitTable.asm"
incsrc "../routines/video/SortObjInitTable.asm"
incsrc "../routines/middle/Readjoy12.asm"
incsrc "../routines/stats/DisplayStats.asm"
incsrc "../routines/penalty/DisplayStats_sslist.asm"
incsrc "../routines/stats/GetNameandAttrib.asm"
incsrc "../routines/stats/attribjmp.asm"
incsrc "../routines/stats/AttribStatus.asm"

StatusTextTbl:						;AttribStatus strings
	%String("Ice   ")
	%String("Bench ")
	%String("Inj P ")
	%String("Inj G ")
	%String("  ")
	%String(" C")

incsrc "../routines/stats/AttribEnergy.asm"
incsrc "../routines/stats/AttribFighting.asm"
incsrc "../routines/stats/AttribHanded.asm"

HandedTextTbl:						;AttribHanded strings
	%String("Right ")
	%String("Left  ")

incsrc "../routines/stats/AttribWeight.asm"
