// NHL 95 asset extractor. No slices yet.
// Usage: node extractAssets95.js lst/nhl95.bin
// Add a slice only after the listing label and the retail range are confirmed.
const fs = require('fs');
const path = require('path');
const romPath = process.argv[2] || 'lst/nhl95.bin';
if (!fs.existsSync(romPath)) {
  console.error('Missing ' + romPath + '. Put the IDA ROM at lst/nhl95.bin first.');
  process.exit(1);
}
const assets = [];
const outRoot = path.join('Extracted');
fs.mkdirSync(outRoot, { recursive: true });
console.log('No assets listed yet. ' + assets.length + ' slices extracted.');
