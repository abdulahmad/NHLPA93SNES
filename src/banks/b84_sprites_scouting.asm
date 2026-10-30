; Bank $84: goalie sprites (set 9), the scouting report text, the hot spot list, and the roster and
; scouting routines. Files in ROM order (docs/file-map.md).

if pc() < $848000
	org $848000
endif
SpriteSet9:							;frame set 9: frames 406-461
	incbin "../../Extracted/Graphics/Sprites/Sprites406_461.sanim"

ScoutingReportText:					;scouting report strings (read by UpdateScoutingDisplay)
	incbin "../../Extracted/Text/ScoutingReportText.bin"
ScoutingReportTextEnd:				; end of ScoutingReportText

FaceOffMap:							;the 12 x 10 faceoff box map (tiles from FaceOffTiles, attribute $20),
									;copied into textmap by puckfaceoff2
	incbin "../../Extracted/Graphics/FaceOff.smap"

incsrc "../routines/print/ConvertByteToDigits.asm"
incsrc "../routines/hockey/teams/UpdateRosterPlayers.asm"
incsrc "../routines/hockey/teams/UpdateRosterPlayer.asm"
incsrc "../routines/hockey/teams/SlideOutRosterPlayer.asm"
incsrc "../routines/hockey/teams/SetupNextPlayer.asm"
incsrc "../routines/hockey/teams/PickRosterAnim.asm"
incsrc "../routines/hockey/teams/GetRosterEntry.asm"
incsrc "../routines/hockey/teams/SkaterRosterAnims.asm"
incsrc "../routines/hockey/teams/GoalieRosterAnims.asm"
incsrc "../routines/hockey/teams/RosterAnimScripts.asm"
incsrc "../routines/hockey/teams/RosterOrderTable.asm"
incsrc "../routines/hockey/display/UpdateTeamSprites.asm"

HotList:							;hot spot (stick blade) x, y bytes for every sprite frame, read by GetHot
	incbin "../../Extracted/Graphics/HotList.bin"
HotListEnd:							; end of HotList

RinkLogoTiles:						;packed rink logo tiles (14 tiles, $1C0 bytes unpacked), sent to
									;vram after FaceOffTiles by setupice
	incbin "../../Extracted/Graphics/RinkLogoTiles.chr.pak"
RinkLogoTilesEnd:					; end of RinkLogoTiles

incsrc "../routines/hockey/screens/UpdateScoutingDisplay.asm"
incsrc "../routines/hockey/screens/ScrollDisplayUp.asm"

PlayoffTiles:						;packed playoff screen palette and tiles (decompressor
									;DecompressBytecode): 128 colors, then 6 tiles; PlayoffScreen sends them
									;to vram $1000
	incbin "../../Extracted/Graphics/PlayoffTiles.chr.pak"

incsrc "../routines/video/objects/InitSortObjects.asm"
incsrc "../routines/video/objects/SsoInitTable.asm"
incsrc "../routines/video/objects/FfoInitTable.asm"
incsrc "../routines/video/objects/SortObjInitTable.asm"
incsrc "../routines/middle/input/orjoy.asm"
incsrc "../routines/stats/DisplayStats.asm"
incsrc "../routines/stats/DisplayStats_sslist.asm"
incsrc "../routines/stats/GetNameandAttrib.asm"
incsrc "../routines/stats/attribjmp.asm"
incsrc "../routines/stats/AttribStatus.asm"
incsrc "../data/text/StatusTextTbl.asm"
incsrc "../routines/stats/AttribEnergy.asm"
incsrc "../routines/stats/AttribFighting.asm"
incsrc "../routines/stats/AttribHanded.asm"
incsrc "../data/text/HandedTextTbl.asm"
incsrc "../routines/stats/AttribWeight.asm"
