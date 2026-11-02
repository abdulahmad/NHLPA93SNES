# Rules (93S)

The rules for this repo's part of the alignment, then the learned rules. Read before every unit. Any tool adds a learned
rule in the same commit as the fix that confirmed it, newest last: `- YYYY-MM-DD <area>: <rule>. (<evidence>)`.

## Who decides what (all games)

| Category | Decided by |
|---|---|
| Name of a routine several games share | the earliest game that has it (92G is the root); a fix goes to the earliest repo first, then down the lineage |
| Name of a feature new in year N | that year's Genesis game (94G for 94S and 94PC, 95G for 95S and 95PC) |
| Name of a platform-only job | the earlier repo on that platform (93S for 94S, 94PC for 95PC), else what the code does |
| Same name, different job | the earlier meaning keeps the name |
| Top folder or file | the same-year Genesis file |
| RAM order | the merged order (92G, 93G, 94G, 93S, 94S, then 95G, 96G) |
| Data, assets, banks | the earlier repo on the same platform |
| Order inside a file | ROM order (the report re-sorts for display) |
| History | `docs/name_map.csv` only, never source comments |

## This repo

- Names: the 93G name when the body is the same routine. SNES-only jobs (password, SPC upload, DMA, pads) keep the 93S name.
- Folders: `src/routines/<93G module>/<area>/`. Inside `hockey/`, each area is named after the one 94G file its routines went to (`collide`, `setup`, `game` = hockey94, `replay`, `title`, `optsetup`, `scout`; `password` and `playoffs` are setup94).
- Small data tables go in `src/data/tables/`, as in 94S.
- Banks: one file per bank in `src/banks/`, `org` then `incsrc` lines in ROM order. Data in `src/data/<category>/`.

## Learned

