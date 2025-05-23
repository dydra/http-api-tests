#!/usr/bin/env node
/**
 * run-sparql11-tests.mjs
 *
 * Runs SPARQL 1.1 Query Evaluation tests whose manifests live locally.
 * Expected results may be JSON (*.srj) or XML (*.srx); the script requests
 * the corresponding format, canonicalises both formats, and compares them.
 *
 * CHANGES:
 *   1. When results differ the full *expected* and *actual* documents are
 *      printed to the console (trimmed to 2 kB each for sanity).
 *   2. Result files are written beneath:
 *          ./results/<authority>/<manifest‑relative‑dir>/<view>.(srj|srx)
 *      where <authority> is the hostname part of the remote endpoint
 *      (e.g. `dydra.com`).
 *
 * Dependencies
 *   $ npm i n3 node-fetch fast-xml-parser
 *
 * Usage
 *   $ DEBUG=1 ./run-sparql11-tests.mjs [<tests-root>]
 */

import fs from 'fs/promises';
import path from 'path';
import { Parser, Store, DataFactory } from 'n3';
import { XMLParser } from 'fast-xml-parser';

//──────────────────────────────────────────────────────────────────────────
// CLI & constants
//──────────────────────────────────────────────────────────────────────────
const DEBUG         = process.env.DEBUG === '1';
const TEST_ROOT     = path.resolve(process.argv[2] || '.');
const RESULTS_ROOT  = path.resolve('./results');
const ENDPOINT_ROOT = 'https://dydra.com/sparql-12/exists-tests';
const ENDPOINT_AUTH = new URL(ENDPOINT_ROOT).hostname;          // 'dydra.com'

// Namespaces
const ns = {
  mf : 'http://www.w3.org/2001/sw/DataAccess/tests/test-manifest#',
  qt : 'http://www.w3.org/2001/sw/DataAccess/tests/test-query#',
  rdf: 'http://www.w3.org/1999/02/22-rdf-syntax-ns#',
};

//──────────────────────────────────────────────────────────────────────────
// Helpers
//──────────────────────────────────────────────────────────────────────────
const log   = (...a) => console.log(...a);
const debug = (...a) => { if (DEBUG) console.error('[DEBUG]', ...a); };

async function fetchText(url, headers) {
  debug('GET', url, headers);
  const res = await fetch(url, { headers });
  if (!res.ok) throw new Error(`GET ${url} – ${res.status} ${res.statusText}`);
  return res.text();
}

/** deterministic stringify */
function stable(obj) {
  if (Array.isArray(obj)) return obj.map(stable);
  if (obj && typeof obj === 'object') {
    const o = {};
    for (const k of Object.keys(obj).sort()) o[k] = stable(obj[k]);
    return o;
  }
  return obj;
}

const xmlParser = new XMLParser({ ignoreAttributes:false, preserveOrder:true });

/** Canonicalise document text based on declared format */
function canon(text, fmt) {
  const trimmed = text.trim();
  if (fmt === 'json') {
    return JSON.stringify(stable(JSON.parse(trimmed)));
  } else {
    return JSON.stringify(stable(xmlParser.parse(trimmed)));
  }
}

async function* walk(dir, filt) {
  for await (const e of await fs.opendir(dir)) {
    const p = path.join(dir, e.name);
    if (e.isDirectory()) yield* walk(p, filt);
    else if (filt(e.name)) yield p;
  }
}

//──────────────────────────────────────────────────────────────────────────
// Execution
//──────────────────────────────────────────────────────────────────────────
log('Test root   :', TEST_ROOT);
log('Results root:', path.join(RESULTS_ROOT, ENDPOINT_AUTH));
await fs.mkdir(RESULTS_ROOT, { recursive: true });

// Find manifests
const manifests = [];
for await (const p of walk(TEST_ROOT, n => n === 'manifest.ttl')) manifests.push(p);
manifests.sort();
if (!manifests.length) {
  console.error('No manifest.ttl found under', TEST_ROOT);
  process.exit(1);
}

// RDF terms
const RDF_TYPE  = DataFactory.namedNode(ns.rdf + 'type');
const MF_TEST   = DataFactory.namedNode(ns.mf + 'QueryEvaluationTest');
const MF_ACTION = DataFactory.namedNode(ns.mf + 'action');
const MF_RESULT = DataFactory.namedNode(ns.mf + 'result');
const QT_QUERY  = DataFactory.namedNode(ns.qt + 'query');

let total = 0, passed = 0;

for (const mPath of manifests) {
  const mDir = path.dirname(mPath);
  const mRel = path.relative(TEST_ROOT, mDir) || '.';
  log(`\n▸ Manifest: ${mRel}/manifest.ttl`);

  const store = new Store(
    new Parser({ baseIRI: `https://example.org/${mRel}/` })
      .parse(await fs.readFile(mPath, 'utf8'))
  );

  const tests = store.getSubjects(RDF_TYPE, MF_TEST, null);
  debug('  found', tests.length, 'tests');

  for (const subj of tests) {
    total++;

    const action = store.getObjects(subj, MF_ACTION, null)[0];
    const resultObj = store.getObjects(subj, MF_RESULT, null)[0];
    if (!action || !resultObj) {
      debug('   ⚠ missing action/result for', subj.value);
      continue;
    }

    const queryObj = store.getObjects(action, QT_QUERY, null)[0];
    if (!queryObj) {
      debug('   ⚠ missing qt:query inside action for', subj.value);
      continue;
    }

    const queryFile = path.posix.basename(queryObj.value);
    const viewName  = queryFile.replace(/\.rq$/i, '');

    const expectedFile = path.posix.basename(resultObj.value);
    const ext          = path.extname(expectedFile).toLowerCase();
    const format       = ext === '.srx' ? 'xml' : 'json';
    const accept       = format === 'xml'
      ? 'application/sparql-results+xml'
      : 'application/sparql-results+json';

    const endpoint   = `${ENDPOINT_ROOT}/${viewName}`;
    const actualPath = path.join(RESULTS_ROOT, ENDPOINT_AUTH, mRel, `${viewName}${ext}`);
    const expectedPath = path.join(mDir, expectedFile);
    await fs.mkdir(path.dirname(actualPath), { recursive: true });

    try {
      const actualTxt   = await fetchText(endpoint, { Accept: accept });
      await fs.writeFile(actualPath, actualTxt, 'utf8');

      const expectedTxt = await fs.readFile(expectedPath, 'utf8');

      const ok = canon(actualTxt, format) === canon(expectedTxt, format);
      if (ok) {
        log('   ✔', viewName);
        passed++;
      } else {
        log('   ✘', viewName, '(differs)');
        const clip = s => s.length > 2048 ? s.slice(0,2048)+'…(truncated)' : s;
        log('      — expected —\n' + clip(expectedTxt));
        log('      — actual   —\n' + clip(actualTxt));
      }
    } catch (e) {
      log('   ✘', viewName, 'error:', e.message);
    }
  }
}

log(`\nSummary: ${passed}/${total} tests passed.`);
log('Result documents stored in', path.join(RESULTS_ROOT, ENDPOINT_AUTH));
