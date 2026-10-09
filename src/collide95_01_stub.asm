;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;
;	collide95_01 segment stub. Retail $07A762-$07C511.
;
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

; .region code
	org	$7A762

; includes for stubs to replace removed code
	include	stubinc\ports.inc	;IO_* / VDP_* ports
	include	stubinc\equals.inc	;VDP status bits
	include	stubinc\ram_addrs.inc	;RAM names

; External addresses outside $07A762-$07C511, read from lst/nhl95.bin.
setc1player = $AD80		;IDA: loc_AD80. used at $7BBDE, $7BC16, $7BC4E, $7BC78 (setup95_01)
setc2player = $AD8A		;IDA: loc_AD8A. used at $7BBEC, $7BC24, $7BC40, $7BC86 (setup95_01)
setc3player = $AD96		;IDA: loc_AD96. used at $7BBFA, $7BC08, $7BC5C, $7BC94 (setup95_01)
setc4player = $ADA2		;IDA: loc_ADA2. used at $7BBD0, $7BC32, $7BC6A, $7BCA2 (setup95_01)
sfx = $677AC			;IDA: sub_677AC. used at $7A9DE, $7AAB2, $7AAF4, $7B3A0, $7B8FA, $7B9FC, $7BCD0, $7BD86, $7BEBA, $7C200 (sound95_01)
song = $678C2			;IDA: sub_678C2. used at $7B50C, $7BB10, $7C1F6 (sound95_01)
newcheck = $682B0		;IDA: sub_682B0. used at $7AC88, $7B514 (sound95_01)
rtss2 = $79CC8			;IDA: locret_79CC8. used at $7AFCA, $7B0EE, $7B0F8, $7C15A. An rts (video95_01)
nodiag = $7A488			;IDA: sub_7A488. used at $7A762, $7A7AA (video95_02)
ReadMenuJoy = $7A6AA		;IDA: sub_7A6AA. used at $7A7A6 (video95_02)
sroot = $7C512			;IDA: sub_7C512. used at $7A926, $7BF84, $7C0FC (video95_03)
vtoa = $7C586			;IDA: sub_7C586. used at $7AD9A, $7AE16, $7AF7A, $7AFDA, $7B196, $7C170 (video95_03)
randomd0s = $7C62E		;IDA: sub_7C62E. used at $7BD54, $7BD60, $7BEDC, $7BEEA (video95_03)
randomd0 = $7C63A		;IDA: sub_7C63A. used at $7AA8C, $7ADF4, $7AE96, $7AF62, $7B478, $7B996, $7BD6C, $7BEC4, $7C290, $7C4D0 (video95_03)
GetHot = $7C672			;IDA: sub_7C672. used at $7A7F8, $7B65E, $7BCF2, $7C254 (video95_03)
makepde = $7CAA6		;IDA: sub_7CAA6. used at $7B976, $7B986, $7B9C0, $7B9D6 (video95_03)
puckflip = $81336		;IDA: sub_81336. used at $7AA96, $7BD06, $7BD74, $7BEF4, $7C260
a2touchpuck = $8142C		;IDA: sub_8142C. used at $7BA02, $7BCC6, $7C1CA
onetimershot = $82EFE		;IDA: sub_82EFE. used at $7BA8C
Stop4Pen = $8901C		;IDA: sub_8901C. used at $7B4F4
AddPenalty = $89140		;IDA: sub_89140. used at $7AED2, $7AEFA, $7AFAE, $7B07C, $7C4EE
AddPenalty2 = $8916E		;IDA: sub_8916E. used at $7AA2C, $7B4DC, $7B4EE, $7C03A
checkagr = $8996E		;IDA: sub_8996E. used at $7AEB0, $7AED8, $7AF96, $7B056 (data95_02)
ChkShotStat = $8ABDA		;IDA: sub_8ABDA. used at $7BB3E, $7BE96, $7C1C4
SetSPA = $8BC9A			;IDA: sub_8BC9A. used at $7A9D2, $7AE28, $7B030, $7B050, $7B094, $7B28A, $7B42E, $7B494, $7B4C0, $7BD42
Goal = $8C304			;IDA: loc_8C304. used at $7BE90. checkgoal .goal in 94
LockScroll = $8C8EC		;IDA: sub_8C8EC. used at $7A98C. 95 only: xc1 / yc1 = Hpos / Vpos, sfslock
PenShotChk = $9EEC4		;IDA: sub_9EEC4. used at $7AECC, $7AEF4, $7AFA8, $7B076
setInjuryType = $9F012		;IDA: sub_9F012. used at $7B49C

; Main segment code
	include	collide95_01.asm
