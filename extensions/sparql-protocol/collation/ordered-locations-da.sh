#! /bin/bash

# test collation for the location strings

set_sparql_url "openrdf-sesame" "collation"

curl_sparql_request "Accept: application/sparql-results+json" <<EOF \
 | jq '.results.bindings[] | .location.value' | diff - ordered-locations-da.txt
select distinct ?s ?location
 where {
  ?s <http://example.org/location> ?location .
  filter (lang(?location) = "da") }
order by (?location)
EOF

