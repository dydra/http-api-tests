#! /bin/bash

# test collation for the location strings

${CURL} -f -s -S -X POST --data-binary @- \
     -H "Content-Type: application/sparql-query" \
     -H "Accept: application/sparql-results+json" \
     ${STORE_URL}/${STORE_ACCOUNT}/${STORE_REPOSITORY}/sparql <<EOF  \
 | jq '.results.bindings[] | ( .value.value + " " + .location.value)' | diff - ordered-lv-combination.txt
select distinct ?s ?value ?location
 where {
  ?s <http://example.org/value> ?value .
  ?s <http://example.org/location> ?location .
 }
order by (concat( ?location, strlang("...", "da"))) (?value + 1)
EOF

