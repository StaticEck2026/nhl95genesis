# NHL 95 segment map

The rows are in `SEGMENT_AGENT.md` "ROM map", made from `tools/segmap95.json`.

## Rerun

```
pip3 install -r tools/requirements.txt
tools/build_ref.sh /tmp/NHL94Genesis            # 94 built bit-perfect under wine
python3 tools/fingerprint_map.py --ref /tmp/NHL94Genesis
python3 tools/verify_segmap.py                   # exit 1 on any failure
python3 tools/apply_segmap.py --ref /tmp/NHL94Genesis
```

`fingerprint_map.py` takes about 15 s in total. Reading the IDA listing takes 10.6 s of that, and the index and placement take 1.4 s. `verify_segmap.py` takes about 11 s. Hand cuts go in `tools/segmap95_overrides.json`. For another game, pass `--ref-game`, `--rom`, `--lst`, `--suffix`, `--overrides` and `--out`.

## Method

- **Reference units:** every 94 label span, split into code and data runs.
- **Normalization:** code becomes normalized 68k tokens. Mnemonics, addressing modes, registers and small immediates are kept. Absolute, RAM, ROM and PC-relative operands and branch targets are masked. Data keeps its raw bytes, with symbolic `dc.w` / `dc.l` operands masked.
- **Matching:** hash indexes of 8-token code windows and 16-byte data windows are matched in one pass over the 95 ROM. The best diagonals are then refined.
- **Placement:** units are placed globally (unique matches first, then by neighbours), followed by a search in the gaps. Operand cross-references from matched instructions then place units that no fingerprint found.
- **Listing addresses:** the IDA listing has no address column. Addresses come from directive sizes and capstone instruction sizes, checked at 3965 hex-named labels. Inline `jsr` parameters printed as instructions are resized by learning and by unique local repair. 29 labels still disagree, and no boundary may fall in the 5369 bytes they leave untrusted.

## Result

`verify_segmap.py` passes:

- 56 rows (55 segments and the `$FF` fill) tile `$000000-$1FFFFF`.
- The concatenated slices are identical to `lst/nhl95.bin` (SHA-1 `09e87b076aa4cd6f…`).
- All 55 boundaries are listing lines outside the untrusted stretches. 38 of them sit on a label. Of the other 17, 13 directly follow an `rts`, `bra` or `jmp`, and 4 are cuts between data tables (`frames95`, `sram95`, `graphics95_02`, `credits95`).
- `src/nhl95.asm` assembles with 0 errors into 2 MB.

Of the 94 code bytes, 73% are found at a similarity of 0.5 or more (1067 of 2253 units). For data the figure is 25%, because rosters, SPA tables, music and graphics were rebuilt for 95.

NHL 95 is re-linked routine by routine. The 94 files are interleaved, while each keeps its own internal order, so most 94 files map to several rows (`checks95_01` … `checks95_07`). 254 units sit in a row owned by another 94 file (`moved_in` in the JSON). `attract94`, `goalie94`, `crowd94` and `optsetup94` have no row: their routines are spread over other rows.

The main unplaced 94 material (`missing` in the JSON):

| 94 file | Unplaced bytes | What it is |
|---|---|---|
| graphics94 | 444 KB | graphics |
| sound94 | 127 KB | music and SFX command streams |
| teamdata94 | 10 KB | rosters |
| cards94 | 7 KB | |
| frames94 | 7 KB | |
| optsetup94 | 5 KB | |

## New in 95

| Row | Range | Contents |
|---|---|---|
| season95 | `$8DF5A-$920BD` | season mode |
| trade95 | `$962EE-$97C53` | schedule and trades |
| create95 | `$97C54-$9ACE5` | create player |
| awards95 | `$9C6F0-$9D9BF` | season awards |
| credits95 | `$1A6C28-$1A72BF` | credits text, in the 94 format |

Further new 95 material sits inside existing rows:

- `main95`: the region lock.
- `sound95_01`: the new sound driver and Z80 program at `$AF44-$BD85`.
- `sram95`: three save RAM routines at `$9972-$9AC7`.
- `graphics95_01` / `graphics95_02`: most of the art.

## Boundaries that need a judgment call

1. **main95 / teamdata95 at `$772`:** main95 holds the dc.l 0 at `$69A` (94 kept it in teamdata94) and 94 `Begin` (from hockey94).
2. **frames95 `$8C76-$93FF`:** unmatched data. `byte_8DD8` is read by season code, so this may belong to season95.
3. **sram95 `$9400-$9721`:** 94 `ScrollArrowTbl` (stats94) and unmatched tables before `InitSaveRAM` at `$9722`.
4. **hockey95 `$9AC8-$A203`:** no byte match. It is identified by 95 `Begin`'s `jmp $9AC8` and by `StartGame` / `StartPer` at similarity 0.56 / 0.74.
5. **setup95_01 `$A656-$AF43`:** mixes setup94, input94 and title94 routines.
6. **sound95_01 / sound95_02:** 94 music data is unplaced. sound95_02 (`$7E0E0`) is a copy of 94 `Z80_Program_Code` far from the driver.
7. **menu95 tail `$7EFFC-$7F97D`:** goalie / pause menu text. menu95 is 12% matched.
8. **season95 start (`$8DF5A`), trade95 (the schedule half could be its own row), create95 / cards95_01 at `sub_9ACE6`:** 94 `NameEntryScreen`; create95 also reuses 94 `NameEntryFramer` at `$986B6`.
9. **Low coverage, so the range is weak:** checks95_05 (27%), stats95_01 (22%), graphics95_01 (15% of 1 MB), graphics95_02 (0%).
10. **title95_02 at `sub_A12AA`:** newTitleScreen. Its first matched unit is at `$A1376`.
11. **credits95:** its counterpart is teamdata94 `Credits`, but 95 moved it next to the checksum.
