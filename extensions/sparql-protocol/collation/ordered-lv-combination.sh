#! /bin/bash

# test collation for the location strings

set_sparql_url "openrdf-sesame" "collation"

curl_sparql_request <<EOF \
 | jq '.results.bindings[] | ( .value.value + " " + .location.value)' | diff - ordered-lv-combination.txt
select distinct ?s ?value ?location
 where {
  ?s <http://example.org/value> ?value .
  ?s <http://example.org/location> ?location .
 }
order by (concat( ?location, strlang('...', 'da'))) (?value + 1)
EOF

