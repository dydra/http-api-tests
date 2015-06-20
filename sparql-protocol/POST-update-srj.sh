#! /bin/bash

curl_sparql_request \
     -H "Accept: application/sparql-results+json" \
     -H "Content-Type: application/sparql-update" \
     --repository "${STORE_REPOSITORY}-write" <<EOF \
   | jq '.boolean' | fgrep -q 'true'
PREFIX     : <http://example.org/> 
INSERT { GRAPH :g2 { ?s ?p 'r' } } WHERE { ?s ?p ?o }
EOF
