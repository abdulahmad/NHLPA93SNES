; NHLPA Hockey '93 (SNES) - top level: macros, hardware registers and RAM names, then one file per bank in ROM
; order (docs/file-map.md). LoROM + FastROM (map mode $30), 4 Mbit, 16 banks mapped at $80-$8F.
; Bank $90 is included last. The stock build writes no bytes there.
asar 1.91
lorom
check bankcross off
incsrc "macros/snes93.mac"
incsrc "ram93s.asm"
incsrc "banks/b80_engine.asm"
incsrc "banks/b81_game_samples.asm"
incsrc "banks/b82_rink_tiles_anims.asm"
incsrc "banks/b83_teams_rink_maps.asm"
incsrc "banks/b84_goalie_sprites_scouting.asm"
incsrc "banks/b85_check_sprites_title.asm"
incsrc "banks/b86_sound_driver.asm"
incsrc "banks/b87_player_sprites.asm"
incsrc "banks/b88_fight_sprites_playoffs.asm"
incsrc "banks/b89_goalie_save_sprites_replay.asm"
incsrc "banks/b8A_misc_sprites_bracket.asm"
incsrc "banks/b8B_fall_sprites_opening.asm"
incsrc "banks/b8C_skate_sprites.asm"
incsrc "banks/b8D_goalie_sprites_fonts.asm"
incsrc "banks/b8E_celebrate_crowd_sprites.asm"
incsrc "banks/b8F_frontend.asm"
incsrc "banks/b90_expanded.asm"
