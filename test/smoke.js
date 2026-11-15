// Checks run before every release (release.cmd, and again on GitHub before the .exe is built):
//   1. server.js and the page's script have no syntax errors
//   2. the app starts and its main addresses answer
//   3. the dashboard loads in a real browser (headless Edge or Chrome, demo data) with no errors, a map that has
//      a size, planes in the list, and a tooltip on every control (the page checks itself: ?selftest in index.html)
// Usage: node test/smoke.js      Exits 0 when everything passes, 1 with the reasons when not.
const fs = require('fs'), path = require('path'), http = require('http'), cp = require('child_process');
const ROOT = path.join(__dirname, '..'), PORT = 8097, BASE = `http://127.0.0.1:${PORT}`;
const fails = [], ok = m => console.log('  ok    ' + m), bad = m => { fails.push(m); console.log('  FAIL  ' + m); };

function get(url, method = 'GET', body) {
  return new Promise((resolve, reject) => {
    const req = http.request(url, { method, timeout: 8000 }, res => {
      let s = ''; res.on('data', d => s += d); res.on('end', () => resolve({ status: res.statusCode, body: s }));
    });
    req.on('timeout', () => req.destroy(new Error('timed out')));
    req.on('error', reject);
    req.end(body);
  });
}
const sleep = ms => new Promise(r => setTimeout(r, ms));
function browser() {
  const bases = [process.env['ProgramFiles(x86)'], process.env.ProgramFiles, process.env.LOCALAPPDATA].filter(Boolean);
  for (const rel of ['Microsoft\\Edge\\Application\\msedge.exe', 'Google\\Chrome\\Application\\chrome.exe'])
    for (const b of bases) { const p = path.join(b, rel); if (fs.existsSync(p)) return p; }
  return null;
}

(async () => {
  console.log('Porch Radar release checks');
  // 1. syntax
  try { cp.execFileSync(process.execPath, ['--check', path.join(ROOT, 'server.js')], { stdio: 'pipe' }); ok('server.js has no syntax errors'); }
  catch (e) { bad('server.js syntax: ' + String(e.stderr || e.message).split('\n').slice(0, 4).join(' ')); }
  const html = fs.readFileSync(path.join(ROOT, 'index.html'), 'utf8');
  const script = [...html.matchAll(/<script>([\s\S]*?)<\/script>/g)].map(m => m[1]).sort((a, b) => b.length - a.length)[0] || '';
  try { new Function(script); ok('the page script has no syntax errors'); } catch (e) { bad('page script syntax: ' + e.message); }
  const css = (html.match(/<style>([\s\S]*?)<\/style>/) || [, ''])[1].replace(/\/\*[\s\S]*?\*\//g, '');
  const open = (css.match(/{/g) || []).length, close = (css.match(/}/g) || []).length;
  open === close ? ok('the page styles are balanced') : bad(`page styles: ${open} "{" but ${close} "}"`);
  if (fails.length) return finish();

  // 2. the app starts and answers
  const server = cp.spawn(process.execPath, ['server.js'], { cwd: ROOT, env: { ...process.env, PORT: String(PORT), NO_BROWSER: '1' }, stdio: 'ignore' });
  const stop = () => { try { server.kill(); } catch (e) {} };
  process.on('exit', stop);
  let up = false;
  for (let i = 0; i < 40 && !up; i++) { await sleep(500); up = await get(BASE + '/api/version').then(r => r.status === 200, () => false); }
  if (!up) { bad('the app did not start on port ' + PORT); return finish(stop); }
  ok('the app starts');
  const routes = [['/', 'GET'], ['/api/version', 'GET'], ['/api/settings', 'GET'], ['/api/log', 'GET'], ['/api/log.csv', 'GET'], ['/api/trails?mins=5', 'GET'],
    ['/api/favorites', 'GET'], ['/api/mirror', 'GET'], ['/api/prefs', 'GET'], ['/api/speaker', 'POST', '{"id":"smoke","vis":false}']];
  for (const [p, method, body] of routes) {
    try {
      const r = await get(BASE + p, method, body);
      if (r.status !== 200) bad(`${method} ${p} answered ${r.status}`);
      else if (p.startsWith('/api/') && p !== '/api/log.csv') JSON.parse(r.body);
    } catch (e) { bad(`${method} ${p}: ${e.message}`); }
  }
  if (!fails.length) ok(routes.length + ' addresses answer');

  // 3. the page, in a real browser
  const exe = browser();
  if (!exe) console.log('  skip  no Edge or Chrome found, so the page was not opened');
  else {
    const profile = fs.mkdtempSync(path.join(require('os').tmpdir(), 'pr-smoke-'));
    for (const [name, size] of [['computer', '1500,900'], ['phone', '390,800']]) {
      let dom = '';
      try {
        dom = cp.execFileSync(exe, ['--headless=new', '--disable-gpu', '--mute-audio', '--no-first-run', '--window-size=' + size, '--virtual-time-budget=12000',
          '--user-data-dir=' + profile, '--dump-dom', BASE + '/?demo&selftest'], { encoding: 'utf8', timeout: 90000, maxBuffer: 64 << 20, stdio: ['ignore', 'pipe', 'ignore'] });
      } catch (e) { bad(`${name}: the browser could not load the page (${e.message.split('\n')[0]})`); continue; }
      const m = dom.match(/data-selftest="([^"]*)"/);
      if (!m) bad(`${name}: the page never finished its own check (it probably stopped on an error while loading)`);
      else if (m[1] !== 'ok') bad(`${name}: ${m[1].replace(/&amp;/g, '&').replace(/&quot;/g, '"')}`);
      else ok(`the page loads at ${name} size: no errors, map has a size, planes listed, every control has a tooltip`);
    }
    try { fs.rmSync(profile, { recursive: true, force: true }); } catch (e) {}
  }
  finish(stop);
})();

function finish(stop) {
  if (stop) stop();
  console.log(fails.length ? `\n${fails.length} check${fails.length > 1 ? 's' : ''} failed. Not releasing.` : '\nAll checks passed.');
  process.exit(fails.length ? 1 : 0);
}
