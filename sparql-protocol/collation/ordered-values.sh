#! /bin/bash

${CURL} -f -s -S -X POST --data-binary @- \
     -H "Content-Type: application/sparql-query" \
     -H "Accept: application/sparql-results+json" \
     ${STORE_URL}/${STORE_ACCOUNT}/${STORE_REPOSITORY}/sparql <<EOF \
 | jq '.results.bindings[] | .value.value' | diff - ordered-values.txt 
select distinct ?s ?value
 where {
  ?s <http://example.org/value> ?value .
 }
order by (?value)
EOF

