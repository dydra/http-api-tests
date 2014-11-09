#! /bin/bash


curl -f -s -S -X POST \
     -H "Content-Type: application/sparql-query" \
     -H "Accept: application/sparql-results+json" \
     --data-binary @- \
     ${STORE_URL}/${STORE_ACCOUNT}/${STORE_REPOSITORY}?auth_token=${STORE_TOKEN} <<EOF
PREFIX     : <http://example.org/> 
INSERT { GRAPH :g2 { ?s ?p 'r' } } WHERE { ?s ?p ?o }
EOF
