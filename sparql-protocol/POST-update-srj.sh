#! /bin/bash

set_sparql_url "${STORE_ACCOUNT}" "${STORE_REPOSITORY}-write"

curl -f -s -S -X POST \
     -H "Content-Type: application/sparql-query" \
     -H "Accept: application/sparql-results+json" \
     --data-binary @- \
     -u "${STORE_TOKEN}:" \
     "${SPARQL_URL}" <<EOF \
 | jq '.boolean' | fgrep -q 'true'
PREFIX     : <http://example.org/> 
INSERT { GRAPH :g2 { ?s ?p 'r' } } WHERE { ?s ?p ?o }
EOF
