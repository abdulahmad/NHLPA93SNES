; Bank $84: scouting. Files in ROM order (docs/file-map.md).

if pc() < $848000
	org $848000
endif
incsrc "../data/gfx/SpriteSet9.asm"

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
incsrc "../data/text/StatusTextTbl.asm"
incsrc "../routines/stats/AttribEnergy.asm"
incsrc "../routines/stats/AttribFighting.asm"
incsrc "../routines/stats/AttribHanded.asm"
incsrc "../data/text/HandedTextTbl.asm"
incsrc "../routines/stats/AttribWeight.asm"
