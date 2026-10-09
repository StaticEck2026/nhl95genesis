;	NHL 95 placeholder. Not matched.
;	New in 95: season schedule data, split from the frames95 placeholder.
;	Org $008DD8, end $009721 (lst/nhl95.bin.lst byte_8DD8; sub_9722 is 94 InitSaveRAM). Read by the season code (season95):
;	move.b (byte_8DD8).l (IDA sub_8E26A), movea.l #$8DD8 / #$8DD9 (sub_8E2AC and others).
;	Transcribe lst/nhl95.bin.lst into this file.
