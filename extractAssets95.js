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
];
const outRoot = path.join('Extracted');
const rom = fs.readFileSync(romPath);
for (const asset of assets) {
  const dir = path.join(outRoot, asset.folder);
  fs.mkdirSync(dir, { recursive: true });
  fs.writeFileSync(path.join(dir, asset.name), rom.subarray(asset.start, asset.end));
}
console.log('Extracted ' + assets.length + ' slices to ' + outRoot + '.');
