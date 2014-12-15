#! /bin/bash

set_sparql_url "openrdf-sesame" "collation"

curl_sparql_request "Accept: application/sparql-results+json" <<EOF \
 | jq '.results.bindings[] | .value.value' | diff - ordered-values.txt 
select distinct ?s ?value
 where {
  ?s <http://example.org/value> ?value .
 }
order by (?value)
EOF

