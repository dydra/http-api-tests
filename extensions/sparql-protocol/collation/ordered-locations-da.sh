#! /bin/bash

# test collation for the location strings

curl_sparql_request  \
     --repository "collation" <<EOF \
 | jq '.results.bindings[] | .location.value' | diff - ordered-locations-da.txt
select  ?location #?lang
 where {
  { ?s <http://example.org/location> ?location }.
  #bind (lang(?location) as ?lang)
  filter ("da" = lang(?location))
 }
#order by (?location)
EOF

