#! /bin/bash
# check url encoding
# check various graph parameters

curl_sparql_request \
     -H "Content-Type: application/x-www-form-urlencoded" \
     -H "Accept: application/sparql-results+json" <<EOF \
   | jq '.results.bindings[] | .[].value' | fgrep -q '"1"'
query=select%20count(*)%20where%20%7b?s%20?p%20?o%7d
EOF

curl_sparql_request default-graph-uri=urn:dydra:default\
     -H "Content-Type: application/sparql-query" \
     -H "Accept: application/sparql-results+json" <<EOF \
   | jq '.results.bindings[] | .[].value' | fgrep -q 'default'
select * where { ?s ?p ?o }
EOF


curl_sparql_request  default-graph-uri=urn:dydra:all \
     -H "Content-Type: application/sparql-query" \
     -H "Accept: application/sparql-results+json" <<EOF \
   | cat  # jq '.results.bindings[] | .[].value' | fgrep -q 'named'
select * where { ?s ?p ?o }
EOF

curl_sparql_request  default-graph-uri=urn:dydra:named\
     -H "Content-Type: application/sparql-query" \
     -H "Accept: application/sparql-results+json" <<EOF \
   | cat # jq '.results.bindings[] | .[].value' | fgrep -q -v 'default'
select * where { ?s ?p ?o }
EOF
