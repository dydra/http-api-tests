#! /bin/bash

initialize_repository --repository "${STORE_REPOSITORY}-write"


curl_sparql_request \
     -H "Accept: application/sparql-results+json" \
     -H "Content-Type: application/sparql-update" \
     --repository "${STORE_REPOSITORY}-write" <<EOF \
   | jq '.boolean' | fgrep -q 'true'
move <http://dydra.com/openrdf-sesame/mem-rdf/graph-name>
to <http://dydra.com/openrdf-sesame/mem-rdf/graph-name-moved>
EOF

curl_sparql_request \
     -H "Content-Type: application/sparql-query" \
     -H "Accept: application/sparql-results+json" \
     --repository "${STORE_REPOSITORY}-write"<<EOF \
   | jq '.results.bindings[] | .[].value' | fgrep -q "name-moved"
select ?g where { graph ?g { ?s ?p ?o } }
EOF
