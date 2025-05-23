#!/usr/bin/env node
/**
 * summarize-sparql-results.mjs
 *
 * Expected  : mf:result files referenced in each manifest
 * Produced  : results/<service>/<manifest-dir>/<view>.(srj|srx)
 * Row key   : <manifest-dir>/<view>.rq
 *
 * Usage:
 *   node summarize-sparql-results.mjs [<results-root> [<tests-root>]]
 */
import fs from 'fs/promises';
import path from 'path';
import { Parser, Store, DataFactory } from 'n3';
import { XMLParser } from 'fast-xml-parser';

const RESULTS_ROOT = path.resolve(process.argv[2] || './results');
const TESTS_ROOT   = path.resolve(process.argv[3] || '.');
const DEBUG        = process.env.DEBUG === '1';

/* ── helpers ───────────────────────────────────────── */
const xmlP = new XMLParser({ ignoreAttributes:false, preserveOrder:true });
const stable = x => Array.isArray(x) ? x.map(stable)
  : (x && typeof x === 'object')
      ? Object.fromEntries(Object.keys(x).sort().map(k => [k, stable(x[k])]))
      : x;
const canon = t => {
  const s = t.trim();
  try { return JSON.stringify(stable(JSON.parse(s))); } catch {}
  try { 
    var parsed = xmlP.parse(s);
    var sparql = parsed["sparql"];
    return JSON.stringify(stable(sparql)); } catch {}
  return s;
};
const esc = s => s.replace(/[&<>"]/g, c =>
  ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;'}[c]));

/* async walker */
async function* walk(dir, filter) {
  for await (const d of await fs.opendir(dir)) {
    const p = path.join(dir, d.name);
    if (d.isDirectory()) yield* walk(p, filter);
    else if (filter(d.name)) yield p;
  }
}

/* RDF constants */
const ns = {
  mf :'http://www.w3.org/2001/sw/DataAccess/tests/test-manifest#',
  qt :'http://www.w3.org/2001/sw/DataAccess/tests/test-query#',
  rdf:'http://www.w3.org/1999/02/22-rdf-syntax-ns#'
};
const RDF_TYPE   = DataFactory.namedNode(ns.rdf + 'type');
const MF_MAN     = DataFactory.namedNode(ns.mf  + 'Manifest');
const MF_ENTRIES = DataFactory.namedNode(ns.mf  + 'entries');
const MF_ACTION  = DataFactory.namedNode(ns.mf  + 'action');
const MF_RESULT  = DataFactory.namedNode(ns.mf  + 'result');
const QT_QUERY   = DataFactory.namedNode(ns.qt  + 'query');
const RDF_FIRST  = DataFactory.namedNode(ns.rdf + 'first');
const RDF_REST   = DataFactory.namedNode(ns.rdf + 'rest');
const RDF_NIL    = DataFactory.namedNode(ns.rdf + 'nil');
const rdfList = (st, head) => {
  const arr = [];
  let n = head;
  while (n && !n.equals(RDF_NIL)) {
    const first = st.getObjects(n, RDF_FIRST, null)[0];
    if (first) arr.push(first);
    n = st.getObjects(n, RDF_REST, null)[0];
  }
  return arr;
};

/* ── STEP 1: expected map ──────────────────────────── */
const expected = {};   // key -> { query, expText, canon, ext }

for await (const manifest of walk(TESTS_ROOT, n => n === 'manifest.ttl')) {
  const mDir   = path.dirname(manifest);
  const relDir = path.relative(TESTS_ROOT, mDir) || '.';

  const store = new Store(
    new Parser({ baseIRI:`https://example/${relDir}/` })
      .parse(await fs.readFile(manifest, 'utf8'))
  );

  for (const mf of store.getSubjects(RDF_TYPE, MF_MAN, null)) {
    for (const head of store.getObjects(mf, MF_ENTRIES, null)) {
      for (const test of rdfList(store, head)) {

        const action = store.getObjects(test, MF_ACTION, null)[0];
        const resRef = store.getObjects(test, MF_RESULT, null)[0];
        if (!action || !resRef) continue;

        let qFile;
        if (action.termType === 'NamedNode') {
          qFile = path.posix.basename(action.value);
        } else {
          const q = store.getObjects(action, QT_QUERY, null)[0];
          if (!q) continue;
          qFile = path.posix.basename(q.value);
        }
        const view = path.parse(qFile).name;
        const key  = (relDir === '.' ? '' : relDir + '/') + view + '.rq';

        try {
          const queryTxt = await fs.readFile(path.join(mDir, qFile), 'utf8');
          const resFile  = path.posix.basename(resRef.value);
          const expTxt   = await fs.readFile(path.join(mDir, resFile), 'utf8');
          expected[key] = {
            query : queryTxt,
            exp   : expTxt,
            canon : canon(expTxt),
            ext   : path.extname(resFile)
          };
        } catch {
          if (DEBUG) console.error('Missing expected', key);
        }
      }
    }
  }
}

/* ── STEP 2: produced map ──────────────────────────── */
const services = (await fs.readdir(RESULTS_ROOT, { withFileTypes:true }))
  .filter(d => d.isDirectory()).map(d => d.name).sort();
if (!services.length) { console.error('No service dirs'); process.exit(1); }

const produced = {};  // key (.rq and real ext) -> { svc -> { text, canon, rel } }

for (const svc of services) {
  for await (const f of walk(path.join(RESULTS_ROOT, svc),
                             /*** ← correct regex ***/  n => /\.(srj|srx)$/i.test(n))) {
    const rel = path.relative(path.join(RESULTS_ROOT, svc), f); // subpath
    const dir = path.dirname(rel);
    const view = path.parse(f).name;

    const rqKey  = (dir === '.' ? '' : dir + '/') + view + '.rq';
    const extKey = rel.replace(/^\.?\//, '');

    const txt = await fs.readFile(f, 'utf8');
    const entry = { text: txt, canon: canon(txt), rel };

    (produced[rqKey]  ??= {})[svc] = entry;
    (produced[extKey] ??= {})[svc] = entry;   // alias under real filename
  }
}

/* ── STEP 3: rows ─────────────────────────────────── */
const rows = [];
let uid = 0;
for (const key of Object.keys(expected).sort()) {
  const exp = expected[key];
  const cells = {};
  for (const svc of services) {
    const prod = produced[key]?.[svc];
    if (!prod) {
      const guess = path.join(svc, key.slice(0, -3) + exp.ext);
      cells[svc]  = { ok:false, actual:`missing (${guess})` };
    } else {
      cells[svc]  = prod.canon === exp.canon ? { ok:true }
                                             : { ok:false, actual:prod.text };
    }
  }
  rows.push({ label:key, query:exp.query, expected:exp.exp, cells });
}

/* ── STEP 4: HTML summary ─────────────────────────── */
let html = `<!doctype html><html><head><meta charset="utf-8">
<title>SPARQL Result Comparison</title>
<style>
 body{font-family:sans-serif;margin:2rem;}
 table{border-collapse:collapse;width:100%;}
 th,td{border:1px solid #aaa;padding:4px 8px;text-align:center;vertical-align:top;}
 th{background:#eee;}
 td.label{text-align:left;cursor:pointer;}
 td.pass{color:green;font-weight:bold;}
 td.fail{color:red;font-weight:bold;cursor:pointer;}
 .flex {display:none;gap:1rem;}
 pre{white-space:pre-wrap;background:#f8f8f8;margin:4px 0 0;padding:4px;
      border:1px solid #ddd;max-height:300px;overflow:auto;}
</style></head><body>
<h1>SPARQL Result Comparison</h1>
<table id="tbl"><thead><tr><th>Test (query | expected)</th>${
  services.map(s => `<th>${s}</th>`).join('')}</tr></thead><tbody>`;

for (const r of rows) {
  const boxID = `b${uid++}`;
  html += `<tr><td class="label toggle" data-id="${boxID}">${r.label}
             <div id="${boxID}" class="flex">
               <pre>${esc(r.query)}</pre>
               <pre>${esc(r.expected)}</pre>
             </div></td>`;
  for (const svc of services) {
    const c = r.cells[svc];
    if (c.ok) html += '<td class="pass">✔</td>';
    else {
      const preID = `p${uid++}`;
      html += `<td class="fail toggle" data-id="${preID}">✘
                 <pre id="${preID}" style="display:none">${esc(c.actual)}</pre></td>`;
    }
  }
  html += '</tr>';
}

html += `</tbody></table><p>Total tests: ${rows.length}</p>
<script>
document.getElementById('tbl').addEventListener('click', e => {
  const cell = e.target.closest('.toggle'); if (!cell) return;
  const el   = document.getElementById(cell.dataset.id);
  if (!el) return;
  const isFlex = el.classList.contains('flex');
  el.style.display = (el.style.display==='none'||!el.style.display)
                     ? (isFlex?'flex':'block') : 'none';
});
</script></body></html>`;

/* write summary */
await fs.writeFile(path.join(RESULTS_ROOT,'summary.html'),html,'utf8');
console.log('Summary written to', path.join(RESULTS_ROOT,'summary.html'));
if (DEBUG) console.error('Services:', services, 'Rows:', rows.length);
