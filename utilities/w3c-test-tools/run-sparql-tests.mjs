#!/usr/bin/env node
/**
 * run-sparql-tests.mjs   —  results distinguished by query name
 *
 * • viewName comes from the query file (basename without ".rq")
 * • Produced result is saved as <viewName>.(srj|srx)
 * • Expected file still comes from mf:result (and may be shared)
 * • Dataset upload (qt:data / qt:graphData) handled per /sparql endpoint
 */
import fs from 'fs/promises';
import path from 'path';
import { Parser, Store, DataFactory } from 'n3';
import { parse as parsePath } from 'path';      // at top of file, if not present

if (typeof fetch !== 'function') {
  const { default: fetchPoly } = await import('node-fetch');
  globalThis.fetch = fetchPoly;
}

/* ── config ──────────────────────────────────────────── */
const DEBUG        = process.env.DEBUG === '1';
const TEST_ROOT    = path.resolve('.');
const RESULTS_ROOT = path.resolve('./results');
const TOKEN = process.argv[2] || '';

const SERVICES = [
  { name:'dydra.com.sparql',
    url :'https://dydra.com/sparql-12/exists-tests-inline/sparql' },  // POST
  { name:'dydra.com',
    url :'https://dydra.com/sparql-12/exists-tests' }          // GET
];

/* ── RDF terms ───────────────────────────────────────── */
const ns = {
  mf :'http://www.w3.org/2001/sw/DataAccess/tests/test-manifest#',
  qt :'http://www.w3.org/2001/sw/DataAccess/tests/test-query#',
  rdf:'http://www.w3.org/1999/02/22-rdf-syntax-ns#',
};
const RDF_TYPE   = DataFactory.namedNode(ns.rdf + 'type');
const MF_MAN     = DataFactory.namedNode(ns.mf  + 'Manifest');
const MF_ENTRIES = DataFactory.namedNode(ns.mf  + 'entries');
const MF_ACTION  = DataFactory.namedNode(ns.mf  + 'action');
const MF_RESULT  = DataFactory.namedNode(ns.mf  + 'result');
const QT_QUERY   = DataFactory.namedNode(ns.qt  + 'query');
const QT_DATA    = DataFactory.namedNode(ns.qt  + 'data');
const QT_GRAPH   = DataFactory.namedNode(ns.qt  + 'graphData');
const RDF_FIRST  = DataFactory.namedNode(ns.rdf + 'first');
const RDF_REST   = DataFactory.namedNode(ns.rdf + 'rest');
const RDF_NIL    = DataFactory.namedNode(ns.rdf + 'nil');

/* ── helpers ─────────────────────────────────────────── */
const log=(...a)=>console.log(...a);
const debug=(...a)=>DEBUG&&console.error('[DEBUG]',...a);
async function fetchText(u,i={}){const r=await fetch(u,i);
  if(!r.ok)throw new Error(`${i.method||'GET'} ${u} → ${r.status}`);return r.text();}
async function* walk(d){for await(const e of await fs.opendir(d)){
  const p=path.join(d,e.name);
  if(e.isDirectory())yield*walk(p); else if(e.name==='manifest.ttl')yield p;}}
const list=(st,h)=>{const a=[];let n=h;
  while(n&&!n.equals(RDF_NIL)){a.push(st.getObjects(n,RDF_FIRST,null)[0]);
    n=st.getObjects(n,RDF_REST,null)[0];}return a;};

/* upload dataset */
/* ── helper: graph-store upload (PUT text/turtle) ────────────────────── */
async function uploadDatasetViaGSP(serviceURL, queryText,
                                   defaultFile, namedFiles, token) {

  if (!defaultFile && !namedFiles.length) return;
  if (!serviceURL.endsWith('sparql'))       // path-style services: nothing to do
    return;

  const gsp = serviceURL.replace(/sparql$/, 'service');

  // read Turtle files
  const defaultData = defaultFile ? await fs.readFile(defaultFile, 'utf8') : '';
  const namedData   = await Promise.all(namedFiles.map(f => fs.readFile(f, 'utf8')));

  // graph URIs from the query
  const defURIs = [...queryText.matchAll(/FROM\s+<([^>]+)>/gi)].map(m => m[1]);
  const namedURIs = [...queryText.matchAll(/FROM\s+NAMED\s+<([^>]+)>/gi)].map(m => m[1]);

  /* --- helper to PUT a graph --- */
  async function putGraph(target, turtle) {
    await fetchText(target, {
      method : 'PUT',
      headers: { 'Content-Type': 'text/turtle',
                 'Accept'      : 'application/sparql-results+json',
                  ...(token ? { 'Authorization': `Bearer ${token}` } : {}) },
      body   : turtle
    });
    if (DEBUG) debug('   GSP PUT →', target);
  }

  // default graph
  if (defaultData) {
    const target = defURIs.length
      ? `${gsp}?graph=${encodeURIComponent(defURIs[0])}`
      : gsp;                                  // unnamed default graph
    await putGraph(target, defaultData);
  }

  // named graphs
  for (let i = 0; i < namedData.length; i++) {
    if (!namedData[i]) continue;
    const g = namedURIs[i] || `urn:g${i}`;
    const target = `${gsp}?graph=${encodeURIComponent(g)}`;
    await putGraph(target, namedData[i]);
  }
}




/* ── main ───────────────────────────────────────────── */
log('Test root   :',TEST_ROOT);
await fs.mkdir(RESULTS_ROOT,{recursive:true});

for await (const manFile of walk(TEST_ROOT)){
  const mDir=path.dirname(manFile);
  const mRel=path.relative(TEST_ROOT,mDir)||'.';
  log(`\n▸ Manifest: ${mRel}/manifest.ttl`);
  const store=new Store(
    new Parser({baseIRI:`https://ex/${mRel}/`})
      .parse(await fs.readFile(manFile,'utf8')));
  
  const tests=new Set();
  for(const mf of store.getSubjects(RDF_TYPE,MF_MAN,null))
    for(const head of store.getObjects(mf,MF_ENTRIES,null))
      for(const t of list(store,head)) tests.add(t.value);
  
  for(const uri of tests){
    const test=DataFactory.namedNode(uri);
    const action=store.getObjects(test,MF_ACTION,null)[0];
    const result=store.getObjects(test,MF_RESULT,null)[0];
    if(!action||!result){debug('   ⚠ missing action/result',uri);continue;}

    /* query + dataset */
    let queryFile, defFile, graphFiles=[];
    if(action.termType==='NamedNode'){ queryFile=path.posix.basename(action.value);}
    else{
      const q=store.getObjects(action,QT_QUERY,null)[0];
      if(!q){debug('   ⚠ no qt:query',uri);continue;}
      queryFile=path.posix.basename(q.value);
      const d=store.getObjects(action,QT_DATA,null)[0];
      if(d) defFile=path.join(mDir,path.posix.basename(d.value));
      graphFiles=store.getObjects(action,QT_GRAPH,null)
                      .map(n=>path.join(mDir,path.posix.basename(n.value)));
    }

    //const viewName = queryFile.replace(/\.rq$/i,'');         // used in URL

    const viewName = parsePath(queryFile).name;     // strips whatever extension
    const ext = path.extname(result.value).toLowerCase();     // ext from manifest
    const accept = ext==='.srx'?'application/sparql-results+xml'
                               :'application/sparql-results+json';

    const queryPath = path.join(mDir,queryFile);
    const queryText = await fs.readFile(queryPath,'utf8');

    for(const svc of SERVICES){
      const isEndpoint = svc.url.endsWith('sparql');
      const auth = new URL(svc.url).hostname;
      const outDir = path.join(RESULTS_ROOT, svc.name, mRel);
      await fs.mkdir(outDir,{recursive:true});
      const outPath = path.join(outDir,`${viewName}${ext}`);   // ← saved by query

      try{
        if (isEndpoint) await uploadDatasetViaGSP(svc.url, queryText, defFile, graphFiles, TOKEN);
        const actual = isEndpoint
          ? await fetchText(svc.url,{
              method:'POST',
              headers:{'Content-Type':'application/sparql-query','Accept':accept},
              body:queryText})
          : await fetchText(`${svc.url}/${viewName}`,{headers:{'Accept':accept}});
        await fs.writeFile(outPath,actual,'utf8');
        if(DEBUG)log('   •',path.relative(RESULTS_ROOT,outPath));
      }catch(e){
        console.error('   ✘', svc.name, viewName, '→', e.message);
        if (e.message.includes(' 400 ')) {           // ← NEW
          console.error('   ↳ query that failed:\n' + queryText);
        }
      }
    }
  }
}
log('\nRaw results saved under',RESULTS_ROOT);
