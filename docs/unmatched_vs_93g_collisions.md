# Collision strategy (93S vs 93G)

Conventions: bank copy = 93G name + bank hex suffix; SNES variant = `<93G name>_<variant>`; split-out 93G local label = `<parent>_<label>`; A-register variant = suffix `a`, d0 interface keeps the 93G name; distinct tables get descriptive suffixes.

| 93S symbol | 93G name | holder | verdict | strategy | action |
|--|--|--|--|--|--|
| GGSleft | aggress | 93S aggress ($10FF) | WRONG: holds 93G $75 (checking rating, set from byte 4 high nibble); 93S GGSleft is 93G aggress ($73, byte 7 low nibble) | RENAME_HOLDER | aggress->chkrating (descriptive, 93G only has $75 'attribute'/'Chk rating'), then GGSleft->aggress. fightagg = 93G $74 fight rating: keep (93G has no name) |
| randomd0sd0 | randomd0s | 93S randomd0s | WRONG: holder is the A-register 0..A-1 variant, not the signed d0 range | RENAME_HOLDER | randomd0s->randomas, then randomd0sd0->randomd0s |
| GetRosterEntry89 | GetRosterEntry | 93S GetRosterEntry | Not yet verified: holder looks like a bank-8x copy of the 93G routine | RENAME_HOLDER | holder->GetRosterEntry89 (bank-suffix), GetRosterEntry89->GetRosterEntry |
| InitSortObjects | SprSort/defaultsprites | 93S defaultsprites | Not yet verified | VARIANTS | rename only after the bodies are compared; otherwise KEEP |
| PrintStringFromList | Fprint | 93S Fprint | holder is print-with-format, ours indexes a list | VARIANTS | PrintStringFromList->Fprint_list |
| TickerTeam | PrintGameInfo | none | - | EXACT_NO_COLLISION | TickerTeam->PrintGameInfo |
| jdtab8F | jdtab | 93S jdtab | holder is different table (distinct content) | VARIANTS | descriptive suffix: jdtab_sso (checksso copy) |
| dirtab8F | dirtab | 93S dirtab | holder is different table | VARIANTS | dirtab_8F -> descriptive dirtab4 (distinct content) |
| setplayercolors_palbuffer | setplayercolors | none | - | VARIANTS | setplayercolors_palbuffer->setplayercolors, setplayercolors_sp->setplayercolors_team (split-out part) |
| SPF/Xfrac,Yfrac,Zfrac,Old*frac | Xpos,Ypos,Zpos,Old*pos | 93S Xpos/Ypos/Zpos hold the integer words | CORRECT (integer half of the 93G long) | KEEP | keep; frac names are the SNES fraction half, convention `<93G name>frac` |
| ssoattr,ssoframe,ssoz | attribute,frame,Zpos | 93S attribute/frame/Zpos (sort objects) | CORRECT | KEEP | sso* are a separate SoA array of the sso objects; keep, document in ram93s.asm |
| TMPDICE,TMPDBENCH,TMPDOUT | tmpdst | 93S tmpdst | CORRECT | KEEP | value names for tmpdst; 93G only comments them |
| JOYA.. | abut.. | 93S masks | CORRECT: masks, 93G are bit numbers | VARIANTS | keep JOYx masks; add 93G bit-number names only if code needs them |
| randoma / random / sfx8F / QueueSound / Readjoy12 / PauseMenu etc. | randomd0 / sfx / ReadJoy1 ... | none | - | MERGE_NOTE | not name collisions; keep name, add '93G <name>' note to comment |
| nullrtl,nullrtl85,nullrtl89 | rtss | none | - | MERGE_NOTE | keep names, note 93G rtss; per-bank copies keep bank suffix |
| vb2_blank,VBlank_Cram,VBlank_CramOnly,addframe_hi,vb2_main,ReturnGoalies_r | vb2,VBlank,addframe... | none | - | MERGE_NOTE | already follow <93G name>_<variant>; keep |
| sprflag,sprx,spry,sprframe,fobox,p3cue,midpercue,pentimer,vcountmark,lastframevc,tickerstart,nopuckb,SPAListEnd | - | none | - | KEEP | SNES-only bookkeeping; no 93G equivalent; keep |
