#! /bin/bash

# test collation for the location strings

curl_sparql_request  \
     --repository "collation" <<EOF \
 | jq '.results.bindings[] | .location.value' | diff - ordered-locations-da.txt
select distinct ?s ?location
 where {
  ?s <http://example.org/location> ?location .
  filter (lang(?location) = "da") }
order by (?location)
EOF

