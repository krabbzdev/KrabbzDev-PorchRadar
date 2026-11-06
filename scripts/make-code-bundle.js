// Packs the app's code into one gzip file for the release: dist/Krabbz9999-FlightTracker-code.gz
// Installed copies (see server.js, swapCode) download this on update and replace only these files.
// Usage: node scripts/make-code-bundle.js   (run after version.json has been stamped with the commit)
const fs = require('fs'), path = require('path'), zlib = require('zlib');
const root = path.join(__dirname, '..');
const FILES = ['server.js', 'index.html', 'version.json']; // keep in step with CODE_FILES in server.js
const base = JSON.parse(fs.readFileSync(path.join(root, 'installer', 'base.json'), 'utf8')).base;
const bundle = { needsBase: base, files: {} };
for (const f of FILES) bundle.files[f] = fs.readFileSync(path.join(root, f)).toString('base64');
fs.mkdirSync(path.join(root, 'dist'), { recursive: true });
const out = path.join(root, 'dist', 'Krabbz9999-FlightTracker-code.gz');
fs.writeFileSync(out, zlib.gzipSync(JSON.stringify(bundle), { level: 9 }));
console.log(`Wrote ${out} (${fs.statSync(out).size} bytes, needs base ${base})`);
