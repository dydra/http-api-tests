#!/usr/bin/env node
/**
 * run‑sparql11‑tests.mjs
 *
 *  • Reads the manifest links that appear at the head of
 *    https://www.w3.org/2009/sparql/docs/tests/summary.html  :contentReference[oaicite:0]{index=0}
 *  • Retrieves every manifest.ttl, parses it with N3,
 *    and executes every mf:QueryEvaluationTest it finds.
 *  • Imports graphs into the RDF repository  test/test  (or $TEST_REPO),
 *    runs sparql‑query, captures the result, and compares with
 *    the official expected result files that live under
 *    https://www.w3.org/2009/sparql/docs/tests/data‑sparql11/ … :contentReference[oaicite:1]{index=1}
 *
 *  Prerequisites
 *  -------------
 *      Node 18+            (built‑in fetch)
 *      npm i n3
 *      dydra‑import        (on $PATH, or edit the IMPORT CMD below)
 *      sparql‑query        (on $PATH, as specified by the user)
 */

import { promises as fs }   from 'fs';
import { execSync, spawnSync } from 'child_process';
import { tmpdir }           from 'os';
import path                 from 'path';
import { fileURLToPath }    from 'url';
import { Parser }           from 'n3';
import fetch                from 'node-fetch';      // for Node < 20

//------------------------------------------------------------------
// Constants
//------------------------------------------------------------------
const SUMMARY_URL = 'https://www.w3.org/2009/sparql/docs/tests/summary.html';
const BASE        = 'https://www.w3.org/2009/sparql/docs/tests/data-sparql11';
const REPO        = process.env.TEST_REPO || 'test/test';

const IMPORT_CMD  = (file) => `dydra-import ${REPO} ${file}`;
const QUERY_CMD   = (qry)  => `sparql-query ${REPO}`;   // we’ll pipe the query in

const mf  = 'http://www.w3.org/2001/sw/DataAccess/tests/test-manifest#';
const qt  = 'http://www.w3.org/2001/sw/DataAccess/tests/test-query#';
const rdf = 'http://www.w3.org/1999/02/22-rdf-syntax-ns#';

//------------------------------------------------------------------
// Helpers
//------------------------------------------------------------------
const tmpRoot = await fs.mkdtemp(path.join(tmpdir(), 'sparql11-'));

function uniq(arr) { return [...new Set(arr)]; }

async function fetchText (url) {
  const res = await fetch(url);
  if (!res.ok) throw new Error(`GET ${url} → ${res.status}`);
  return res.text();
}

async function download (url, file) {
  const res = await fetch(url);
  if (!res.ok) throw new Error(`GET ${url} → ${res.status}`);
  await fs.writeFile(file, await res.arrayBuffer());
}

function exec (cmd, opts = {}) {
  return execSync(cmd, { stdio: 'pipe', encoding: 'utf8', ...opts });
}

//------------------------------------------------------------------
// MAIN
//------------------------------------------------------------------
console.log(`Repository: ${REPO}`);
console.log('Fetching summary page …');

const summaryHtml = await fetchText(SUMMARY_URL);

// collect manifest directories that appear in the header list
const manifestDirs = uniq(
  [...summaryHtml.matchAll(/href="(?:\.\.\/)*data-sparql11\/([^"]+)\/manifest#/g)]
    .map(m => m[1].replace(/\/?$/, ''))              // drop tailing slash
).sort();

for (const dir of manifestDirs) {
  const manifestUrl  = `${BASE}/${dir}/manifest.ttl`;
  const manifestTtl  = await fetchText(manifestUrl);

  console.log(`\n=== ${dir} ===`);

  // Parse the manifest with N3
  const parser  = new Parser({ baseIRI: `${BASE}/${dir}/` });
  const quads   = parser.parse(manifestTtl);

  // group quads by subject for convenience
  const bySubject = new Map();
  for (const q of quads) {
    const s = q.subject.value;
    if (!bySubject.has(s)) bySubject.set(s, []);
    bySubject.get(s).push(q);
  }

  //----------------------------------------------------------------
  // For every mf:QueryEvaluationTest …
  //----------------------------------------------------------------
  for (const [subject, triples] of bySubject) {
    const isEvalTest = triples.some(q =>
      q.predicate.value === `${rdf}type` &&
      q.object.value    === `${mf}QueryEvaluationTest`
    );
    if (!isEvalTest) continue;

    const getObj = (pred) => triples
      .filter(q => q.predicate.value === pred)
      .map(q => q.object.value);

    const label      = path.basename(subject);
    const queryFile  = getObj(`${qt}query`)[0];
    const dataFile   = getObj(`${qt}data` )[0] || null;
    const graphDatas = getObj(`${qt}graphData`);
    const resultFile = getObj(`${mf}result`)[0];

    // --------------------------------------------------------------
    // 1. Download datasets and import into repository
    // --------------------------------------------------------------
    const downloadAndImport = async (fileUrl) => {
      const local = path.join(tmpRoot, path.basename(fileUrl));
      await download(fileUrl, local);
      exec(IMPORT_CMD(local));
    };

    if (dataFile)   await downloadAndImport(`${BASE}/${dir}/${dataFile}`);
    for (const g of graphDatas)
                    await downloadAndImport(`${BASE}/${dir}/${g}`);

    // --------------------------------------------------------------
    // 2. Download query + expected result
    // --------------------------------------------------------------
    const queryPath  = path.join(tmpRoot, path.basename(queryFile));
    const expectPath = path.join(tmpRoot, 'exp_' + label);
    await download(`${BASE}/${dir}/${queryFile}`,  queryPath);
    await download(`${BASE}/${dir}/${resultFile}`, expectPath);

    // --------------------------------------------------------------
    // 3. Execute query
    // --------------------------------------------------------------
    const proc = spawnSync('bash', ['-c', QUERY_CMD(queryPath)], {
      input: await fs.readFile(queryPath),
      encoding: 'utf8'
    });
    if (proc.error) throw proc.error;
    const actual = proc.stdout;
    const actualPath = path.join(tmpRoot, 'act_' + label);
    await fs.writeFile(actualPath, actual);

    // --------------------------------------------------------------
    // 4. Compare
    // --------------------------------------------------------------
    const expected = await fs.readFile(expectPath, 'utf8');
    if (expected.trim() === actual.trim()) {
      console.log(`   ✔ ${label}`);
    } else {
      console.log(`   ✘ ${label}  (results differ)`);
    }
  }
}

console.log(`\nAll done.  Temporary files → ${tmpRoot}`);
