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
incsrc "banks/b82_rink_tiles_anim_tables.asm"
incsrc "banks/b83_teams_rink_maps.asm"
incsrc "banks/b84_scouting_rosters.asm"
incsrc "banks/b85_title_map.asm"
incsrc "banks/b86_sound_driver.asm"
incsrc "banks/b87_ref_tiles_drawframe.asm"
incsrc "banks/b88_teamblocks_playoffs_password.asm"
incsrc "banks/b89_hor_ref_replay_music.asm"
incsrc "banks/b8A_credits_bracket.asm"
incsrc "banks/b8B_opening_playoffs.asm"
incsrc "banks/b8C_nhlpa_logo.asm"
incsrc "banks/b8D_bigfont_highlights.asm"
incsrc "banks/b8E_gameloop.asm"
incsrc "banks/b8F_frontend.asm"
incsrc "banks/b90_expanded.asm"
