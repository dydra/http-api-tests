#! /bin/bash

curl_sparql_request -H "Accept: application/sparql-results+json" --url "${GRAPH_STORE_URL}-write" <<EOF \
   | jq '.boolean' | fgrep -q 'true'
PREFIX     : <http://example.org/> 
INSERT { GRAPH :g2 { ?s ?p 'r' } } WHERE { ?s ?p ?o }
EOF
