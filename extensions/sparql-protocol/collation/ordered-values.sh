#! /bin/bash

set_sparql_url "openrdf-sesame" "collation"

${CURL} -f -s -S -X POST --data-binary @- \
     -H "Content-Type: application/sparql-query" \
     -H "Accept: application/sparql-results+json" \
     -u "${STORE_TOKEN}:" \
     "${SPARQL_URL}" <<EOF \
 | jq '.results.bindings[] | .value.value' | diff - ordered-values.txt 
select distinct ?s ?value
 where {
  ?s <http://example.org/value> ?value .
 }
order by (?value)
EOF

