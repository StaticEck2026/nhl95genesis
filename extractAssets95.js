// NHL 95 asset extractor.
// Usage: node extractAssets95.js lst/nhl95.bin
// Add a slice only after the listing label and the retail range are confirmed.
const fs = require('fs');
const path = require('path');
const romPath = process.argv[2] || 'lst/nhl95.bin';
if (!fs.existsSync(romPath)) {
  console.error('Missing ' + romPath + '. Put the IDA ROM at lst/nhl95.bin first.');
  process.exit(1);
}
// Slices: name, folder under Extracted, start, end (exclusive).
const assets = [
    // NHL 95 team palettes, src/teamdata95.asm .pad of each team block (block + $C): home then visitor, 32 bytes each, in ROM order.
    // Every one differs from 94, so each is the 94 file stem (93 stem for MIN / LI / NY / TBY) with 95 added.
    { name: 'ASEh95.pal', folder: 'NHL95/Graphics/Pals', start: 0x000007EE, end: 0x0000080E }, // ASE home
    { name: 'ASEv95.pal', folder: 'NHL95/Graphics/Pals', start: 0x0000080E, end: 0x0000082E }, // ASE visitor
    { name: 'ASWh95.pal', folder: 'NHL95/Graphics/Pals', start: 0x00000ABE, end: 0x00000ADE }, // ASW home
    { name: 'ASWv95.pal', folder: 'NHL95/Graphics/Pals', start: 0x00000ADE, end: 0x00000AFE }, // ASW visitor
    { name: 'ANHh95.pal', folder: 'NHL95/Graphics/Pals', start: 0x00000D72, end: 0x00000D92 }, // ANH home
    { name: 'ANHv95.pal', folder: 'NHL95/Graphics/Pals', start: 0x00000D92, end: 0x00000DB2 }, // ANH visitor
    { name: 'BOSh95.pal', folder: 'NHL95/Graphics/Pals', start: 0x00001036, end: 0x00001056 }, // BOS home
    { name: 'BOSv95.pal', folder: 'NHL95/Graphics/Pals', start: 0x00001056, end: 0x00001076 }, // BOS visitor
    { name: 'BUFh95.pal', folder: 'NHL95/Graphics/Pals', start: 0x00001310, end: 0x00001330 }, // BUF home
    { name: 'BUFv95.pal', folder: 'NHL95/Graphics/Pals', start: 0x00001330, end: 0x00001350 }, // BUF visitor
    { name: 'CGYh95.pal', folder: 'NHL95/Graphics/Pals', start: 0x000015EC, end: 0x0000160C }, // CGY home
    { name: 'CGYv95.pal', folder: 'NHL95/Graphics/Pals', start: 0x0000160C, end: 0x0000162C }, // CGY visitor
    { name: 'CHIh95.pal', folder: 'NHL95/Graphics/Pals', start: 0x000018CA, end: 0x000018EA }, // CHI home
    { name: 'CHIv95.pal', folder: 'NHL95/Graphics/Pals', start: 0x000018EA, end: 0x0000190A }, // CHI visitor
    { name: 'DETh95.pal', folder: 'NHL95/Graphics/Pals', start: 0x00001BAA, end: 0x00001BCA }, // DET home
    { name: 'DETv95.pal', folder: 'NHL95/Graphics/Pals', start: 0x00001BCA, end: 0x00001BEA }, // DET visitor
    { name: 'EDMh95.pal', folder: 'NHL95/Graphics/Pals', start: 0x00001EA8, end: 0x00001EC8 }, // EDM home
    { name: 'EDMv95.pal', folder: 'NHL95/Graphics/Pals', start: 0x00001EC8, end: 0x00001EE8 }, // EDM visitor
    { name: 'FLAh95.pal', folder: 'NHL95/Graphics/Pals', start: 0x0000219A, end: 0x000021BA }, // FLA home
    { name: 'FLAv95.pal', folder: 'NHL95/Graphics/Pals', start: 0x000021BA, end: 0x000021DA }, // FLA visitor
    { name: 'HFDh95.pal', folder: 'NHL95/Graphics/Pals', start: 0x0000247A, end: 0x0000249A }, // HFD home
    { name: 'HFDv95.pal', folder: 'NHL95/Graphics/Pals', start: 0x0000249A, end: 0x000024BA }, // HFD visitor
    { name: 'LAh95.pal', folder: 'NHL95/Graphics/Pals', start: 0x0000276E, end: 0x0000278E }, // LA home
    { name: 'LAv95.pal', folder: 'NHL95/Graphics/Pals', start: 0x0000278E, end: 0x000027AE }, // LA visitor
    { name: 'MINh95.pal', folder: 'NHL95/Graphics/Pals', start: 0x00002A30, end: 0x00002A50 }, // DAL home
    { name: 'MINv95.pal', folder: 'NHL95/Graphics/Pals', start: 0x00002A50, end: 0x00002A70 }, // DAL visitor
    { name: 'MTLh95.pal', folder: 'NHL95/Graphics/Pals', start: 0x00002D04, end: 0x00002D24 }, // MTL home
    { name: 'MTLv95.pal', folder: 'NHL95/Graphics/Pals', start: 0x00002D24, end: 0x00002D44 }, // MTL visitor
    { name: 'NJh95.pal', folder: 'NHL95/Graphics/Pals', start: 0x00002FF4, end: 0x00003014 }, // NJ home
    { name: 'NJv95.pal', folder: 'NHL95/Graphics/Pals', start: 0x00003014, end: 0x00003034 }, // NJ visitor
    { name: 'LIh95.pal', folder: 'NHL95/Graphics/Pals', start: 0x000032E6, end: 0x00003306 }, // NYI home
    { name: 'LIv95.pal', folder: 'NHL95/Graphics/Pals', start: 0x00003306, end: 0x00003326 }, // NYI visitor
    { name: 'NYh95.pal', folder: 'NHL95/Graphics/Pals', start: 0x000035D2, end: 0x000035F2 }, // NYR home
    { name: 'NYv95.pal', folder: 'NHL95/Graphics/Pals', start: 0x000035F2, end: 0x00003612 }, // NYR visitor
    { name: 'OTWh95.pal', folder: 'NHL95/Graphics/Pals', start: 0x000038B4, end: 0x000038D4 }, // OTW home
    { name: 'OTWv95.pal', folder: 'NHL95/Graphics/Pals', start: 0x000038D4, end: 0x000038F4 }, // OTW visitor
    { name: 'PHIh95.pal', folder: 'NHL95/Graphics/Pals', start: 0x00003BAA, end: 0x00003BCA }, // PHI home
    { name: 'PHIv95.pal', folder: 'NHL95/Graphics/Pals', start: 0x00003BCA, end: 0x00003BEA }, // PHI visitor
    { name: 'PITh95.pal', folder: 'NHL95/Graphics/Pals', start: 0x00003E88, end: 0x00003EA8 }, // PIT home
    { name: 'PITv95.pal', folder: 'NHL95/Graphics/Pals', start: 0x00003EA8, end: 0x00003EC8 }, // PIT visitor
    { name: 'QUEh95.pal', folder: 'NHL95/Graphics/Pals', start: 0x00004178, end: 0x00004198 }, // QUE home
    { name: 'QUEv95.pal', folder: 'NHL95/Graphics/Pals', start: 0x00004198, end: 0x000041B8 }, // QUE visitor
    { name: 'SJh95.pal', folder: 'NHL95/Graphics/Pals', start: 0x0000445E, end: 0x0000447E }, // SJ home
    { name: 'SJv95.pal', folder: 'NHL95/Graphics/Pals', start: 0x0000447E, end: 0x0000449E }, // SJ visitor
    { name: 'STLh95.pal', folder: 'NHL95/Graphics/Pals', start: 0x00004722, end: 0x00004742 }, // STL home
    { name: 'STLv95.pal', folder: 'NHL95/Graphics/Pals', start: 0x00004742, end: 0x00004762 }, // STL visitor
    { name: 'TBYh95.pal', folder: 'NHL95/Graphics/Pals', start: 0x00004A0A, end: 0x00004A2A }, // TB home
    { name: 'TBYv95.pal', folder: 'NHL95/Graphics/Pals', start: 0x00004A2A, end: 0x00004A4A }, // TB visitor
    { name: 'TORh95.pal', folder: 'NHL95/Graphics/Pals', start: 0x00004CC2, end: 0x00004CE2 }, // TOR home
    { name: 'TORv95.pal', folder: 'NHL95/Graphics/Pals', start: 0x00004CE2, end: 0x00004D02 }, // TOR visitor
    { name: 'VANh95.pal', folder: 'NHL95/Graphics/Pals', start: 0x00004FB4, end: 0x00004FD4 }, // VAN home
    { name: 'VANv95.pal', folder: 'NHL95/Graphics/Pals', start: 0x00004FD4, end: 0x00004FF4 }, // VAN visitor
    { name: 'WPGh95.pal', folder: 'NHL95/Graphics/Pals', start: 0x0000529A, end: 0x000052BA }, // WPG home
    { name: 'WPGv95.pal', folder: 'NHL95/Graphics/Pals', start: 0x000052BA, end: 0x000052DA }, // WPG visitor
    { name: 'WSHh95.pal', folder: 'NHL95/Graphics/Pals', start: 0x00005562, end: 0x00005582 }, // WSH home
    { name: 'WSHv95.pal', folder: 'NHL95/Graphics/Pals', start: 0x00005582, end: 0x000055A2 }, // WSH visitor
    // NHL 95 revframetbl, src/frames95.asm after the SPA tables: one word per sprite frame (1057), the frame RestoreReplayFrame shows for a reverse angle replay.
    // 94 kept it at the end of graphics94 (NHL94/Graphics/revframetbl.bin, 880 words).
    { name: 'revframetbl.bin', folder: 'NHL95/Graphics', start: 0x00008596, end: 0x00008DD8 }, // revframetbl
    // NHL 95 sound driver data, src/sounddrv95.asm: the Z80 program ($BD86, $1B63 bytes loaded by SndLoadZ80, plus its last byte $FF),
    // then the items of the sound bank at $D8EC (SoundBanks) in bank order, named by item type and id.
    { name: 'z80_snd_drv95.bin', folder: 'NHL95/Sound', start: 0x0000BD86, end: 0x0000D8EA }, // Z80Program
    { name: 'snd95_patch_00.bin', folder: 'NHL95/Sound/Bank', start: 0x0000DB22, end: 0x0000DB27 }, // patch 0
    { name: 'snd95_patch_01.bin', folder: 'NHL95/Sound/Bank', start: 0x0000DB27, end: 0x0000DB2C }, // patch 1
    { name: 'snd95_patch_02.bin', folder: 'NHL95/Sound/Bank', start: 0x0000DB2C, end: 0x0000DB31 }, // patch 2
    { name: 'snd95_patch_03.bin', folder: 'NHL95/Sound/Bank', start: 0x0000DB31, end: 0x0000DB36 }, // patch 3
    { name: 'snd95_patch_04.bin', folder: 'NHL95/Sound/Bank', start: 0x0000DB36, end: 0x0000DB3B }, // patch 4
    { name: 'snd95_patch_05.bin', folder: 'NHL95/Sound/Bank', start: 0x0000DB3B, end: 0x0000DB40 }, // patch 5
    { name: 'snd95_patch_06.bin', folder: 'NHL95/Sound/Bank', start: 0x0000DB40, end: 0x0000DB45 }, // patch 6
    { name: 'snd95_patch_07.bin', folder: 'NHL95/Sound/Bank', start: 0x0000DB45, end: 0x0000DB4A }, // patch 7
    { name: 'snd95_patch_08.bin', folder: 'NHL95/Sound/Bank', start: 0x0000DB4A, end: 0x0000DB4F }, // patch 8
    { name: 'snd95_patch_09.bin', folder: 'NHL95/Sound/Bank', start: 0x0000DB4F, end: 0x0000DB54 }, // patch 9
    { name: 'snd95_patch_0A.bin', folder: 'NHL95/Sound/Bank', start: 0x0000DB54, end: 0x0000DB59 }, // patch 10
    { name: 'snd95_patch_0B.bin', folder: 'NHL95/Sound/Bank', start: 0x0000DB59, end: 0x0000DB80 }, // patch 11
    { name: 'snd95_patch_0C.bin', folder: 'NHL95/Sound/Bank', start: 0x0000DB80, end: 0x0000DB85 }, // patch 12
    { name: 'snd95_patch_0D.bin', folder: 'NHL95/Sound/Bank', start: 0x0000DB85, end: 0x0000DBAC }, // patch 13
    { name: 'snd95_patch_0E.bin', folder: 'NHL95/Sound/Bank', start: 0x0000DBAC, end: 0x0000DBD3 }, // patch 14
    { name: 'snd95_patch_11.bin', folder: 'NHL95/Sound/Bank', start: 0x0000DBD3, end: 0x0000DBFA }, // patch 17
    { name: 'snd95_patch_13.bin', folder: 'NHL95/Sound/Bank', start: 0x0000DBFA, end: 0x0000DC0A }, // patch 19
    { name: 'snd95_patch_14.bin', folder: 'NHL95/Sound/Bank', start: 0x0000DC0A, end: 0x0000DC1A }, // patch 20
    { name: 'snd95_patch_15.bin', folder: 'NHL95/Sound/Bank', start: 0x0000DC1A, end: 0x0000DC41 }, // patch 21
    { name: 'snd95_patch_16.bin', folder: 'NHL95/Sound/Bank', start: 0x0000DC41, end: 0x0000DC68 }, // patch 22
    { name: 'snd95_patch_18.bin', folder: 'NHL95/Sound/Bank', start: 0x0000DC68, end: 0x0000DC8F }, // patch 24
    { name: 'snd95_patch_19.bin', folder: 'NHL95/Sound/Bank', start: 0x0000DC8F, end: 0x0000DCB6 }, // patch 25
    { name: 'snd95_patch_1B.bin', folder: 'NHL95/Sound/Bank', start: 0x0000DCB6, end: 0x0000DCDD }, // patch 27
    { name: 'snd95_patch_1C.bin', folder: 'NHL95/Sound/Bank', start: 0x0000DCDD, end: 0x0000DD04 }, // patch 28
    { name: 'snd95_patch_1D.bin', folder: 'NHL95/Sound/Bank', start: 0x0000DD04, end: 0x0000DD2B }, // patch 29
    { name: 'snd95_patch_33.bin', folder: 'NHL95/Sound/Bank', start: 0x0000DD2B, end: 0x0000DD30 }, // patch 51
    { name: 'snd95_patch_36.bin', folder: 'NHL95/Sound/Bank', start: 0x0000DD30, end: 0x0000DD35 }, // patch 54
    { name: 'snd95_patch_38.bin', folder: 'NHL95/Sound/Bank', start: 0x0000DD35, end: 0x0000DD3A }, // patch 56
    { name: 'snd95_patch_39.bin', folder: 'NHL95/Sound/Bank', start: 0x0000DD3A, end: 0x0000DD3F }, // patch 57
    { name: 'snd95_patch_3B.bin', folder: 'NHL95/Sound/Bank', start: 0x0000DD3F, end: 0x0000DD44 }, // patch 59
    { name: 'snd95_patch_3D.bin', folder: 'NHL95/Sound/Bank', start: 0x0000DD44, end: 0x0000DD49 }, // patch 61
    { name: 'snd95_patch_3E.bin', folder: 'NHL95/Sound/Bank', start: 0x0000DD49, end: 0x0000DD70 }, // patch 62
    { name: 'snd95_patch_3F.bin', folder: 'NHL95/Sound/Bank', start: 0x0000DD70, end: 0x0000DD97 }, // patch 63
    { name: 'snd95_patch_40.bin', folder: 'NHL95/Sound/Bank', start: 0x0000DD97, end: 0x0000DDBE }, // patch 64
    { name: 'snd95_patch_41.bin', folder: 'NHL95/Sound/Bank', start: 0x0000DDBE, end: 0x0000DDC3 }, // patch 65
    { name: 'snd95_patch_42.bin', folder: 'NHL95/Sound/Bank', start: 0x0000DDC3, end: 0x0000DDC8 }, // patch 66
    { name: 'snd95_patch_43.bin', folder: 'NHL95/Sound/Bank', start: 0x0000DDC8, end: 0x0000DDCD }, // patch 67
    { name: 'snd95_patch_44.bin', folder: 'NHL95/Sound/Bank', start: 0x0000DDCD, end: 0x0000DDD2 }, // patch 68
    { name: 'snd95_patch_45.bin', folder: 'NHL95/Sound/Bank', start: 0x0000DDD2, end: 0x0000DDF9 }, // patch 69
    { name: 'snd95_patch_46.bin', folder: 'NHL95/Sound/Bank', start: 0x0000DDF9, end: 0x0000DDFE }, // patch 70
    { name: 'snd95_patch_47.bin', folder: 'NHL95/Sound/Bank', start: 0x0000DDFE, end: 0x0000DE25 }, // patch 71
    { name: 'snd95_patch_48.bin', folder: 'NHL95/Sound/Bank', start: 0x0000DE25, end: 0x0000DE2A }, // patch 72
    { name: 'snd95_patch_49.bin', folder: 'NHL95/Sound/Bank', start: 0x0000DE2A, end: 0x0000DE51 }, // patch 73
    { name: 'snd95_sample_00.bin', folder: 'NHL95/Sound/Bank', start: 0x0000DE51, end: 0x0000FF94 }, // sample 0
    { name: 'snd95_sample_01.bin', folder: 'NHL95/Sound/Bank', start: 0x0000FF94, end: 0x000101BB }, // sample 1
    { name: 'snd95_sample_02.bin', folder: 'NHL95/Sound/Bank', start: 0x000101BB, end: 0x00012286 }, // sample 2
    { name: 'snd95_sample_03.bin', folder: 'NHL95/Sound/Bank', start: 0x00012286, end: 0x00012AE9 }, // sample 3
    { name: 'snd95_sample_04.bin', folder: 'NHL95/Sound/Bank', start: 0x00012AE9, end: 0x000134EC }, // sample 4
    { name: 'snd95_sample_05.bin', folder: 'NHL95/Sound/Bank', start: 0x000134EC, end: 0x000143F5 }, // sample 5
    { name: 'snd95_sample_06.bin', folder: 'NHL95/Sound/Bank', start: 0x000143F5, end: 0x00015318 }, // sample 6
    { name: 'snd95_sample_07.bin', folder: 'NHL95/Sound/Bank', start: 0x00015318, end: 0x000161DB }, // sample 7
    { name: 'snd95_sample_08.bin', folder: 'NHL95/Sound/Bank', start: 0x000161DB, end: 0x000172AE }, // sample 8
    { name: 'snd95_sample_09.bin', folder: 'NHL95/Sound/Bank', start: 0x000172AE, end: 0x000175DD }, // sample 9
    { name: 'snd95_sample_0A.bin', folder: 'NHL95/Sound/Bank', start: 0x000175DD, end: 0x00017930 }, // sample 10
    { name: 'snd95_sample_0B.bin', folder: 'NHL95/Sound/Bank', start: 0x00017930, end: 0x00018EF2 }, // sample 11
    { name: 'snd95_sample_0C.bin', folder: 'NHL95/Sound/Bank', start: 0x00018EF2, end: 0x00019F37 }, // sample 12
    { name: 'snd95_sample_0E.bin', folder: 'NHL95/Sound/Bank', start: 0x00019F37, end: 0x00023AFA }, // sample 14
    { name: 'snd95_sample_10.bin', folder: 'NHL95/Sound/Bank', start: 0x00023AFA, end: 0x00032723 }, // sample 16
    { name: 'snd95_sample_11.bin', folder: 'NHL95/Sound/Bank', start: 0x00032723, end: 0x00034C4B }, // sample 17
    { name: 'snd95_sample_13.bin', folder: 'NHL95/Sound/Bank', start: 0x00034C4B, end: 0x0003A419 }, // sample 19
    { name: 'snd95_sample_15.bin', folder: 'NHL95/Sound/Bank', start: 0x0003A419, end: 0x0003C2E2 }, // sample 21
    { name: 'snd95_sample_16.bin', folder: 'NHL95/Sound/Bank', start: 0x0003C2E2, end: 0x00049365 }, // sample 22
    { name: 'snd95_sample_17.bin', folder: 'NHL95/Sound/Bank', start: 0x00049365, end: 0x0004DB35 }, // sample 23
    { name: 'snd95_sample_18.bin', folder: 'NHL95/Sound/Bank', start: 0x0004DB35, end: 0x0004F038 }, // sample 24
    { name: 'snd95_sample_19.bin', folder: 'NHL95/Sound/Bank', start: 0x0004F038, end: 0x00050B7B }, // sample 25
    { name: 'snd95_sample_1B.bin', folder: 'NHL95/Sound/Bank', start: 0x00050B7B, end: 0x0005239D }, // sample 27
    { name: 'snd95_sample_1D.bin', folder: 'NHL95/Sound/Bank', start: 0x0005239D, end: 0x000525CF }, // sample 29
    { name: 'snd95_song_00.bin', folder: 'NHL95/Sound/Bank', start: 0x000525CF, end: 0x00056CCA }, // song 0
    { name: 'snd95_song_01.bin', folder: 'NHL95/Sound/Bank', start: 0x00056CCA, end: 0x0005984C }, // song 1
    { name: 'snd95_song_02.bin', folder: 'NHL95/Sound/Bank', start: 0x0005984C, end: 0x0005CDD3 }, // song 2
    { name: 'snd95_song_03.bin', folder: 'NHL95/Sound/Bank', start: 0x0005CDD3, end: 0x00060D06 }, // song 3
    { name: 'snd95_song_04.bin', folder: 'NHL95/Sound/Bank', start: 0x00060D06, end: 0x00060D12 }, // song 4
    { name: 'snd95_song_05.bin', folder: 'NHL95/Sound/Bank', start: 0x00060D12, end: 0x00060D1E }, // song 5
    { name: 'snd95_song_06.bin', folder: 'NHL95/Sound/Bank', start: 0x00060D1E, end: 0x00060D2A }, // song 6
    { name: 'snd95_song_07.bin', folder: 'NHL95/Sound/Bank', start: 0x00060D2A, end: 0x00060D36 }, // song 7
    { name: 'snd95_song_08.bin', folder: 'NHL95/Sound/Bank', start: 0x00060D36, end: 0x00060D42 }, // song 8
    { name: 'snd95_song_09.bin', folder: 'NHL95/Sound/Bank', start: 0x00060D42, end: 0x00060D4E }, // song 9
    { name: 'snd95_song_0A.bin', folder: 'NHL95/Sound/Bank', start: 0x00060D4E, end: 0x00060D5A }, // song 10
    { name: 'snd95_song_0B.bin', folder: 'NHL95/Sound/Bank', start: 0x00060D5A, end: 0x00060D66 }, // song 11
    { name: 'snd95_song_0E.bin', folder: 'NHL95/Sound/Bank', start: 0x00060D66, end: 0x00060D74 }, // song 14
    { name: 'snd95_song_10.bin', folder: 'NHL95/Sound/Bank', start: 0x00060D74, end: 0x00060D82 }, // song 16
    { name: 'snd95_song_11.bin', folder: 'NHL95/Sound/Bank', start: 0x00060D82, end: 0x00060D8E }, // song 17
    { name: 'snd95_song_13.bin', folder: 'NHL95/Sound/Bank', start: 0x00060D8E, end: 0x00060D9A }, // song 19
    { name: 'snd95_song_15.bin', folder: 'NHL95/Sound/Bank', start: 0x00060D9A, end: 0x00060DA6 }, // song 21
    { name: 'snd95_song_16.bin', folder: 'NHL95/Sound/Bank', start: 0x00060DA6, end: 0x00060E0A }, // song 22
    { name: 'snd95_song_17.bin', folder: 'NHL95/Sound/Bank', start: 0x00060E0A, end: 0x00060E5E }, // song 23
    { name: 'snd95_song_18.bin', folder: 'NHL95/Sound/Bank', start: 0x00060E5E, end: 0x00060E6A }, // song 24
    { name: 'snd95_song_19.bin', folder: 'NHL95/Sound/Bank', start: 0x00060E6A, end: 0x00060E76 }, // song 25
    { name: 'snd95_song_1A.bin', folder: 'NHL95/Sound/Bank', start: 0x00060E76, end: 0x00060E82 }, // song 26
    { name: 'snd95_song_1B.bin', folder: 'NHL95/Sound/Bank', start: 0x00060E82, end: 0x00060E8E }, // song 27
    { name: 'snd95_song_1C.bin', folder: 'NHL95/Sound/Bank', start: 0x00060E8E, end: 0x00060E9A }, // song 28
    { name: 'snd95_song_1D.bin', folder: 'NHL95/Sound/Bank', start: 0x00060E9A, end: 0x00060EA6 }, // song 29
    { name: 'snd95_song_1E.bin', folder: 'NHL95/Sound/Bank', start: 0x00060EA6, end: 0x00060EB4 }, // song 30
    { name: 'snd95_song_20.bin', folder: 'NHL95/Sound/Bank', start: 0x00060EB4, end: 0x00060EC0 }, // song 32
    { name: 'snd95_song_21.bin', folder: 'NHL95/Sound/Bank', start: 0x00060EC0, end: 0x00060ECC }, // song 33
    { name: 'snd95_song_22.bin', folder: 'NHL95/Sound/Bank', start: 0x00060ECC, end: 0x00060ED8 }, // song 34
    { name: 'snd95_song_23.bin', folder: 'NHL95/Sound/Bank', start: 0x00060ED8, end: 0x00060EE4 }, // song 35
    { name: 'snd95_song_24.bin', folder: 'NHL95/Sound/Bank', start: 0x00060EE4, end: 0x00060EF0 }, // song 36
    { name: 'snd95_song_25.bin', folder: 'NHL95/Sound/Bank', start: 0x00060EF0, end: 0x00060EFC }, // song 37
    { name: 'snd95_song_26.bin', folder: 'NHL95/Sound/Bank', start: 0x00060EFC, end: 0x00061217 }, // song 38
    { name: 'snd95_song_27.bin', folder: 'NHL95/Sound/Bank', start: 0x00061217, end: 0x0006122B }, // song 39
    { name: 'snd95_song_28.bin', folder: 'NHL95/Sound/Bank', start: 0x0006122B, end: 0x0006123F }, // song 40
    { name: 'snd95_song_29.bin', folder: 'NHL95/Sound/Bank', start: 0x0006123F, end: 0x0006124B }, // song 41
    { name: 'snd95_song_32.bin', folder: 'NHL95/Sound/Bank', start: 0x0006124B, end: 0x0006143D }, // song 50
    { name: 'snd95_song_33.bin', folder: 'NHL95/Sound/Bank', start: 0x0006143D, end: 0x00061921 }, // song 51
    { name: 'snd95_song_34.bin', folder: 'NHL95/Sound/Bank', start: 0x00061921, end: 0x00061B75 }, // song 52
    { name: 'snd95_song_35.bin', folder: 'NHL95/Sound/Bank', start: 0x00061B75, end: 0x00061E23 }, // song 53
    { name: 'snd95_song_36.bin', folder: 'NHL95/Sound/Bank', start: 0x00061E23, end: 0x0006213F }, // song 54
    { name: 'snd95_song_37.bin', folder: 'NHL95/Sound/Bank', start: 0x0006213F, end: 0x000623E7 }, // song 55
    { name: 'snd95_song_38.bin', folder: 'NHL95/Sound/Bank', start: 0x000623E7, end: 0x00062683 }, // song 56
    { name: 'snd95_song_39.bin', folder: 'NHL95/Sound/Bank', start: 0x00062683, end: 0x0006282F }, // song 57
    { name: 'snd95_song_3A.bin', folder: 'NHL95/Sound/Bank', start: 0x0006282F, end: 0x00062C13 }, // song 58
    { name: 'snd95_song_3B.bin', folder: 'NHL95/Sound/Bank', start: 0x00062C13, end: 0x00062E57 }, // song 59
    { name: 'snd95_song_3C.bin', folder: 'NHL95/Sound/Bank', start: 0x00062E57, end: 0x00062E87 }, // song 60
    { name: 'snd95_song_3D.bin', folder: 'NHL95/Sound/Bank', start: 0x00062E87, end: 0x0006328B }, // song 61
    { name: 'snd95_song_3E.bin', folder: 'NHL95/Sound/Bank', start: 0x0006328B, end: 0x000635CC }, // song 62
    { name: 'snd95_song_3F.bin', folder: 'NHL95/Sound/Bank', start: 0x000635CC, end: 0x000637D4 }, // song 63
    { name: 'snd95_song_40.bin', folder: 'NHL95/Sound/Bank', start: 0x000637D4, end: 0x00063A52 }, // song 64
    { name: 'snd95_song_41.bin', folder: 'NHL95/Sound/Bank', start: 0x00063A52, end: 0x00063DAA }, // song 65
    { name: 'snd95_song_42.bin', folder: 'NHL95/Sound/Bank', start: 0x00063DAA, end: 0x00063ED6 }, // song 66
    { name: 'snd95_song_43.bin', folder: 'NHL95/Sound/Bank', start: 0x00063ED6, end: 0x0006429A }, // song 67
    { name: 'snd95_song_44.bin', folder: 'NHL95/Sound/Bank', start: 0x0006429A, end: 0x000644A6 }, // song 68
    { name: 'snd95_song_45.bin', folder: 'NHL95/Sound/Bank', start: 0x000644A6, end: 0x0006471A }, // song 69
    { name: 'snd95_song_46.bin', folder: 'NHL95/Sound/Bank', start: 0x0006471A, end: 0x00064872 }, // song 70
    { name: 'snd95_song_47.bin', folder: 'NHL95/Sound/Bank', start: 0x00064872, end: 0x00064C2E }, // song 71
    { name: 'snd95_song_48.bin', folder: 'NHL95/Sound/Bank', start: 0x00064C2E, end: 0x00065052 }, // song 72
    { name: 'snd95_song_49.bin', folder: 'NHL95/Sound/Bank', start: 0x00065052, end: 0x00065452 }, // song 73
    { name: 'snd95_song_4A.bin', folder: 'NHL95/Sound/Bank', start: 0x00065452, end: 0x00065767 }, // song 74
    { name: 'snd95_song_4B.bin', folder: 'NHL95/Sound/Bank', start: 0x00065767, end: 0x00065ACC }, // song 75
    { name: 'snd95_song_4C.bin', folder: 'NHL95/Sound/Bank', start: 0x00065ACC, end: 0x00065E2F }, // song 76
    { name: 'snd95_song_4D.bin', folder: 'NHL95/Sound/Bank', start: 0x00065E2F, end: 0x000660F8 }, // song 77
    { name: 'snd95_song_4E.bin', folder: 'NHL95/Sound/Bank', start: 0x000660F8, end: 0x00066514 }, // song 78
    { name: 'snd95_song_4F.bin', folder: 'NHL95/Sound/Bank', start: 0x00066514, end: 0x000669A0 }, // song 79
    { name: 'snd95_song_50.bin', folder: 'NHL95/Sound/Bank', start: 0x000669A0, end: 0x00066BF5 }, // song 80
    { name: 'snd95_song_51.bin', folder: 'NHL95/Sound/Bank', start: 0x00066BF5, end: 0x00066E1F }, // song 81
    { name: 'snd95_song_52.bin', folder: 'NHL95/Sound/Bank', start: 0x00066E1F, end: 0x00066F0F }, // song 82
    { name: 'snd95_song_53.bin', folder: 'NHL95/Sound/Bank', start: 0x00066F0F, end: 0x00067183 }, // song 83
    { name: 'snd95_song_54.bin', folder: 'NHL95/Sound/Bank', start: 0x00067183, end: 0x00067257 }, // song 84
    { name: 'snd95_song_55.bin', folder: 'NHL95/Sound/Bank', start: 0x00067257, end: 0x00067680 }, // song 85
    { name: 'snd95_list_00.bin', folder: 'NHL95/Sound/Bank', start: 0x00067680, end: 0x00067699 }, // list 0
    { name: 'snd95_list_01.bin', folder: 'NHL95/Sound/Bank', start: 0x00067699, end: 0x000676D8 }, // list 1
    // NHL 95 sound95_01: the 94 PCM samples and FM patches (same bytes as the 94 files, 94 address + $4D2BA).
    { name: 'sfx_shotbh_pcm.bin', folder: 'NHL95/Sound', start: 0x0006834E, end: 0x00068542 }, // 94 file, same bytes (94 $1B094)
    { name: 'sfx_pass_pcm.bin', folder: 'NHL95/Sound', start: 0x00068542, end: 0x0006926F }, // 94 file, same bytes (94 $1B288)
    { name: 'sfx_oooh_pcm.bin', folder: 'NHL95/Sound', start: 0x00069270, end: 0x0006C4B4 }, // 94 file, same bytes (94 $1BFB6)
    { name: 'sfx_crowdboo_pcm.bin', folder: 'NHL95/Sound', start: 0x0006C4B4, end: 0x0006EA01 }, // 94 file, same bytes (94 $1F1FA)
    { name: 'sfx_check_pcm.bin', folder: 'NHL95/Sound', start: 0x0006EA02, end: 0x00070954 }, // 94 file, same bytes (94 $21748)
    { name: 'sfx_crowdcheer_pcm.bin', folder: 'NHL95/Sound', start: 0x00070954, end: 0x00073834 }, // 94 file, same bytes (94 $2369A)
    { name: 'sfx_id_0E_pcm.bin', folder: 'NHL95/Sound', start: 0x00073834, end: 0x000772B3 }, // 94 file, same bytes (94 $2657A)
    { name: 'sfx_playerwall_pcm.bin', folder: 'NHL95/Sound', start: 0x000772B4, end: 0x00077764 }, // 94 file, same bytes (94 $29FFA)
    { name: 'sfx_check2_pcm.bin', folder: 'NHL95/Sound', start: 0x00077764, end: 0x00078193 }, // 94 file, same bytes (94 $2A4AA)
    { name: 'sfx_hithigh_pcm.bin', folder: 'NHL95/Sound', start: 0x00078194, end: 0x000786EA }, // 94 file, same bytes (94 $2AEDA)
    { name: 'sfx_shotfh_pcm.bin', folder: 'NHL95/Sound', start: 0x000786EA, end: 0x000792A2 }, // 94 file, same bytes (94 $2B430)
    { name: 'sfx_puckget_pcm.bin', folder: 'NHL95/Sound', start: 0x000792A2, end: 0x00079502 }, // 94 file, same bytes (94 $2BFE8)
    { name: 'fm_instrument_patches.bin', folder: 'NHL95/Sound', start: 0x00079502, end: 0x00079902 }, // 94 file, same bytes (94 $2C248)
    { name: 'z80_snd_drv93.bin', folder: 'NHL95/Sound', start: 0x0007E0E1, end: 0x0007E358 }, // sound95_02: the 94 Z80 driver after its first byte, up to the ld bc of the FM patch bank address (93 / 94 file, same bytes; 94 $1AD91)
    { name: 'z80_snd_drv93_end.bin', folder: 'NHL95/Sound', start: 0x0007E35D, end: 0x0007E36B }, // sound95_02: rest of the 94 Z80 driver (93 / 94 file, same bytes; 94 $1B00D)
    // NHL 95 graphics95_01 ($A1A5A-$1A1699): the player pictures, the rink, the sprites, the fonts and screen maps, the team logos.
    // One slice per asset the code references (its label in src/graphics95_01.asm), one per FeaturedPictures picture (PlayerCards).
    { name: 'NoPlayerPicture.map.jim', folder: 'NHL95/Graphics', start: 0x000A1A5A, end: 0x000A1E90 }, // NoPlayerPicture
    { name: 'NoPicSkater2.bin', folder: 'NHL95/Graphics', start: 0x000A1E90, end: 0x000A21FA }, // NoPicSkater2
    { name: 'NoPicSkater1.bin', folder: 'NHL95/Graphics', start: 0x000A21FA, end: 0x000A2564 }, // NoPicSkater1
    { name: 'NoPicGoalie2.bin', folder: 'NHL95/Graphics', start: 0x000A2564, end: 0x000A28CE }, // NoPicGoalie2
    { name: 'NoPicGoalie1.bin', folder: 'NHL95/Graphics', start: 0x000A28CE, end: 0x000A2C38 }, // NoPicGoalie1
    { name: 'CardGuyHebert.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000A2C38, end: 0x000A2FA2 }, // CardGuyHebert
    { name: 'CardBobCorkum.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000A2FA2, end: 0x000A330C }, // CardBobCorkum
    { name: 'CardTerryYake.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000A330C, end: 0x000A3676 }, // CardTerryYake
    { name: 'CardGarryValk.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000A3676, end: 0x000A39E0 }, // CardGarryValk
    { name: 'CardSeanHill.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000A39E0, end: 0x000A3D4A }, // CardSeanHill
    { name: 'CardBillHoulder.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000A3D4A, end: 0x000A40B4 }, // CardBillHoulder
    { name: 'CardJonCasey.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000A40B4, end: 0x000A441E }, // CardJonCasey
    { name: 'CardAdamOates.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000A441E, end: 0x000A4788 }, // CardAdamOates
    { name: 'CardBryanSmolinski.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000A4788, end: 0x000A4AF2 }, // CardBryanSmolinski
    { name: 'CardCamNeely.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000A4AF2, end: 0x000A4E5C }, // CardCamNeely
    { name: 'CardRayBourque.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000A4E5C, end: 0x000A51C6 }, // CardRayBourque
    { name: 'CardAlIafrate.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000A51C6, end: 0x000A5530 }, // CardAlIafrate
    { name: 'CardDominikHasek.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000A5530, end: 0x000A589A }, // CardDominikHasek
    { name: 'CardPatLaFontaine.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000A589A, end: 0x000A5C04 }, // CardPatLaFontaine
    { name: 'CardDaleHawerchuk.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000A5C04, end: 0x000A5F6E }, // CardDaleHawerchuk
    { name: 'CardAlexnderMogilny.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000A5F6E, end: 0x000A62D8 }, // CardAlexnderMogilny
    { name: 'CardDougBodger.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000A62D8, end: 0x000A6642 }, // CardDougBodger
    { name: 'CardPetrSvoboda.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000A6642, end: 0x000A69AC }, // CardPetrSvoboda
    { name: 'CardMikeVernon.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000A69AC, end: 0x000A6D16 }, // CardMikeVernon
    { name: 'CardJoeNieuwendyk.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000A6D16, end: 0x000A7080 }, // CardJoeNieuwendyk
    { name: 'CardGaryRoberts.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000A7080, end: 0x000A73EA }, // CardGaryRoberts
    { name: 'CardTheorenFleury.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000A73EA, end: 0x000A7754 }, // CardTheorenFleury
    { name: 'CardZarleyZalapski.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000A7754, end: 0x000A7ABE }, // CardZarleyZalapski
    { name: 'CardAlMacInnis.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000A7ABE, end: 0x000A7E28 }, // CardAlMacInnis
    { name: 'CardEdBelfour.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000A7E28, end: 0x000A8192 }, // CardEdBelfour
    { name: 'CardJeremyRoenick.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000A8192, end: 0x000A84FC }, // CardJeremyRoenick
    { name: 'CardMichelGoulet.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000A84FC, end: 0x000A8866 }, // CardMichelGoulet
    { name: 'CardJoeMurphy.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000A8866, end: 0x000A8BD0 }, // CardJoeMurphy
    { name: 'CardChrisChelios.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000A8BD0, end: 0x000A8F3A }, // CardChrisChelios
    { name: 'CardSteveSmith.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000A8F3A, end: 0x000A92A4 }, // CardSteveSmith
    { name: 'CardAndyMoog.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000A92A4, end: 0x000A960E }, // CardAndyMoog
    { name: 'CardMikeModano.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000A960E, end: 0x000A9978 }, // CardMikeModano
    { name: 'CardDaveGagner.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000A9978, end: 0x000A9CE2 }, // CardDaveGagner
    { name: 'CardRussCourtnall.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000A9CE2, end: 0x000AA04C }, // CardRussCourtnall
    { name: 'CardMarkTinordi.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000AA04C, end: 0x000AA3B6 }, // CardMarkTinordi
    { name: 'CardDerianHatcher.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000AA3B6, end: 0x000AA720 }, // CardDerianHatcher
    { name: 'CardBobEssensa.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000AA720, end: 0x000AAA8A }, // CardBobEssensa
    { name: 'CardSteveYzerman.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000AAA8A, end: 0x000AADF4 }, // CardSteveYzerman
    { name: 'CardSergeiFedorov.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000AADF4, end: 0x000AB15E }, // CardSergeiFedorov
    { name: 'CardDinoCiccarelli.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000AB15E, end: 0x000AB4C8 }, // CardDinoCiccarelli
    { name: 'CardPaulCoffey.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000AB4C8, end: 0x000AB832 }, // CardPaulCoffey
    { name: 'CardSteveChiasson.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000AB832, end: 0x000ABB9C }, // CardSteveChiasson
    { name: 'CardBillRanford.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000ABB9C, end: 0x000ABF06 }, // CardBillRanford
    { name: 'CardDougWeight.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000ABF06, end: 0x000AC30C }, // CardDougWeight
    { name: 'CardShayneCorson.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000AC30C, end: 0x000AC676 }, // CardShayneCorson
    { name: 'CardZdenoCiger.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000AC676, end: 0x000ACA7C }, // CardZdenoCiger
    { name: 'CardIgorKravchuk.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000ACA7C, end: 0x000ACDE6 }, // CardIgorKravchuk
    { name: 'CardBobBeers.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000ACDE6, end: 0x000AD150 }, // CardBobBeers
    { name: 'CardJohnVanbiesbrk.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000AD150, end: 0x000AD4BA }, // CardJohnVanbiesbrk
    { name: 'CardJesseBelanger.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000AD4BA, end: 0x000AD824 }, // CardJesseBelanger
    { name: 'CardAndreiLomakin.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000AD824, end: 0x000ADB8E }, // CardAndreiLomakin
    { name: 'CardBobKudelski.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000ADB8E, end: 0x000ADFAC }, // CardBobKudelski
    { name: 'CardBrianBenning.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000ADFAC, end: 0x000AE316 }, // CardBrianBenning
    { name: 'CardGordMurphy.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000AE316, end: 0x000AE680 }, // CardGordMurphy
    { name: 'CardSeanBurke.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000AE680, end: 0x000AE9EA }, // CardSeanBurke
    { name: 'CardAndrewCassels.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000AE9EA, end: 0x000AED54 }, // CardAndrewCassels
    { name: 'CardGeoffSanderson.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000AED54, end: 0x000AF0BE }, // CardGeoffSanderson
    { name: 'CardPatVerbeek.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000AF0BE, end: 0x000AF428 }, // CardPatVerbeek
    { name: 'CardAlexnderGodynyuk.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000AF428, end: 0x000AF792 }, // CardAlexnderGodynyuk
    { name: 'CardChrisPronger.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000AF792, end: 0x000AFAFC }, // CardChrisPronger
    { name: 'CardKellyHrudey.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000AFAFC, end: 0x000AFEEA }, // CardKellyHrudey
    { name: 'CardWayneGretzky.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000AFEEA, end: 0x000B0254 }, // CardWayneGretzky
    { name: 'CardLucRobitaille.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000B0254, end: 0x000B05BE }, // CardLucRobitaille
    { name: 'CardJariKurri.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000B05BE, end: 0x000B0928 }, // CardJariKurri
    { name: 'CardRobBlake.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000B0928, end: 0x000B0C92 }, // CardRobBlake
    { name: 'CardMartyMcSorley.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000B0C92, end: 0x000B0FFC }, // CardMartyMcSorley
    { name: 'CardPatrickRoy.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000B0FFC, end: 0x000B1366 }, // CardPatrickRoy
    { name: 'CardKirkMuller.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000B1366, end: 0x000B16D0 }, // CardKirkMuller
    { name: 'CardVincentDamphousse.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000B16D0, end: 0x000B1A3A }, // CardVincentDamphousse
    { name: 'CardBrianBellows.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000B1A3A, end: 0x000B1DA4 }, // CardBrianBellows
    { name: 'CardEricDesjardins.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000B1DA4, end: 0x000B210E }, // CardEricDesjardins
    { name: 'CardMattSchneider.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000B210E, end: 0x000B24E4 }, // CardMattSchneider
    { name: 'CardChrisTerreri.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000B24E4, end: 0x000B284E }, // CardChrisTerreri
    { name: 'CardCoreyMillen.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000B284E, end: 0x000B2BB8 }, // CardCoreyMillen
    { name: 'CardJohnMacLean.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000B2BB8, end: 0x000B2F22 }, // CardJohnMacLean
    { name: 'CardStephaneRicher.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000B2F22, end: 0x000B328C }, // CardStephaneRicher
    { name: 'CardScottStevens.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000B328C, end: 0x000B35F6 }, // CardScottStevens
    { name: 'CardScottNiedrmayer.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000B35F6, end: 0x000B3960 }, // CardScottNiedrmayer
    { name: 'CardRonHextall.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000B3960, end: 0x000B3D36 }, // CardRonHextall
    { name: 'CardPierreTurgeon.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000B3D36, end: 0x000B40A0 }, // CardPierreTurgeon
    { name: 'CardBenoitHogue.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000B40A0, end: 0x000B440A }, // CardBenoitHogue
    { name: 'CardSteveThomas.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000B440A, end: 0x000B4774 }, // CardSteveThomas
    { name: 'CardDariusKasparitis.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000B4774, end: 0x000B4B7A }, // CardDariusKasparitis
    { name: 'CardVladimirMalakhov.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000B4B7A, end: 0x000B4EE4 }, // CardVladimirMalakhov
    { name: 'CardMikeRichter.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000B4EE4, end: 0x000B524E }, // CardMikeRichter
    { name: 'CardMarkMessier.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000B524E, end: 0x000B55B8 }, // CardMarkMessier
    { name: 'CardAdamGraves.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000B55B8, end: 0x000B59D6 }, // CardAdamGraves
    { name: 'CardSteveLarmer.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000B59D6, end: 0x000B5D40 }, // CardSteveLarmer
    { name: 'CardBrianLeetch.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000B5D40, end: 0x000B60AA }, // CardBrianLeetch
    { name: 'CardSergeiZubov.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000B60AA, end: 0x000B6414 }, // CardSergeiZubov
    { name: 'CardCraigBillington.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000B6414, end: 0x000B677E }, // CardCraigBillington
    { name: 'CardAlexnderDaigle.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000B677E, end: 0x000B6AE8 }, // CardAlexnderDaigle
    { name: 'CardAlexeiYashin.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000B6AE8, end: 0x000B6E52 }, // CardAlexeiYashin
    { name: 'CardSylvainTurgeon.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000B6E52, end: 0x000B71BC }, // CardSylvainTurgeon
    { name: 'CardNormMaciver.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000B71BC, end: 0x000B7526 }, // CardNormMaciver
    { name: 'CardBradShaw.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000B7526, end: 0x000B7890 }, // CardBradShaw
    { name: 'CardDominicRoussel.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000B7890, end: 0x000B7BFA }, // CardDominicRoussel
    { name: 'CardEricLindros.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000B7BFA, end: 0x000B7F64 }, // CardEricLindros
    { name: 'CardRodBrindAmour.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000B7F64, end: 0x000B82CE }, // CardRodBrindAmour
    { name: 'CardMarkRecchi.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000B82CE, end: 0x000B8638 }, // CardMarkRecchi
    { name: 'CardGarryGalley.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000B8638, end: 0x000B89A2 }, // CardGarryGalley
    { name: 'CardDimitriYushkevich.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000B89A2, end: 0x000B8D0C }, // CardDimitriYushkevich
    { name: 'CardTomBarrasso.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000B8D0C, end: 0x000B9076 }, // CardTomBarrasso
    { name: 'CardMarioLemieux.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000B9076, end: 0x000B93E0 }, // CardMarioLemieux
    { name: 'CardKevinStevens.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000B93E0, end: 0x000B974A }, // CardKevinStevens
    { name: 'CardJaromirJagr.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000B974A, end: 0x000B9AB4 }, // CardJaromirJagr
    { name: 'CardUlfSamuelsson.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000B9AB4, end: 0x000B9E1E }, // CardUlfSamuelsson
    { name: 'CardLarryMurphy.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000B9E1E, end: 0x000BA188 }, // CardLarryMurphy
    { name: 'CardStephaneFiset.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000BA188, end: 0x000BA4F2 }, // CardStephaneFiset
    { name: 'CardJoeSakic.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000BA4F2, end: 0x000BA85C }, // CardJoeSakic
    { name: 'CardMatsSundin.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000BA85C, end: 0x000BABC6 }, // CardMatsSundin
    { name: 'CardValeriKamensky.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000BABC6, end: 0x000BAF30 }, // CardValeriKamensky
    { name: 'CardCurtisLeschyshyn.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000BAF30, end: 0x000BB29A }, // CardCurtisLeschyshyn
    { name: 'CardAlexeiGusarov.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000BB29A, end: 0x000BB604 }, // CardAlexeiGusarov
    { name: 'CardArtursIrbe.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000BB604, end: 0x000BB96E }, // CardArtursIrbe
    { name: 'CardIgorLarionov.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000BB96E, end: 0x000BBCD8 }, // CardIgorLarionov
    { name: 'CardUlfDahlen.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000BBCD8, end: 0x000BC042 }, // CardUlfDahlen
    { name: 'CardSergeiMakarov.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000BC042, end: 0x000BC3AC }, // CardSergeiMakarov
    { name: 'CardJeffNorton.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000BC3AC, end: 0x000BC716 }, // CardJeffNorton
    { name: 'CardSandisOzolinsh.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000BC716, end: 0x000BCA80 }, // CardSandisOzolinsh
    { name: 'CardCurtisJoseph.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000BCA80, end: 0x000BCDEA }, // CardCurtisJoseph
    { name: 'CardCraigJanney.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000BCDEA, end: 0x000BD154 }, // CardCraigJanney
    { name: 'CardBrendanShanahan.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000BD154, end: 0x000BD4BE }, // CardBrendanShanahan
    { name: 'CardBrettHull.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000BD4BE, end: 0x000BD828 }, // CardBrettHull
    { name: 'CardPhilHousley.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000BD828, end: 0x000BDB92 }, // CardPhilHousley
    { name: 'CardSteveDuchesne.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000BDB92, end: 0x000BDEFC }, // CardSteveDuchesne
    { name: 'CardDarenPuppa.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000BDEFC, end: 0x000BE266 }, // CardDarenPuppa
    { name: 'CardChrisGratton.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000BE266, end: 0x000BE5D0 }, // CardChrisGratton
    { name: 'CardBrianBradley.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000BE5D0, end: 0x000BE93A }, // CardBrianBradley
    { name: 'CardPetrKlima.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000BE93A, end: 0x000BECA4 }, // CardPetrKlima
    { name: 'CardRomanHamrlik.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000BECA4, end: 0x000BF00E }, // CardRomanHamrlik
    { name: 'CardShawnChambers.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000BF00E, end: 0x000BF378 }, // CardShawnChambers
    { name: 'CardFelixPotvin.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000BF378, end: 0x000BF6E2 }, // CardFelixPotvin
    { name: 'CardDougGilmour.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000BF6E2, end: 0x000BFA4C }, // CardDougGilmour
    { name: 'CardWendelClark.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000BFA4C, end: 0x000BFDB6 }, // CardWendelClark
    { name: 'CardDaveAndreychuk.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000BFDB6, end: 0x000C01BC }, // CardDaveAndreychuk
    { name: 'CardJamieMacoun.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000C01BC, end: 0x000C0526 }, // CardJamieMacoun
    { name: 'CardDaveEllett.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000C0526, end: 0x000C0890 }, // CardDaveEllett
    { name: 'CardKirkMcLean.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000C0890, end: 0x000C0BFA }, // CardKirkMcLean
    { name: 'CardCliffRonning.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000C0BFA, end: 0x000C0F64 }, // CardCliffRonning
    { name: 'CardGeoffCourtnall.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000C0F64, end: 0x000C12CE }, // CardGeoffCourtnall
    { name: 'CardPavelBure.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000C12CE, end: 0x000C1638 }, // CardPavelBure
    { name: 'CardJyrkiLumme.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000C1638, end: 0x000C19A2 }, // CardJyrkiLumme
    { name: 'CardJeffBrown.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000C19A2, end: 0x000C1D0C }, // CardJeffBrown
    { name: 'CardDonBeaupre.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000C1D0C, end: 0x000C2076 }, // CardDonBeaupre
    { name: 'CardMikeRidley.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000C2076, end: 0x000C23E0 }, // CardMikeRidley
    { name: 'CardJoeJuneau.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000C23E0, end: 0x000C274A }, // CardJoeJuneau
    { name: 'CardDimitriKhristich.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000C274A, end: 0x000C2AB4 }, // CardDimitriKhristich
    { name: 'CardKevinHatcher.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000C2AB4, end: 0x000C2E1E }, // CardKevinHatcher
    { name: 'CardSylvainCote.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000C2E1E, end: 0x000C3188 }, // CardSylvainCote
    { name: 'CardTimCheveldae.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000C3188, end: 0x000C34F2 }, // CardTimCheveldae
    { name: 'CardAlexeiZhamnov.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000C34F2, end: 0x000C385C }, // CardAlexeiZhamnov
    { name: 'CardKeithTkachuk.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000C385C, end: 0x000C3C62 }, // CardKeithTkachuk
    { name: 'CardTeemuSelanne.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000C3C62, end: 0x000C3FCC }, // CardTeemuSelanne
    { name: 'CardTeppoNumminen.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000C3FCC, end: 0x000C43EA }, // CardTeppoNumminen
    { name: 'CardDaveManson.bin', folder: 'NHL95/Graphics/PlayerCards', start: 0x000C43EA, end: 0x000C4754 }, // CardDaveManson
    { name: 'Rinktilelist.map.jim', folder: 'NHL95/Graphics', start: 0x000C4A7C, end: 0x000CA56A }, // Rinktilelist
    { name: 'Sprites.bin', folder: 'NHL95/Graphics', start: 0x000CA56A, end: 0x000CA574 }, // Sprites
    { name: 'Spritetiles.bin', folder: 'NHL95/Graphics', start: 0x000CA574, end: 0x001318F4 }, // Spritetiles
    { name: 'frameSprData.bin', folder: 'NHL95/Graphics', start: 0x001318F4, end: 0x00137B66 }, // frameSprData
    { name: 'HotSpotList.bin', folder: 'NHL95/Graphics', start: 0x00137B66, end: 0x001383C6 }, // HotSpotList
    { name: 'RosterFont.bin', folder: 'NHL95/Graphics', start: 0x001383C6, end: 0x00139094 }, // RosterFont
    { name: 'SmallFontMap.map.jim', folder: 'NHL95/Graphics', start: 0x00139094, end: 0x00139E02 }, // SmallFontMap
    { name: 'SmallFontMap2.map.jim', folder: 'NHL95/Graphics', start: 0x00139E02, end: 0x0013AC70 }, // SmallFontMap2
    { name: 'PauseBgBitmap.map.jim', folder: 'NHL95/Graphics', start: 0x0013AC70, end: 0x0013E09E }, // PauseBgBitmap
    { name: 'PeriodNumberBitmap.map.jim', folder: 'NHL95/Graphics', start: 0x0013E09E, end: 0x0013E21C }, // PeriodNumberBitmap
    { name: 'TabBitmap.map.jim', folder: 'NHL95/Graphics', start: 0x0013E21C, end: 0x0013EEAA }, // TabBitmap
    { name: 'PauseFontMap.map.jim', folder: 'NHL95/Graphics', start: 0x0013EEAA, end: 0x0013FC18 }, // PauseFontMap
    { name: 'ClockDigitsBitmap.map.jim', folder: 'NHL95/Graphics', start: 0x0013FC18, end: 0x0014000A }, // ClockDigitsBitmap
    { name: 'RosterBitmap.map.jim', folder: 'NHL95/Graphics', start: 0x0014000A, end: 0x00142906 }, // RosterBitmap
    { name: 'Teamblocksmap.map.jim', folder: 'NHL95/Graphics', start: 0x00142906, end: 0x00146D24 }, // Teamblocksmap
    { name: 'PauseTeamBlocksMap.map.jim', folder: 'NHL95/Graphics', start: 0x00146D24, end: 0x00149E32 }, // PauseTeamBlocksMap
    { name: 'FaceOffMap.map.jim', folder: 'NHL95/Graphics', start: 0x00149E32, end: 0x0014A490 }, // FaceOffMap
    { name: 'FaceOffSprites.map.jim', folder: 'NHL95/Graphics', start: 0x0014A490, end: 0x0014C148 }, // FaceOffSprites
    { name: 'Framermap.map.jim', folder: 'NHL95/Graphics', start: 0x0014C148, end: 0x0014C308 }, // Framermap
    { name: 'Framermap2.map.jim', folder: 'NHL95/Graphics', start: 0x0014C308, end: 0x0014C4C8 }, // Framermap2
    { name: 'EnergyBarMap.map.jim', folder: 'NHL95/Graphics', start: 0x0014C4C8, end: 0x0014C796 }, // EnergyBarMap
    { name: 'EASportsMap.map.jim', folder: 'NHL95/Graphics', start: 0x0014C796, end: 0x0014EB04 }, // EASportsMap
    { name: 'RefTiles.map.jim', folder: 'NHL95/Graphics', start: 0x0014EB04, end: 0x0014FBA2 }, // RefTiles
    { name: 'RefTilesHor.map.jim', folder: 'NHL95/Graphics', start: 0x0014FBA2, end: 0x00151760 }, // RefTilesHor
    { name: 'SetupFont.map.jim', folder: 'NHL95/Graphics', start: 0x00151760, end: 0x001524CE }, // SetupFont
    { name: 'SetupBgMap2.map.jim', folder: 'NHL95/Graphics', start: 0x001524CE, end: 0x001588FC }, // SetupBgMap2
    { name: 'SetupBgMap1.map.jim', folder: 'NHL95/Graphics', start: 0x001588FC, end: 0x0015974A }, // SetupBgMap1
    { name: 'TeamBitmaps.map.jim', folder: 'NHL95/Graphics', start: 0x0015974A, end: 0x0015CE68 }, // TeamBitmaps
    { name: 'BigFontMap3.map.jim', folder: 'NHL95/Graphics', start: 0x0015CE68, end: 0x0015E18A }, // BigFontMap3
    { name: 'BigFontMap.map.jim', folder: 'NHL95/Graphics', start: 0x0015E18A, end: 0x0015F46C }, // BigFontMap
    { name: 'BigFontMap2.map.jim', folder: 'NHL95/Graphics', start: 0x0015F46C, end: 0x0016060E }, // BigFontMap2
    { name: 'RevRinkTilelist.bin', folder: 'NHL95/Graphics', start: 0x0016060E, end: 0x001625F2 }, // RevRinkTilelist
    { name: 'ReplayMap.map.jim', folder: 'NHL95/Graphics', start: 0x001625F2, end: 0x00162D18 }, // ReplayMap
    { name: 'ReplayIconMap.map.jim', folder: 'NHL95/Graphics', start: 0x00162D18, end: 0x0016334A }, // ReplayIconMap
    { name: 'HiScoreBgMap.map.jim', folder: 'NHL95/Graphics', start: 0x0016334A, end: 0x0016430A }, // HiScoreBgMap
    { name: 'HiScoreImg.map.jim', folder: 'NHL95/Graphics', start: 0x0016430A, end: 0x00164AC8 }, // HiScoreImg
    { name: 'ControllerBgMap.map.jim', folder: 'NHL95/Graphics', start: 0x00164AC8, end: 0x00165A36 }, // ControllerBgMap
    { name: 'GamesTodayLogoMap.map.jim', folder: 'NHL95/Graphics', start: 0x00165A36, end: 0x00167524 }, // GamesTodayLogoMap
    { name: 'GamesTodayMap1.map.jim', folder: 'NHL95/Graphics', start: 0x00167524, end: 0x0016767E }, // GamesTodayMap1
    { name: 'GamesTodayMap2.map.jim', folder: 'NHL95/Graphics', start: 0x0016767E, end: 0x0016781E }, // GamesTodayMap2
    { name: 'GamesTodayMap3.map.jim', folder: 'NHL95/Graphics', start: 0x0016781E, end: 0x00167A44 }, // GamesTodayMap3
    { name: 'CalendarBgMap.map.jim', folder: 'NHL95/Graphics', start: 0x00167A44, end: 0x00168E72 }, // CalendarBgMap
    { name: 'CalOpponentMap.map.jim', folder: 'NHL95/Graphics', start: 0x00168E72, end: 0x001696DC }, // CalOpponentMap
    { name: 'CalDayMap.map.jim', folder: 'NHL95/Graphics', start: 0x001696DC, end: 0x00169CE6 }, // CalDayMap
    { name: 'CalMonthMap.map.jim', folder: 'NHL95/Graphics', start: 0x00169CE6, end: 0x0016A814 }, // CalMonthMap
    { name: 'CalCheckMap.bin', folder: 'NHL95/Graphics', start: 0x0016A814, end: 0x0016A8BC }, // CalCheckMap
    { name: 'CalResultMap.map.jim', folder: 'NHL95/Graphics', start: 0x0016A8BC, end: 0x0016AA7C }, // CalResultMap
    { name: 'ControllerTitleMap.map.jim', folder: 'NHL95/Graphics', start: 0x0016AA7C, end: 0x0016AD5A }, // ControllerTitleMap
    { name: 'PadCursorMap.map.jim', folder: 'NHL95/Graphics', start: 0x0016AD5A, end: 0x0016B0B2 }, // PadCursorMap
    { name: 'PadIconMap1.map.jim', folder: 'NHL95/Graphics', start: 0x0016B0B2, end: 0x0016B1C8 }, // PadIconMap1
    { name: 'PadIconMap2.map.jim', folder: 'NHL95/Graphics', start: 0x0016B1C8, end: 0x0016B2DE }, // PadIconMap2
    { name: 'PadIconMap3.map.jim', folder: 'NHL95/Graphics', start: 0x0016B2DE, end: 0x0016B3F4 }, // PadIconMap3
    { name: 'PadIconMap4.map.jim', folder: 'NHL95/Graphics', start: 0x0016B3F4, end: 0x0016B50A }, // PadIconMap4
    { name: 'PlayerStatsBgMap.map.jim', folder: 'NHL95/Graphics', start: 0x0016B50A, end: 0x0016C438 }, // PlayerStatsBgMap
    { name: 'PlayerStatsTitleMap.map.jim', folder: 'NHL95/Graphics', start: 0x0016C438, end: 0x0016C776 }, // PlayerStatsTitleMap
    { name: 'PeriodStatsMap.map.jim', folder: 'NHL95/Graphics', start: 0x0016C776, end: 0x0016C9FC }, // PeriodStatsMap
    { name: 'HighlightsBgMap.map.jim', folder: 'NHL95/Graphics', start: 0x0016C9FC, end: 0x0016CC82 }, // HighlightsBgMap
    { name: 'WaitBoxMap.map.jim', folder: 'NHL95/Graphics', start: 0x0016CC82, end: 0x0016EAB4 }, // WaitBoxMap
    { name: 'LineEditorBgMap.map.jim', folder: 'NHL95/Graphics', start: 0x0016EAB4, end: 0x0016F7D2 }, // LineEditorBgMap
    { name: 'PlayerSelectMap2.map.jim', folder: 'NHL95/Graphics', start: 0x0016F7D2, end: 0x0016FA70 }, // PlayerSelectMap2
    { name: 'PlayerSelectMap1.map.jim', folder: 'NHL95/Graphics', start: 0x0016FA70, end: 0x001703FE }, // PlayerSelectMap1
    { name: 'CreateBgMap.map.jim', folder: 'NHL95/Graphics', start: 0x001703FE, end: 0x00172CCC }, // CreateBgMap
    { name: 'TradeBgMap.map.jim', folder: 'NHL95/Graphics', start: 0x00172CCC, end: 0x0017409A }, // TradeBgMap
    { name: 'AwardsBgMap.map.jim', folder: 'NHL95/Graphics', start: 0x0017409A, end: 0x001787C8 }, // AwardsBgMap
    { name: 'FinalistsPanelMap.map.jim', folder: 'NHL95/Graphics', start: 0x001787C8, end: 0x00178B12 }, // FinalistsPanelMap
    { name: 'WinnerPanelMap.map.jim', folder: 'NHL95/Graphics', start: 0x00178B12, end: 0x00178EC6 }, // WinnerPanelMap
    { name: 'HartPic.map.jim', folder: 'NHL95/Graphics', start: 0x00178EC6, end: 0x00179690 }, // HartPic
    { name: 'NorrisPic.map.jim', folder: 'NHL95/Graphics', start: 0x00179690, end: 0x0017A94A }, // NorrisPic
    { name: 'VezinaPic.map.jim', folder: 'NHL95/Graphics', start: 0x0017A94A, end: 0x0017B2E8 }, // VezinaPic
    { name: 'ArtRossPic.map.jim', folder: 'NHL95/Graphics', start: 0x0017B2E8, end: 0x0017BF00 }, // ArtRossPic
    { name: 'SelkePic.map.jim', folder: 'NHL95/Graphics', start: 0x0017BF00, end: 0x0017E0D6 }, // SelkePic
    { name: 'JenningsPic.map.jim', folder: 'NHL95/Graphics', start: 0x0017E0D6, end: 0x0017EE8E }, // JenningsPic
    { name: 'PresidentsPic.map.jim', folder: 'NHL95/Graphics', start: 0x0017EE8E, end: 0x0017F76C }, // PresidentsPic
    { name: 'ConnSmythePic.map.jim', folder: 'NHL95/Graphics', start: 0x0017F76C, end: 0x0018022A }, // ConnSmythePic
    { name: 'PearsonPic.map.jim', folder: 'NHL95/Graphics', start: 0x0018022A, end: 0x00180B4E }, // PearsonPic
    { name: 'EASNmap.map.jim', folder: 'NHL95/Graphics', start: 0x00180B4E, end: 0x00180D54 }, // EASNmap
    { name: 'GMDecisionMap.map.jim', folder: 'NHL95/Graphics', start: 0x00180D54, end: 0x00181078 }, // GMDecisionMap
    { name: 'FreeAgentMap2.map.jim', folder: 'NHL95/Graphics', start: 0x00181078, end: 0x00181486 }, // FreeAgentMap2
    { name: 'FreeAgentMap1.map.jim', folder: 'NHL95/Graphics', start: 0x00181486, end: 0x00181B04 }, // FreeAgentMap1
    { name: 'TradeAdvantageMap2.map.jim', folder: 'NHL95/Graphics', start: 0x00181B04, end: 0x0018277C }, // TradeAdvantageMap2
    { name: 'TradeAdvantageMap1.map.jim', folder: 'NHL95/Graphics', start: 0x0018277C, end: 0x001834F4 }, // TradeAdvantageMap1
    { name: 'NameEntryBgMap.map.jim', folder: 'NHL95/Graphics', start: 0x001834F4, end: 0x001835D6 }, // NameEntryBgMap
    { name: 'Arrowsmap.map.jim', folder: 'NHL95/Graphics', start: 0x001835D6, end: 0x0018394C }, // Arrowsmap
    { name: 'ScoutMap.map.jim', folder: 'NHL95/Graphics', start: 0x0018394C, end: 0x001842DA }, // ScoutMap
    { name: 'PlayoffSprite.map.jim', folder: 'NHL95/Graphics', start: 0x001842DA, end: 0x001891F8 }, // PlayoffSprite
    { name: 'ScoutReportMap.map.jim', folder: 'NHL95/Graphics', start: 0x001891F8, end: 0x0018A5C6 }, // ScoutReportMap
    { name: 'HotIconMap.map.jim', folder: 'NHL95/Graphics', start: 0x0018A5C6, end: 0x0018A78C }, // HotIconMap
    { name: 'ColdIconMap.map.jim', folder: 'NHL95/Graphics', start: 0x0018A78C, end: 0x0018A9B2 }, // ColdIconMap
    { name: 'RonBarrMap.map.jim', folder: 'NHL95/Graphics', start: 0x0018A9B2, end: 0x0018B628 }, // RonBarrMap
    { name: 'CrowdFrameList.map.jim', folder: 'NHL95/Graphics', start: 0x0018B628, end: 0x0018DAA8 }, // CrowdFrameList
    { name: 'TitleScreenImg.map.jim', folder: 'NHL95/Graphics', start: 0x0018DAA8, end: 0x001960D6 }, // TitleScreenImg
    { name: 'TitleImg.map.jim', folder: 'NHL95/Graphics', start: 0x001960D6, end: 0x00196C4C }, // TitleImg
    { name: 'StanleyCupImg.map.jim', folder: 'NHL95/Graphics', start: 0x00196C4C, end: 0x0019A0FA }, // StanleyCupImg
    { name: 'CupSprites.map.jim', folder: 'NHL95/Graphics', start: 0x0019A0FA, end: 0x0019A992 }, // CupSprites
    { name: 'logoANA.map.jim', folder: 'NHL95/Graphics', start: 0x0019A992, end: 0x0019AE28 }, // logoANA
    { name: 'logoBOS.map.jim', folder: 'NHL95/Graphics', start: 0x0019AE28, end: 0x0019B17E }, // logoBOS
    { name: 'logoBUF.map.jim', folder: 'NHL95/Graphics', start: 0x0019B17E, end: 0x0019B4D4 }, // logoBUF
    { name: 'logoCGY.map.jim', folder: 'NHL95/Graphics', start: 0x0019B4D4, end: 0x0019B96A }, // logoCGY
    { name: 'logoCHI.map.jim', folder: 'NHL95/Graphics', start: 0x0019B96A, end: 0x0019BDA0 }, // logoCHI
    { name: 'logoDET.map.jim', folder: 'NHL95/Graphics', start: 0x0019BDA0, end: 0x0019C0F6 }, // logoDET
    { name: 'logoEDM.map.jim', folder: 'NHL95/Graphics', start: 0x0019C0F6, end: 0x0019C4EC }, // logoEDM
    { name: 'logoFLA.map.jim', folder: 'NHL95/Graphics', start: 0x0019C4EC, end: 0x0019C8A2 }, // logoFLA
    { name: 'logoHFD.map.jim', folder: 'NHL95/Graphics', start: 0x0019C8A2, end: 0x0019CB38 }, // logoHFD
    { name: 'logoNYI.map.jim', folder: 'NHL95/Graphics', start: 0x0019CB38, end: 0x0019CF8E }, // logoNYI
    { name: 'logoLA.map.jim', folder: 'NHL95/Graphics', start: 0x0019CF8E, end: 0x0019D304 }, // logoLA
    { name: 'logoDAL.map.jim', folder: 'NHL95/Graphics', start: 0x0019D304, end: 0x0019D71A }, // logoDAL
    { name: 'logoMTL.map.jim', folder: 'NHL95/Graphics', start: 0x0019D71A, end: 0x0019DA90 }, // logoMTL
    { name: 'logoNJ.map.jim', folder: 'NHL95/Graphics', start: 0x0019DA90, end: 0x0019DF46 }, // logoNJ
    { name: 'logoNYR.map.jim', folder: 'NHL95/Graphics', start: 0x0019DF46, end: 0x0019E41C }, // logoNYR
    { name: 'logoOTW.map.jim', folder: 'NHL95/Graphics', start: 0x0019E41C, end: 0x0019E832 }, // logoOTW
    { name: 'logoPHI.map.jim', folder: 'NHL95/Graphics', start: 0x0019E832, end: 0x0019EBE8 }, // logoPHI
    { name: 'logoPIT.map.jim', folder: 'NHL95/Graphics', start: 0x0019EBE8, end: 0x0019EF5E }, // logoPIT
    { name: 'logoQUE.map.jim', folder: 'NHL95/Graphics', start: 0x0019EF5E, end: 0x0019F2B4 }, // logoQUE
    { name: 'logoSJ.map.jim', folder: 'NHL95/Graphics', start: 0x0019F2B4, end: 0x0019F6EA }, // logoSJ
    { name: 'logoSTL.map.jim', folder: 'NHL95/Graphics', start: 0x0019F6EA, end: 0x0019FAC0 }, // logoSTL
    { name: 'logoTB.map.jim', folder: 'NHL95/Graphics', start: 0x0019FAC0, end: 0x0019FED6 }, // logoTB
    { name: 'logoTOR.map.jim', folder: 'NHL95/Graphics', start: 0x0019FED6, end: 0x001A022C }, // logoTOR
    { name: 'logoVAN.map.jim', folder: 'NHL95/Graphics', start: 0x001A022C, end: 0x001A0642 }, // logoVAN
    { name: 'logoWSH.map.jim', folder: 'NHL95/Graphics', start: 0x001A0642, end: 0x001A08B8 }, // logoWSH
    { name: 'logoWPG.map.jim', folder: 'NHL95/Graphics', start: 0x001A08B8, end: 0x001A0D2E }, // logoWPG
    { name: 'logoASE.map.jim', folder: 'NHL95/Graphics', start: 0x001A0D2E, end: 0x001A11E4 }, // logoASE
    { name: 'logoASW.map.jim', folder: 'NHL95/Graphics', start: 0x001A11E4, end: 0x001A169A }, // logoASW
    // NHL 95 title95_03 TeamLogoPalettes ($1A169A): one 32 byte palette per team; 25 are the same bytes as the 94 files (94 names), DAL / ASE / ASW differ.
    { name: 'MatchupPalANHA.pal', folder: 'NHL95/Graphics/Pals', start: 0x001A169A, end: 0x001A16BA }, // ANH TeamLogoPalettes, 94 file, same bytes
    { name: 'TeamLogoPalBOS.pal', folder: 'NHL95/Graphics/Pals', start: 0x001A16BA, end: 0x001A16DA }, // BOS TeamLogoPalettes, 94 file, same bytes
    { name: 'MatchupPalBUFA.pal', folder: 'NHL95/Graphics/Pals', start: 0x001A16DA, end: 0x001A16FA }, // BUF TeamLogoPalettes, 94 file, same bytes
    { name: 'MatchupPalCGYA.pal', folder: 'NHL95/Graphics/Pals', start: 0x001A16FA, end: 0x001A171A }, // CGY TeamLogoPalettes, 94 file, same bytes
    { name: 'MatchupPalCHIA.pal', folder: 'NHL95/Graphics/Pals', start: 0x001A171A, end: 0x001A173A }, // CHI TeamLogoPalettes, 94 file, same bytes
    { name: 'MatchupPalDALA95.pal', folder: 'NHL95/Graphics/Pals', start: 0x001A173A, end: 0x001A175A }, // DAL TeamLogoPalettes, differs from 94 MatchupPalDALA.pal
    { name: 'MatchupPalDETA.pal', folder: 'NHL95/Graphics/Pals', start: 0x001A175A, end: 0x001A177A }, // DET TeamLogoPalettes, 94 file, same bytes
    { name: 'MatchupPalEDMA.pal', folder: 'NHL95/Graphics/Pals', start: 0x001A177A, end: 0x001A179A }, // EDM TeamLogoPalettes, 94 file, same bytes
    { name: 'TeamLogoPalFLA.pal', folder: 'NHL95/Graphics/Pals', start: 0x001A179A, end: 0x001A17BA }, // FLA TeamLogoPalettes, 94 file, same bytes
    { name: 'TeamLogoPalHFD.pal', folder: 'NHL95/Graphics/Pals', start: 0x001A17BA, end: 0x001A17DA }, // HFD TeamLogoPalettes, 94 file, same bytes
    { name: 'MatchupPalLAA.pal', folder: 'NHL95/Graphics/Pals', start: 0x001A17DA, end: 0x001A17FA }, // LA TeamLogoPalettes, 94 file, same bytes
    { name: 'MatchupPalMTLA.pal', folder: 'NHL95/Graphics/Pals', start: 0x001A17FA, end: 0x001A181A }, // MTL TeamLogoPalettes, 94 file, same bytes
    { name: 'MatchupPalNJA.pal', folder: 'NHL95/Graphics/Pals', start: 0x001A181A, end: 0x001A183A }, // NJ TeamLogoPalettes, 94 file, same bytes
    { name: 'MatchupPalNYIA.pal', folder: 'NHL95/Graphics/Pals', start: 0x001A183A, end: 0x001A185A }, // NYI TeamLogoPalettes, 94 file, same bytes
    { name: 'MatchupPalNYRA.pal', folder: 'NHL95/Graphics/Pals', start: 0x001A185A, end: 0x001A187A }, // NYR TeamLogoPalettes, 94 file, same bytes
    { name: 'MatchupPalOTWA.pal', folder: 'NHL95/Graphics/Pals', start: 0x001A187A, end: 0x001A189A }, // OTW TeamLogoPalettes, 94 file, same bytes
    { name: 'MatchupPalPHIA.pal', folder: 'NHL95/Graphics/Pals', start: 0x001A189A, end: 0x001A18BA }, // PHI TeamLogoPalettes, 94 file, same bytes
    { name: 'MatchupPalPITA.pal', folder: 'NHL95/Graphics/Pals', start: 0x001A18BA, end: 0x001A18DA }, // PIT TeamLogoPalettes, 94 file, same bytes
    { name: 'MatchupPalQUEA.pal', folder: 'NHL95/Graphics/Pals', start: 0x001A18DA, end: 0x001A18FA }, // QUE TeamLogoPalettes, 94 file, same bytes
    { name: 'TeamLogoPalSJ.pal', folder: 'NHL95/Graphics/Pals', start: 0x001A18FA, end: 0x001A191A }, // SJ TeamLogoPalettes, 94 file, same bytes
    { name: 'MatchupPalSTLA.pal', folder: 'NHL95/Graphics/Pals', start: 0x001A191A, end: 0x001A193A }, // STL TeamLogoPalettes, 94 file, same bytes
    { name: 'MatchupPalTBA.pal', folder: 'NHL95/Graphics/Pals', start: 0x001A193A, end: 0x001A195A }, // TB TeamLogoPalettes, 94 file, same bytes
    { name: 'MatchupPalTORA.pal', folder: 'NHL95/Graphics/Pals', start: 0x001A195A, end: 0x001A197A }, // TOR TeamLogoPalettes, 94 file, same bytes
    { name: 'MatchupPalVANA.pal', folder: 'NHL95/Graphics/Pals', start: 0x001A197A, end: 0x001A199A }, // VAN TeamLogoPalettes, 94 file, same bytes
    { name: 'MatchupPalWSHA.pal', folder: 'NHL95/Graphics/Pals', start: 0x001A199A, end: 0x001A19BA }, // WSH TeamLogoPalettes, 94 file, same bytes
    { name: 'MatchupPalWPGA.pal', folder: 'NHL95/Graphics/Pals', start: 0x001A19BA, end: 0x001A19DA }, // WPG TeamLogoPalettes, 94 file, same bytes
    { name: 'MatchupPalASEA95.pal', folder: 'NHL95/Graphics/Pals', start: 0x001A19DA, end: 0x001A19FA }, // ASE TeamLogoPalettes, differs from 94 MatchupPalASEA.pal
    { name: 'MatchupPalASWA95.pal', folder: 'NHL95/Graphics/Pals', start: 0x001A19FA, end: 0x001A1A1A }, // ASW TeamLogoPalettes, differs from 94 MatchupPalASWA.pal
    // NHL 95 graphics95_02 ArenaGfxBank ($1A1A1A): the home team graphics, $30A bytes per team in bank order (TeamGfxList, fourway95).
    { name: 'ArenaGfxANH.bin', folder: 'NHL95/Graphics/ArenaGfx', start: 0x001A1A1A, end: 0x001A1D24 }, // ArenaGfxBank+$0, ANH
    { name: 'ArenaGfxBUF.bin', folder: 'NHL95/Graphics/ArenaGfx', start: 0x001A1D24, end: 0x001A202E }, // ArenaGfxBank+$30A, BUF
    { name: 'ArenaGfxCGY.bin', folder: 'NHL95/Graphics/ArenaGfx', start: 0x001A202E, end: 0x001A2338 }, // ArenaGfxBank+$614, CGY
    { name: 'ArenaGfxCHI.bin', folder: 'NHL95/Graphics/ArenaGfx', start: 0x001A2338, end: 0x001A2642 }, // ArenaGfxBank+$91E, CHI
    { name: 'ArenaGfxDAL.bin', folder: 'NHL95/Graphics/ArenaGfx', start: 0x001A2642, end: 0x001A294C }, // ArenaGfxBank+$C28, DAL
    { name: 'ArenaGfxDET.bin', folder: 'NHL95/Graphics/ArenaGfx', start: 0x001A294C, end: 0x001A2C56 }, // ArenaGfxBank+$F32, DET
    { name: 'ArenaGfxEDM.bin', folder: 'NHL95/Graphics/ArenaGfx', start: 0x001A2C56, end: 0x001A2F60 }, // ArenaGfxBank+$123C, EDM
    { name: 'ArenaGfxFLA.bin', folder: 'NHL95/Graphics/ArenaGfx', start: 0x001A2F60, end: 0x001A326A }, // ArenaGfxBank+$1546, FLA
    { name: 'ArenaGfxHFD.bin', folder: 'NHL95/Graphics/ArenaGfx', start: 0x001A326A, end: 0x001A3574 }, // ArenaGfxBank+$1850, HFD
    { name: 'ArenaGfxLA.bin', folder: 'NHL95/Graphics/ArenaGfx', start: 0x001A3574, end: 0x001A387E }, // ArenaGfxBank+$1B5A, LA
    { name: 'ArenaGfxMTL.bin', folder: 'NHL95/Graphics/ArenaGfx', start: 0x001A387E, end: 0x001A3B88 }, // ArenaGfxBank+$1E64, MTL
    { name: 'ArenaGfxNJ.bin', folder: 'NHL95/Graphics/ArenaGfx', start: 0x001A3B88, end: 0x001A3E92 }, // ArenaGfxBank+$216E, NJ
    { name: 'ArenaGfxNYI.bin', folder: 'NHL95/Graphics/ArenaGfx', start: 0x001A3E92, end: 0x001A419C }, // ArenaGfxBank+$2478, NYI
    { name: 'ArenaGfxNYR.bin', folder: 'NHL95/Graphics/ArenaGfx', start: 0x001A419C, end: 0x001A44A6 }, // ArenaGfxBank+$2782, NYR
    { name: 'ArenaGfxOTW.bin', folder: 'NHL95/Graphics/ArenaGfx', start: 0x001A44A6, end: 0x001A47B0 }, // ArenaGfxBank+$2A8C, OTW
    { name: 'ArenaGfxPHI.bin', folder: 'NHL95/Graphics/ArenaGfx', start: 0x001A47B0, end: 0x001A4ABA }, // ArenaGfxBank+$2D96, PHI
    { name: 'ArenaGfxPIT.bin', folder: 'NHL95/Graphics/ArenaGfx', start: 0x001A4ABA, end: 0x001A4DC4 }, // ArenaGfxBank+$30A0, PIT
    { name: 'ArenaGfxQUE.bin', folder: 'NHL95/Graphics/ArenaGfx', start: 0x001A4DC4, end: 0x001A50CE }, // ArenaGfxBank+$33AA, QUE
    { name: 'ArenaGfxSJ.bin', folder: 'NHL95/Graphics/ArenaGfx', start: 0x001A50CE, end: 0x001A53D8 }, // ArenaGfxBank+$36B4, SJ
    { name: 'ArenaGfxSTL.bin', folder: 'NHL95/Graphics/ArenaGfx', start: 0x001A53D8, end: 0x001A56E2 }, // ArenaGfxBank+$39BE, STL
    { name: 'ArenaGfxTB.bin', folder: 'NHL95/Graphics/ArenaGfx', start: 0x001A56E2, end: 0x001A59EC }, // ArenaGfxBank+$3CC8, TB
    { name: 'ArenaGfxTOR.bin', folder: 'NHL95/Graphics/ArenaGfx', start: 0x001A59EC, end: 0x001A5CF6 }, // ArenaGfxBank+$3FD2, TOR
    { name: 'ArenaGfxVAN.bin', folder: 'NHL95/Graphics/ArenaGfx', start: 0x001A5CF6, end: 0x001A6000 }, // ArenaGfxBank+$42DC, VAN
    { name: 'ArenaGfxWSH.bin', folder: 'NHL95/Graphics/ArenaGfx', start: 0x001A6000, end: 0x001A630A }, // ArenaGfxBank+$45E6, WSH
    { name: 'ArenaGfxWPG.bin', folder: 'NHL95/Graphics/ArenaGfx', start: 0x001A630A, end: 0x001A6614 }, // ArenaGfxBank+$48F0, WPG
    { name: 'ArenaGfxBOS.bin', folder: 'NHL95/Graphics/ArenaGfx', start: 0x001A6614, end: 0x001A691E }, // ArenaGfxBank+$4BFA, BOS
    { name: 'ArenaGfxASEASW.bin', folder: 'NHL95/Graphics/ArenaGfx', start: 0x001A691E, end: 0x001A6C28 }, // ArenaGfxBank+$4F04, ASE / ASW
];
const outRoot = path.join('Extracted');
const rom = fs.readFileSync(romPath);
for (const asset of assets) {
  const dir = path.join(outRoot, asset.folder);
  fs.mkdirSync(dir, { recursive: true });
  fs.writeFileSync(path.join(dir, asset.name), rom.subarray(asset.start, asset.end));
}
console.log('Extracted ' + assets.length + ' slices to ' + outRoot + '.');
