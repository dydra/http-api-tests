# JavaScript SPARQL Test Harness

This repository delivers a reproducible harness for W3C-style SPARQL tests.

| file | purpose |
|------|---------|
| **run-sparql-tests.mjs** | discovers every `manifest.ttl`, uploads datasets, executes each query against one or more SPARQL endpoints, and saves “actual” result files under `./results` |
| **summarize-sparql-results.mjs** | builds `results/summary.html`, an interactive page that compares every “actual” result with the **intended** result referenced in the manifests |

---

## 1  Install prerequisites

```bash
git clone <your-repo>  sparql-test-harness
cd  sparql-test-harness
npm init -y
npm i n3 node-fetch fast-xml-parser
