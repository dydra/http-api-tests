#! /bin/bash

# test collation for the location strings

set_sparql_url "openrdf-sesame" "collation"

${CURL} -f -s -S -X POST --data-binary @- \
     -H "Content-Type: application/sparql-query" \
     -H "Accept: application/sparql-results+json" \
     -u "${STORE_TOKEN}:" \
     "${SPARQL_URL}" <<EOF \
 | jq '.results.bindings[] | .location.value' | diff - ordered-locations-da.txt
select distinct ?s ?location
 where {
  ?s <http://example.org/location> ?location .
  filter (lang(?location) = "da") }
order by (?location)
EOF

